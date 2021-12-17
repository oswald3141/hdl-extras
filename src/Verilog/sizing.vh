/*
The implementation of sizing package from VHDL-extras in Verilog.
https://github.com/kevinpt/vhdl-extras

This package provides functions used to compute integer approximations
of logarithms. The primary use of these functions is to determine the
size of arrays using the bit_size and encoding_size functions. When put to
maximal use it is possible to create designs that eliminate hardcoded
ranges and automatically resize their signals and variables by changing a
few key constants or generics.

These functions can be used in most synthesizers to compute ranges for
arrays. The core functionality is provided in the ceil_log and
floor_log subprograms. These compute the logarithm in any integer base.
For convenenience, base-2 functions are also provided along with the array
sizing functions.

Notice, that SEQUENTIAL_ASSERT works only in sequential context (functions,
always-blocks, etc.) It won't be executed if called in, e.g. localparam
definition. Be careful with that.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
Copyright (c) 2010 Kevin Thibedeau
    (kevin 'period' thibedeau 'at' gmail 'punto' com)
See LICENSE for the complete license text

*/

`ifndef SIZING_H
`define SIZING_H

`include "assert.vh"

// Compute the integer result of the function
// floor(log(n)) where b is the base.
function automatic integer floor_log;
    input integer n, b;
    integer residual;
begin
    `SEQUENTIAL_ASSERT(n > 0 && b > 0, 
        "Both arguments must be positive!")
    residual = n;
    floor_log = 0;
    while ( residual > (b-1) ) begin
        residual = residual / b;
        floor_log = floor_log + 1;
    end
end
endfunction

// Compute the integer result of the function
// ceil(log(n)) where b is the base.
function automatic integer ceil_log;
    input integer n, b;
    integer residual;
begin
    `SEQUENTIAL_ASSERT(n > 0 && b > 0, 
        "Both arguments must be positive!")
    residual = n - 1;
    ceil_log = 0;
    while ( residual > 0 ) begin
        residual = residual / b;
        ceil_log = ceil_log + 1;
    end
end
endfunction

// Compute the integer result of the function
// floor(log2(n)).
function automatic integer floor_log2;
    input integer n;
begin
    floor_log2 = floor_log(n, 2);
end
endfunction

// Compute the integer result of the function
// ceil(log2(n)).
function automatic integer ceil_log2;
    input integer n;
begin
    ceil_log2 = ceil_log(n, 2);
end
endfunction

// Compute the total number of bits needed
// to represent a number in binary.
function automatic integer bit_size;
    input integer n;
begin
    `SEQUENTIAL_ASSERT(n >= 0, 
        "The argument must be non-negative!")
    if (n == 0)
        bit_size = 1;
    else
        bit_size = floor_log2(n) + 1;
end
endfunction

// Compute the number of bits needed to encode
// n items.
function automatic integer encoding_size;
    input integer n;
begin
    `SEQUENTIAL_ASSERT(n > 0, 
        "The argument must be positive!")
    if (n == 1)
        encoding_size = 1;
    else
        encoding_size = ceil_log2(n);
end
endfunction

// Compute the total number of bits to represent
// an unsigned integer in binary.
function automatic integer unsigned_size;
    input integer n;
begin
    unsigned_size = bit_size(n);
end
endfunction

// Compute the total number of bits to represent
// a 2's complement signed integer in binary.
function automatic integer signed_size;
    input integer n;
begin
    `SEQUENTIAL_ASSERT(n >= 0, 
        "The argument must be non-negative!")
    if (n == 0)
        signed_size = 2;
    else if (n > 0)
        signed_size = bit_size(n) + 1;
    else
        signed_size = bit_size(-1 - n) + 1;
end
endfunction

`endif
