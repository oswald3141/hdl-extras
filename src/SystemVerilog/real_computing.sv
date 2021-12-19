/*
This file provides functions to ease the work with real numbers.

This package is tool-independent.


The code is distributed under The MIT License
Copyright (c) 2021 Andrey Smolyakov
    (andreismolyakow 'at' gmail 'punto' com)
See LICENSE for the complete license text
*/

package real_computing;

// Compute the absolute value of a real number
function real abs(real n);
    return (n < 0) ? -n : n;
endfunction

// Compute the floating-point remainder of a/b
function real fmod(real a, b);
    return a - b*$floor(a/b);
endfunction

endpackage : real_computing
