# HDL-extras

## Description
This repository contains a library with the code of packets, functions,
entities, modules, and other units widely used in the various projects but not
included in the standard libraries of the hardware description languages. For
instance, primitive delay lines, CDC modules, arrays sizes calculation
functions, and definitions of array types popular in VHDL are present in the
library. You can find a more detailed description of the library's content in
"readme" files from the folders with the names corresponding to the
implementation languages names.

## Tools requirements
Most of the code presented here is probably platform-independent, and you can
use it with any synthesis tool or simulator. However, the library was tested in
Xilinx Vivado 2020.2 and ModelSim 10.6d. Therefore it can contain code
constructs aimed to mitigate these tool's bugs. These constructs, though, are
still standard-compliant, so there shouldn't be any problems with them in other
tools either.

## Languages versions
The library implementation is compliant with the following standards:
- IEEE 1364-2001 (IEEE Standard Verilog Hardware Description Language);
- IEEE 1800-2012 (IEEE Standard for SystemVerilog - Unified Hardware Design,
Specification, and Verification Language);
- IEEE 1076-2008 (IEEE Standard VHDL Language Reference Manual).

## VHDL-extras
Some parts of this library are either written with having
[VHDL-extras](https://github.com/kevinpt/vhdl-extras) in mind or directly
copied from it. There were, though, some significant changes made to it. For
example, asynchronous resets were replaced with synchronous ones, and arrays
types with `resolved` elements types were redefined as subtypes of arrays with
`unresolved` elements types.  
VHDL-extras is a large and quite helpful library. You definitely should spend
some time exploring it.

## Licensing
The code is distributed under The MIT License.  
See LICENSE for the complete license text.
