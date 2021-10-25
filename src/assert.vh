/*
Simple assert macroses.

SEQUENTIAL_ASSERT for using in sequential contexts, such as
always-blocks, functions, initial-beginc, etc.
ASSERT for using in module's body.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`ifndef ASSERT_H
`define ASSERT_H

`define SEQUENTIAL_ASSERT(condition, message) \
    if (!(condition)) begin \
        $display("ASSERTION FAILED in %m: %s", message); \
        $stop; \
    end

`define ASSERT(condition, message) \
    initial begin \
        `SEQUENTIAL_ASSERT(condition, message) \
    end

`endif
