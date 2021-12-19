/*
This file provides a number of synchronizer modules for managing
data transmission between clock domains.

If you need to synchronize a bus together you should use the
handshake_synchronizer module. If you generate an array of bit_synchronizer
modules instead, there is a risk that some bits will take longer than
others and invalid values will appear at the outputs. This is particularly
problematic if the bus represents a numeric value. bit_synchronizer can
be used safely in an array only if you know the input signal comes from an
isochronous domain (same period, different phase).

These modules are optimized for use with Xilinx Vivado. Attributes used in the
modules are Vivado-specific. Other tool would just probably ignore them. The
modules also may contain workarounds for some Vivado's bugs. If you intend to
use a module defined here with different synthesis tool, it would be better to
reimplement it.

The code presented here is either inspired by VHDL-extras library or directly
reimplements it in SystemVerilog.
https://github.com/kevinpt/vhdl-extras


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
Copyright (c) 2010 Kevin Thibedeau
    (kevin 'period' thibedeau 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

// A basic synchronizer with a configurable number of stages
module bit_synchronizer_sv
#(
    parameter int
        STAGES = 2,             // Number of flip-flops in the synchronizer
    parameter bit
        RESET_ACTIVE_LEVEL = 1  // Synch. reset control level
)
(
    input logic
        Clock,  // System clock
        Reset,  // Synchronous reset
        Bit_in, // Asynchronous bit
    output logic
        Sync    // Synchronized bit
);
    if (!(STAGES >= 2))
        $error("The number of the synchronization stages must be at least 2!");

    (* ASYNC_REG = "TRUE" *) logic [0:STAGES-1] sr;
    
    always_ff @ (posedge Clock) begin
        if (Reset == RESET_ACTIVE_LEVEL)
            sr <= 0;
        else
            sr <= {Bit_in, sr[0:STAGES-1-1]};  
    end
    
    assign Sync = sr[STAGES-1];
endmodule : bit_synchronizer_sv

// Synchronizer for generating a synchronized reset
module reset_synchronizer_sv
#(
    parameter int
        STAGES = 2,            // Number of flip-flops in the synchronizer
    parameter bit
        RESET_ACTIVE_LEVEL = 1 // Asynch. reset control level
)
(
    input logic
        Clock,     // System clock
        Reset,     // Asynchronous reset
    output logic
        Sync_reset // Synchronized reset
);
    if (!(STAGES >= 2))
        $error("The number of the synchronization stages must be at least 2!");

    (* dont_touch = "yes", shreg_extract = "no" *) logic [0:STAGES-1] sr;
    
    `define _RESET_SYNCHER_PROCESS_BODY \
        if (Reset == RESET_ACTIVE_LEVEL) \
            sr <= '{default:RESET_ACTIVE_LEVEL}; \
        else \
            sr <= {!RESET_ACTIVE_LEVEL, sr[0:STAGES-1-1]};
    
    generate
        if(RESET_ACTIVE_LEVEL == 1)
            always_ff @ (posedge Clock or posedge Reset)
                `_RESET_SYNCHER_PROCESS_BODY
        else
            always_ff @ (posedge Clock or negedge Reset)
                `_RESET_SYNCHER_PROCESS_BODY
    endgenerate
    
    assign Sync_reset = sr[STAGES-1];
endmodule : reset_synchronizer_sv

// A handshaking synchronizer for sending an array between clock domains
// This uses the four-phase handshake protocol.
module handshake_synchronizer_sv
#(
    parameter int
        WORD_LENGTH = 0,
        STAGES = 2,
    parameter bit
        RESET_ACTIVE_LEVEL = 1
)
(
    input  logic
        Clock_tx,
        Reset_tx,
        Clock_rx,
        Reset_rx,
        [WORD_LENGTH-1:0] Tx_data,
        Send_data,
    output logic
        Sending,
        Data_sent,
        [WORD_LENGTH-1:0] Rx_data,
        New_data
);
    // If's get evaluated during elaboration, hence better use them here
    // instead of assertions
    if (!(WORD_LENGTH > 0))
        $error("The value must be positive!");
    if (!(STAGES >= 2))
        $error("The number of the synchronization stages must be at least 2!");

    logic ack_rx, ack_tx;
    logic prev_ack;
    
    logic tx_reg_en;
    logic [WORD_LENGTH-1:0] tx_data_reg;
    
    logic req_rx;
    logic req_tx;
    logic prev_req;
    
    enum logic [1:0] {IDLE, SEND, FINISH} cur_state, next_state;

    (* ASYNC_REG = "TRUE" *) logic [WORD_LENGTH-1:0] Rx_data_r;
    logic Sending_r, New_data_r;
    assign Rx_data = Rx_data_r, Sending = Sending_r, New_data = New_data_r;

    // Tx logic
    
    bit_synchronizer_sv #(
        .STAGES(STAGES),
        .RESET_ACTIVE_LEVEL(RESET_ACTIVE_LEVEL)
    ) as (
        .Clock(Clock_tx),
        .Reset(Reset_tx),
        .Bit_in(ack_rx),
        .Sync(ack_tx)
    );
    
    always_ff @ (posedge Clock_tx) begin
        if (Reset_tx == RESET_ACTIVE_LEVEL)
            prev_ack <= 0;
        else
            prev_ack <= ack_tx;
    end

    assign Data_sent = (!ack_tx && prev_ack) ? 1 : 0;
    
    always_ff @ (posedge Clock_tx) begin
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
    
   always_ff @ (posedge Clock_tx) begin
        if (Reset_tx == RESET_ACTIVE_LEVEL)
            tx_data_reg <= '{default:1'b0};
        else begin
            if (tx_reg_en)
                tx_data_reg <= Tx_data;
        end
    end
    
    
    // Rx logic
    
    bit_synchronizer_sv #(
        .STAGES(STAGES),
        .RESET_ACTIVE_LEVEL(RESET_ACTIVE_LEVEL)
    ) rs (
        .Clock(Clock_rx),
        .Reset(Reset_rx),
        .Bit_in(req_tx),
        .Sync(req_rx)
    ); 
    
    assign ack_rx = req_rx;
    
    always_ff @ (posedge Clock_rx) begin
        if (Reset_rx == RESET_ACTIVE_LEVEL) begin
            prev_req   <= 0;
            Rx_data_r  <= '{default:1'b0};
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
endmodule : handshake_synchronizer_sv
