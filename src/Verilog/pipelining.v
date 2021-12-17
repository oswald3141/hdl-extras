/*
The implementation of pipelining package from VHDL-extras in Verilog.

This package provides configurable shift register components intended to
be used as placeholders for register retiming during synthesis. These
components can be placed after a section of combinational logic. With 
retiming activated in the synesis tool, the flip-flops will be distributed
through the combinational logic to balance delays. The number of pipeline
stages is controlled with the PIPELINE_STAGES generic.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
Copyright (c) 2010 Kevin Thibedeau
    (kevin 'period' thibedeau 'at' gmail 'punto' com)
See LICENSE for the complete license text

*/

`ifndef PIPELINING_H
`define PIPELINING_H

`include "assert.vh"

// Pipeline registers for retiming
module pipeline
#(
    parameter
    WORD_LENGTH = 0,                  // Input/output port width
    PIPELINE_STAGES = 0,              // Number of pipeline stages to insert
    ATTR_REG_BALANCING = "backward",  // Control propagation direction (Xilinx only)
    RESET_ACTIVE_LEVEL = 1            // Synch. reset control level
)
(
    input  Clock,                    // System clock
    input  Reset,                    // Synch. reset
    input  [WORD_LENGTH-1:0] Sig_in, // Signal from module to be pipelined
    output [WORD_LENGTH-1:0] Sig_out // Pipelined result
);

    `ASSERT(WORD_LENGTH > 0, "The value must be positive!")
    `ASSERT(PIPELINE_STAGES > 0, "The value must be positive!")
    `ASSERT(RESET_ACTIVE_LEVEL == 1 || RESET_ACTIVE_LEVEL == 0, 
        "The reset value must be signle-bit!")

    integer i;
    
    localparam [0:1] retiming_code = ( ATTR_REG_BALANCING == "backward" ) ? 2'b10 :
                                     ( ATTR_REG_BALANCING == "forward" )  ? 2'b01 :
                                     2'b00;
                                     
    (*retiming_backward = retiming_code[0], retiming_forward = retiming_code[1] *)
        reg [WORD_LENGTH-1:0] pipe [0:PIPELINE_STAGES-1];
    
    always @ (posedge Clock) begin
        if (Reset == RESET_ACTIVE_LEVEL) begin
            for(i = 0; i < PIPELINE_STAGES; i = i + 1)
                pipe[i] <= 0;
        end else begin
            pipe[0] <= Sig_in;
            for(i = 1; i < PIPELINE_STAGES; i = i + 1)
                pipe[i] <= pipe[i-1];
        end
    end
    
    assign Sig_out = pipe[PIPELINE_STAGES-1];

endmodule

// General-purpose fixed delay line
module fixed_delay_line
#(
    parameter
    WORD_LENGTH = 0, // Input/output port width
    STAGES = -1      // Number of delay stages (0 for short circuit)
)
(
    input  Clock,                     // System clock
    input  Enable,                    // Synchronous enable
    input  [WORD_LENGTH-1:0] Data_in, // Input data
    output [WORD_LENGTH-1:0] Data_out // Delayed output data
);

    `ASSERT(WORD_LENGTH > 0, "The value must be positive!")
    `ASSERT(STAGES >= 0, "The value must be non-negative!")

    integer i;
    reg [WORD_LENGTH-1:0] pipe [0:STAGES-1];
    
    generate
        if ( STAGES == 0 )
            assign Data_out = Data_in;
        else begin
            always @ (posedge Clock) begin
                if (Enable) begin
                    pipe[0] <= Data_in;
                    for(i = 1; i < STAGES; i = i + 1)
                        pipe[i] <= pipe[i-1];
                end
            end
            
            assign Data_out = pipe[STAGES-1];
        end
    endgenerate
endmodule

// General-purpose dynamic delay line
module dynamic_delay_line
#(
    parameter
    WORD_LENGTH = 0,   // Input/output port width
    ADDRESS_LENGTH = 0 // Address bus width
)
(
    input  Clock,                        // System clock
    input  Enable,                       // Synchronous enable
    input  [ADDRESS_LENGTH-1:0] Address, // Selected delay stage
    input  [WORD_LENGTH-1:0]    Data_in, // Input data
    output [WORD_LENGTH-1:0]    Data_out // Delayed output data
);

    `ASSERT(WORD_LENGTH > 0,    "The value must be positive!")
    `ASSERT(ADDRESS_LENGTH > 0, "The value must be positive!")
    
    localparam STAGES = 2**ADDRESS_LENGTH;

    integer i;
    reg [WORD_LENGTH-1:0] pipe [0:STAGES-1];
    
    always @ (posedge Clock) begin
        if (Enable) begin
            pipe[0] <= Data_in;
            for(i = 1; i < STAGES; i = i + 1)
                pipe[i] <= pipe[i-1];
        end
    end
    
    assign Data_out = pipe[Address];
endmodule 

`endif
