/*
This file provides functions to ease the work with real numbers.

This header is tool-independent.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

`ifndef REAL_COMPUTING_H
`define REAL_COMPUTING_H

`include "assert.vh"

// Compute the absolute value of a real number
function real abs;
    input real n;
begin
    abs = n;
    if ( n < 0 )
        abs = -abs;
end
endfunction

// Round real towards zero
function real trunc;
    input real n;
    integer n_floor, n_ceil, result;
begin
    // ModelSim prohibits the use of $rtoi here for calculating
    // localparams values, says it's not a constant function
    n_floor = n - 0.5; // cast to integer rounds to the closest
    n_ceil  = n + 0.5;
    trunc = (n > 0) ? n_floor : n_ceil;
end
endfunction

// Compute the floating-point remainder of a/b
function real fmod;
    input real a, b;
begin
    `SEQUENTIAL_ASSERT(b != 0,
        "Division by zero is undefined.")
    fmod = a - b*trunc(a/b);
end
endfunction

`endif
