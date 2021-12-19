/*
Simple assert macros.

SEQUENTIAL_ASSERT for using in sequential contexts, such as
always-blocks, functions, initial-begins, etc.

ASSERT for using in module's body. Gets evaluated during elaboration allowing
you to terminate compilation of the erroneous code.

This header is tool-independent.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`ifndef ASSERT_H
`define ASSERT_H

`define SEQUENTIAL_ASSERT(condition, message) \
    if (!(condition)) \
        $error("ASSERTION FAILED in %m: %s", message);

`define ASSERT(condition, message) \
    initial begin \
        `SEQUENTIAL_ASSERT(condition, message) \
    end \

`endif
