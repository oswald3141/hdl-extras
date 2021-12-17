/*
The implementation of synchronizing package from VHDL-extras in Verilog.

This package provides a number of synchronizer components for managing
data transmission between clock domains.

If you need to synchronize a vector of bits together you should use the
handshake_synchronizer module. If you generate an array of bit_synchronizer
modules instead, there is a risk that some bits will take longer than
others and invalid values will appear at the outputs. This is particularly
problematic if the vector represents a numeric value. bit_synchronizer can
be used safely in an array only if you know the input signal comes from an
isochronous domain (same period, different phase).


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`ifndef SYNCHRONIZING_H
`define SYNCHRONIZING_H

`include "assert.vh"

// A basic synchronizer with a configurable number of stages
module bit_synchronizer
#(
    parameter
    STAGES = 2,
    RESET_ACTIVE_LEVEL = 1
)
(
    input  Clock,
    input  Reset,
    input  Bit_in,
    output Sync
);
    `ASSERT(STAGES >= 2,
        "The number of the synchronization stages must exceed 2!")
    `ASSERT(RESET_ACTIVE_LEVEL == 1 || RESET_ACTIVE_LEVEL == 0, 
        "The reset value must be signle-bit!")

    (* ASYNC_REG = "TRUE" *) reg [0:STAGES-1] sr;
    integer i;
    
    always @ (posedge Clock) begin
        if (Reset == RESET_ACTIVE_LEVEL)
            sr <= 0;
        else
            sr <= {Bit_in, sr[0:STAGES-1-1]};  
    end
    
    assign Sync = sr[STAGES-1];

endmodule

// Synchronizer for generating a synchronized reset
module reset_synchronizer
#(
    parameter
    STAGES = 2,            // Number of flip-flops in the synchronizer
    RESET_ACTIVE_LEVEL = 1 // Asynch. reset control level
)
(
    input  Clock,     // System clock
    input  Reset,     // Asynchronous reset
    output Sync_reset // Synchronized reset
);

    `ASSERT(STAGES >= 2,
        "The number of the synchronization stages must exceed 2!")
    `ASSERT(RESET_ACTIVE_LEVEL == 1 || RESET_ACTIVE_LEVEL == 0, 
        "The reset value must be signle-bit!")

    (* dont_touch = "yes", shreg_extract = "no" *) reg [0:STAGES-1] sr;
    integer i;
    
    always @ (posedge Clock or posedge Reset) begin
        if (Reset == RESET_ACTIVE_LEVEL)
            for (i = 0; i < STAGES; i = i + 1)
                sr[i] <= RESET_ACTIVE_LEVEL;
        else
            sr <= {!RESET_ACTIVE_LEVEL, sr[0:STAGES-1-1]};  
    end
    
    assign Sync_reset = sr[STAGES-1];

endmodule


// A handshaking synchronizer for sending an array between clock domains
// This uses the four-phase handshake protocol.
module handshake_synchronizer
#(
    parameter
    WORD_LENGTH = 0,
    STAGES = 2,
    RESET_ACTIVE_LEVEL = 1
)
(
    input  Clock_tx,
    input  Reset_tx,
    input  Clock_rx,
    input  Reset_rx,
    input  [WORD_LENGTH-1:0] Tx_data,
    input  Send_data,
    output Sending,
    output Data_sent,
    output [WORD_LENGTH-1:0] Rx_data,
    output New_data
);

    `ASSERT(WORD_LENGTH > 0,    "The value must be positive!")
    `ASSERT(STAGES >= 2,
        "The number of the synchronization stages must exceed 2!")
    `ASSERT(RESET_ACTIVE_LEVEL == 1 || RESET_ACTIVE_LEVEL == 0, 
        "The reset value must be signle-bit!")

    wire ack_rx, ack_tx;
    reg prev_ack;
    
    reg tx_reg_en;
    reg [WORD_LENGTH-1:0] tx_data_reg;
    
    wire req_rx;
    reg req_tx;
    reg prev_req;
    
    localparam  IDLE   = 2'b00,
                SEND   = 2'b01,
                FINISH = 2'b10;
    
    reg [1:0] cur_state;
    reg [1:0] next_state;

    (* ASYNC_REG = "TRUE" *) reg [WORD_LENGTH-1:0] Rx_data_r;
    reg Sending_r, New_data_r;
    assign Rx_data = Rx_data_r, Sending = Sending_r, New_data = New_data_r;


    // Tx logic
    
    bit_synchronizer #(
        .STAGES(STAGES),
        .RESET_ACTIVE_LEVEL(RESET_ACTIVE_LEVEL)
    ) as (
        .Clock(Clock_tx),
        .Reset(Reset_tx),
        .Bit_in(ack_rx),
        .Sync(ack_tx)
    );
    
    always @ (posedge Clock_tx) begin
        if (Reset_tx == RESET_ACTIVE_LEVEL)
            prev_ack <= 0;
        else
            prev_ack <= ack_tx;
    end

    assign Data_sent = (!ack_tx && prev_ack) ? 1 : 0;
    
    always @ (posedge Clock_tx) begin
        if (Reset_tx == RESET_ACTIVE_LEVEL) begin
            cur_state <= IDLE;
            tx_reg_en <= 0;
            req_tx    <= 0;
            Sending_r <= 0;
        end else begin
            next_state = cur_state;
            tx_reg_en <= 0;
            
            case (cur_state)
            IDLE:
                if (Send_data) begin
                    next_state = SEND;
                    tx_reg_en <= 1;
                end
            SEND:
                if (ack_tx)
                    next_state = FINISH;
            FINISH:
                if (!ack_tx)
                    next_state = IDLE;
            default:
                next_state = IDLE;
            endcase
            
            cur_state <= next_state;
            
            req_tx    <= 0;
            Sending_r <= 0;
            
            case (next_state)
            SEND:
                begin
                    req_tx    <= 1;
                    Sending_r <= 1;
                end
            FINISH:
                Sending_r <= 1;
            endcase
        end
    end
    
   always @ (posedge Clock_tx) begin
        if (Reset_tx == RESET_ACTIVE_LEVEL)
            tx_data_reg <= {WORD_LENGTH{1'b0}};
        else begin
            if (tx_reg_en)
                tx_data_reg <= Tx_data;
        end
    end
    
    
    // Rx logic
    
    bit_synchronizer #(
        .STAGES(STAGES),
        .RESET_ACTIVE_LEVEL(RESET_ACTIVE_LEVEL)
    ) rs (
        .Clock(Clock_rx),
        .Reset(Reset_rx),
        .Bit_in(req_tx),
        .Sync(req_rx)
    ); 
    
    assign ack_rx = req_rx;
    
    always @ (posedge Clock_rx) begin
        if (Reset_rx == RESET_ACTIVE_LEVEL) begin
            prev_req   <= 0;
            Rx_data_r  <= {WORD_LENGTH{1'b0}};
            New_data_r <= 0;
        end else begin
            prev_req   <= req_rx;
            New_data_r <= 0;
            
            if (req_rx && !prev_req) begin
                Rx_data_r  <= tx_data_reg;
                New_data_r <= 1;
            end
        end
    end

endmodule

`endif
