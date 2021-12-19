/*
This file provides functions used to compute integer approximations of
logarithms. The primary use of these functions is to determine the size of
arrays using the bit_size and encoding_size functions. When put to maximal
use it is possible to create designs that eliminate hardcoded ranges and
automatically resize their variables by changing a few key parameters.

These functions can be used in most synthesizers to compute ranges for
arrays. The core functionality is provided in the ceil_log and
floor_log subprograms. These compute the logarithm in any integer base.
For convenenience, base-2 functions are also provided along with the array
sizing functions.

Additionaly, the file provides closest_8_multiple function calculating the
multiple of 8 closest to the given number. It's useful for determining widths
of AXI buses.

This package is tool-independent.

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


package sizing;

// Compute the integer result of the function
// floor(log(n)) where b is the base.
function automatic int unsigned floor_log(int n, b);
    int unsigned residual = n,
                 log = 0;
                 
     assert( n > 0 && b > 0) else
        $error("Both arguments must be positive!");
    
    while (residual > (b - 1)) begin
        residual = residual / b;
        ++log;
    end  
    
    return log;
endfunction : floor_log

// Compute the integer result of the function
// ceil(log(n)) where b is the base.
function automatic int unsigned ceil_log(int n, b);
    int unsigned residual = n - 1,
                 log = 0;
                 
     assert( n > 0 && b > 0) else
        $error("Both arguments must be positive!");
    
    while (residual > 0) begin
        residual = residual / b;
        ++log;
    end  
    
    return log;
endfunction : ceil_log

// Compute the integer result of the function
// floor(log2(n)).
function automatic int unsigned floor_log2(int n);
    return floor_log(n, 2);
endfunction : floor_log2

// Compute the integer result of the function
// ceil(log2(n)).
function automatic int unsigned ceil_log2(int n);
    return ceil_log(n, 2);
endfunction : ceil_log2

// Compute the total number of bits needed
// to represent a number in binary.
function automatic int unsigned bit_size(int n);
     assert( n >= 0 ) else
        $error("The argument must be non-negative!");
     
     return (n == 0) ? 1 : floor_log2(n) + 1;
endfunction : bit_size

// Compute the number of bits needed to encode
// n items.
function automatic int unsigned encoding_size(int n);
     assert( n > 0 ) else
        $error("The argument must be positive!");
     
     return (n == 1) ? 1 : ceil_log2(n);
endfunction : encoding_size

// Compute the total number of bits to represent
// an unsigned integer in binary.
function automatic int unsigned unsigned_size(int n);
    return bit_size(n);
endfunction : unsigned_size

// Compute the total number of bits to represent
// a 2's complement signed integer in binary.
function automatic int unsigned signed_size(int n);
    if (n == 0)
        return 2;
    else if (n > 0)
        return bit_size(n) + 1;
    else
        return bit_size(-1 - n) + 1;
endfunction : signed_size

// Compute multiple of 8 closest to the given number
function automatic int unsigned closest_8_multiple(int n);
    int unsigned mult = 8;
    
     assert( n > 0 ) else
        $error("The argument must be positive!");
    
    while (n > mult)
        mult += 8;
    return mult;
endfunction : closest_8_multiple

endpackage : sizing
