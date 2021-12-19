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

// Compute the absolute value of a real number
function real abs;
    input real n;
begin
    abs = n;
    if ( n < 0 )
        abs = -abs;
end
endfunction

// Compute the floating-point remainder of a/b
function real fmod;
    input real a, b;
begin
    fmod = a - b*$floor(a/b);
end
endfunction

`endif
