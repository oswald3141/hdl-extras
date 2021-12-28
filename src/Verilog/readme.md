# HDL-extras (Verilog)

## Library's content
- `assert`: macros allowing you to detect an error and terminate the erroneous
code compilation at elaboration time.
- `packing`: macros to pack an array into a single bus and unpack it back.
- `pipelining_xilinx`: fixed delay line, addressable delay line, retiming
registers generating module.
- `real_computing`: functions for calculations with the `real` numbers.
- `sizing`: buses sizes calculating functions.
- `synchronizing_xilinx`: CDC modules (N flip-flop one-bit synchronizer, reset
synchronizer, handshake bus synchronizer).

## Compilation
You must compile all of the library's files into the main library of your tool
(`xil_defaultlib` for Xilinx).
