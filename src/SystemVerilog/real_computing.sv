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

// Round real towards zero
function real trunc(real n);
    // ModelSim prohibits the use of $rtoi here for calculating
    // localparams values, says it's not a constant function
    return (n > 0) ? int'(n-0.5) : int'(n+0.5);
endfunction

// Compute the floating-point remainder of a/b
function real fmod(real a, b);
    // No need for check equality with tolerance, division by
    // even small numbers is defined. You should chek it by
    // yourself, if required
    if (b == 0.0)
        $error("Division by zero is undefined.");
    return a - b*trunc(a/b);
endfunction

endpackage : real_computing
