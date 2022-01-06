/*
This file provides configurable shift register modules.

pipeline_v is intended to be used as placeholders for register retiming during
synthesis. The module can be placed after a section of combinational logic.
With retiming activated in the synthesis tool, the flip-flops will be
distributed through the combinational logic to balance delays. The number of
pipeline stages is controlled with the PIPELINE_STAGES generic.

fixed_delay_line_v is a simple delay line friedly to inferring SRL primitives.
You can force the synthesis synesis tool to infer a specific stype of shift
registers implementation by setting ATTR_SRL_STYLE parameter to something
other than auto. Vivado 2020.2 supports the following values for this
attribute:
- register: The tool does not infer an SRL, but instead only uses registers.
- srl: The tool infers an SRL without any registers before or after.
- srl_reg: The tool infers an SRL and leaves one register after the SRL.
- reg_srl: The tool infers an SRL and leaves one register before the SRL.
- reg_srl_reg: The tool infers an SRL and leaves one register before and one
register after the SRL.
- block: The tool infers the SRL inside a block RAM.

dynamic_delay_line_v is similar to the fixed_delay_line_v. It allows you to
access any register in the chain by its address. It doesn't support setting
srl_style attribute though.

These modules are optimized for use with Xilinx Vivado. Attributes used in the
modules are Vivado-specific. Other tool would just probably ignore them. The
modules also may contain workarounds for some Vivado's bugs. If you intend to
use a module defined here with different synthesis tool, it would be better to
reimplement it.

The code presented here is either inspired by VHDL-extras library or directly
reimplements it in Verilog.
https://github.com/kevinpt/vhdl-extras


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
Copyright (c) 2010 Kevin Thibedeau
    (kevin 'period' thibedeau 'at' gmail 'punto' com)
See LICENSE for the complete license text

*/

`include "assert.vh"

// Pipeline registers for retiming
module pipeline_v
#(
    parameter integer
        WORD_LENGTH = 0,        // Input/output port width
        PIPELINE_STAGES = 0,    // Number of pipeline stages to insert
    parameter [0:0]
        RESET_ACTIVE_LEVEL = 1, // Synch. reset control level
        // Control propagation direction (Xilinx only)
        ATTR_RETIMING_BACKWARD = 0,
        ATTR_RETIMING_FORWARD  = 0
)
(
    input wire
        Clock,                    // System clock
        Reset,                    // Synch. reset
        [WORD_LENGTH-1:0] Sig_in, // Signal from module to be pipelined
    output wire
        [WORD_LENGTH-1:0] Sig_out // Pipelined result
);

    `ASSERT(WORD_LENGTH > 0, "The value must be positive!")
    `ASSERT(PIPELINE_STAGES > 0, "The value must be positive!")
    `ASSERT(ATTR_RETIMING_BACKWARD ^ ATTR_RETIMING_FORWARD,
        "You should enable exactly one retiming direction!")

    (*retiming_backward = ATTR_RETIMING_BACKWARD, 
        retiming_forward = ATTR_RETIMING_FORWARD*)
        reg [WORD_LENGTH-1:0] pipe [0:PIPELINE_STAGES-1];
    
    always @ (posedge Clock) begin : pipe_pushing
        integer i;
        
        if (Reset == RESET_ACTIVE_LEVEL) begin
            for(i = 0; i < PIPELINE_STAGES; i = i + 1)
                pipe[i] <= 0;
        end else begin
            pipe[0] <= Sig_in;
            for(i = 1; i < PIPELINE_STAGES; i = i + 1)
                pipe[i] <= pipe[i-1];
        end
    end : pipe_pushing
    
    assign Sig_out = pipe[PIPELINE_STAGES-1];
endmodule

// General-purpose fixed delay line
// Leave ATTR_SRL_STYLE set to "auto" if you want to leave SRL_STYLE attribute
// uninitialized. Otherwise you can specifiy the exact value of it.
module fixed_delay_line_v
#(
    parameter integer
        WORD_LENGTH = 0, // Input/output port width
        STAGES = -1,     // Number of delay stages (0 for short circuit)
    parameter //string
        ATTR_SRL_STYLE = "auto"
)
(
    input wire
        Clock,                     // System clock
        Enable,                    // Synchronous enable
        [WORD_LENGTH-1:0] Data_in, // Input data
    output wire
        [WORD_LENGTH-1:0] Data_out // Delayed output data
);

    `ASSERT(WORD_LENGTH > 0, "The value must be positive!")
    `ASSERT(STAGES >= 0, "The value must be non-negative!")
    
    // Body macro
    `define  _FIXED_DELAY_LINE_BODY \
        always @ (posedge Clock) begin : pipe_pushing \
            integer i; \
            if (Enable) begin \
                pipe[0] <= Data_in; \
                for(i = 1; i < STAGES; i = i + 1) \
                    pipe[i] <= pipe[i-1]; \
            end \
        end : pipe_pushing \
        assign Data_out = pipe[STAGES-1];
    // End body macro

    generate
        if ( STAGES == 0 ) begin
            assign Data_out = Data_in; //Short circuit
        end else begin
        
            if (ATTR_SRL_STYLE == "auto") begin // User doesn't want to set SRL_STYLE
                
                reg [WORD_LENGTH-1:0] pipe [0:STAGES-1];
                `_FIXED_DELAY_LINE_BODY
            
            end else begin  // User wants to set SRL_STYLE
            
                (*srl_style = ATTR_SRL_STYLE*)
                    reg [WORD_LENGTH-1:0] pipe [0:STAGES-1];
                `_FIXED_DELAY_LINE_BODY
                
            end
        end
    endgenerate
endmodule

// General-purpose dynamic delay line
module dynamic_delay_line_v
#(
    parameter integer
        WORD_LENGTH = 0,   // Input/output port width
        ADDRESS_LENGTH = 0 // Address bus width
)
(
    input wire
        Clock,                        // System clock
        Enable,                       // Synchronous enable
        [ADDRESS_LENGTH-1:0] Address, // Selected delay stage
        [WORD_LENGTH-1:0]    Data_in, // Input data
    output wire
        [WORD_LENGTH-1:0]    Data_out // Delayed output data
);

    `ASSERT(WORD_LENGTH > 0,    "The value must be positive!")
    `ASSERT(ADDRESS_LENGTH > 0, "The value must be positive!")
    
    localparam STAGES = 2**ADDRESS_LENGTH;

    reg [WORD_LENGTH-1:0] pipe [0:STAGES-1];
    
    always @ (posedge Clock) begin : pipe_pushing
        integer i;
        
        if (Enable) begin
            pipe[0] <= Data_in;
            for(i = 1; i < STAGES; i = i + 1)
                pipe[i] <= pipe[i-1];
        end
    end : pipe_pushing
    
    assign Data_out = pipe[Address];
endmodule 
