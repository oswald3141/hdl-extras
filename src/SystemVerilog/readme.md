# HDL-extras (SystemVerilog)

## Library's content
- `pipelining_xilinx`: fixed delay line, addressable delay line, retiming
registers generating module.
- `real_computing`: functions for calculations with the `real` numbers.
- `sizing`: buses sizes calculating functions.
- `synchronizing_xilinx`: CDC modules (N flip-flop one-bit synchronizer, reset
synchronizer, handshake bus synchronizer).

The library does not provide `assert` header present in the Verilog
implementation. You can use `if - else $error` pattern and instead.

## Compilation
You must compile all of the library's files into the main library of your tool
(`xil_defaultlib` for Xilinx).
