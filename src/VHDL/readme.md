# HDL-extras (VHDL)

## Library's content
- `common_types`: contains the definitions of array types with elements of 
`std_ulogic_vector`, `unresolved_signed`, and `unresolved_unsigned` types, and
with their `resolved` versions (`std_logic_vector`, `signed`, and `unsigned`).
It also provides functions for converting these types into each other.
- `complex`: describes a complex signed number represented in the Cartesian
form.
- `contexts`: contexts for a quick including of the different library parts.
- `numeric_std_resizing`: functions for resizing numbers of typed defined in
`IEEE.NUMERIC_STD`. Allow one to state which bits exactly should be truncated/
extended explicitly.
- `packing_common`: functions to convert arrays of types defined in
`common_types` into a single `std_ulogic_vector` and back. Helpful for passing
data into a design in a foreign language.
- `pipelining_xilinx`: fixed delay line, addressable delay line, retiming
registers generating module.
- `sizing`: buses sizes calculating functions.
- `synchronizing_xilinx`: CDC modules (N flip-flop one-bit synchronizer, reset
synchronizer, handshake bus synchronizer).

## Compilation
You must compile all of the library's files into the library with
`hdl_extras` name, and not into the main tool's library
(`xil_defaultlib` for Xilinx).
