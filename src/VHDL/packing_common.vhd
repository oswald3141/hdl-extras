-------------------------------------------------------------------------------
--# Functions to pack arrays into std_ulogic_vector and to unpack them back
--# 
--# The package is tool-independent. However, it may contain workarounds
--# mitigating specific Vivado bugs.
--# 
--# This package provides functions allowing you to convert an array into a
--# single std_ulogic_vector. It may be convinient, for example, when
--# interoperating with code written in Verilog or SystemVerilog, IP cores or
--# other libraries.
--# 
--# It's a bad idea to use this functions for transfering data between VHDL
--# entities in the same project. Converting arrays and other user-defined
--# types into sulvs leaves VHDL type-checker useless: it's impossible to
--# determine what you put into sulv, and therefore it's also impossible to
--# check whether the back conversion was correct or not. For the same reason
--# from_sulv functions defined here can't check if the back conversion you ask
--# for correct. So be careful with them.
--# Generally, it's advisable to call "from_sulv" only for vectors that have
--# been initially assigned by calling "to_sulv" and only with return type
--# being the same as the input type of to_sulv. In any other case, pay special
--# attention to the type correctness of your conversion.
--# 
--# Functions presented here are defined for unresolved arrays types only.
--# However, due to the fact that common package defines arrays with resolved
--# elements types as subtypes of arrays with unresolved elements types, you
--# can use functions from this package for any type of array defined in common
--# package without explicit type conversions.
--# Also remember, that std_logic_vector is a subtype of std_ulogic_vector. So
--# you can safely put sulv's resulted from this package into slv's, or to pass
--# into function defined here slv's instead of sulv's.
--#
--# The code is distributed under The MIT License
--# Copyright (c) 2021 Andrey Smolyakov
--#     (andreismolyakow 'at' gmail 'punto' com)
--# See LICENSE for the complete license text
-------------------------------------------------------------------------------

library ieee;
context ieee.ieee_std_context;

library hdl_extras;
use hdl_extras.common_types.all;

package packing_common is

  --## Pack an std_ulogic_vector array into a single std_ulogic_vector.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Vector with array bits.
  function to_sulv(a : sulv_array) return std_ulogic_vector;
  
  --## Pack an unsigned array into a single std_ulogic_vector.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Vector with array bits.
  function to_sulv(a : u_unsigned_array) return std_ulogic_vector;
  
  --## Pack a signed array into a single std_ulogic_vector.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Vector with array bits.
  function to_sulv(a : u_signed_array) return std_ulogic_vector;
  
  
  --## Unpack an std_ulogic_vector array from a signle std_ulogic_vector.
  --#
  --# Args:
  --#   s: Vector to be unpacked
  --#   n: Number of array elements in the vector
  --# Returns:
  --#   Unpacked array.
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return sulv_array;
  
  --## Unpack an unsigned array from a signle std_ulogic_vector.
  --#
  --# Args:
  --#   s: Vector to be unpacked
  --#   n: Number of array elements in the vector
  --# Returns:
  --#   Unpacked array.
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return u_unsigned_array;
  
  --## Unpack a signed array from a signle std_ulogic_vector.
  --#
  --# Args:
  --#   s: Vector to be unpacked
  --#   n: Number of array elements in the vector
  --# Returns:
  --#   Unpacked array.
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return u_signed_array;
  
  
  --## Compute the size of a packed std_ulogic_vector array.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Number of bits in a vector yielded by the packing function.
  function packed_length(a : sulv_array) return natural;
  
  --## Compute the size of a packed unsigned array.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Number of bits in a vector yielded by the packing function.
  function packed_length(a : u_unsigned_array) return natural;
  
  --## Compute the size of a packed signed array.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Number of bits in a vector yielded by the packing function.
  function packed_length(a : u_signed_array) return natural;
  
end package;

package body packing_common is

  function packed_length(a : sulv_array) return natural is
  begin
    return (a'length)*(a'element'length);
  end function;
  
  function to_sulv(a : sulv_array) return std_ulogic_vector is
    constant ELEM_LENGTH : natural := a'element'length;
    constant PCKD_LENGTH : natural := packed_length(a);
    variable sulv : std_ulogic_vector(PCKD_LENGTH-1 downto 0);
  begin
    for i in a'range loop
      sulv((i+1)*ELEM_LENGTH-1 downto i*ELEM_LENGTH) := a(i);
    end loop;
    return sulv;
  end function;
  
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return sulv_array is
    constant ELEM_LENGTH : natural := s'length/n;
    variable a : sulv_array(0 to n-1)(ELEM_LENGTH-1 downto 0);
  begin
    for i in a'range loop
      a(i) := s(s'low + (i+1)*ELEM_LENGTH-1 downto s'low + i*ELEM_LENGTH);
    end loop;
    return a;
  end function;
  
  
  function packed_length(a : u_unsigned_array) return natural is
  begin
    return packed_length(to_sulv_array(a));
  end function;
  
  function packed_length(a : u_signed_array) return natural is
  begin
    return packed_length(to_sulv_array(a));
  end function;
  
  
  function to_sulv(a : u_unsigned_array) return std_ulogic_vector is
  begin
    return to_sulv(to_sulv_array(a));
  end function;
  
  function to_sulv(a : u_signed_array) return std_ulogic_vector is
  begin
    return to_sulv(to_sulv_array(a));
  end function;
  
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return u_unsigned_array is
    constant a : sulv_array := from_sulv(s,n);
  begin
    return to_u_unsigned_array(a);
  end function;
  
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return u_signed_array is
    constant a : sulv_array := from_sulv(s,n);
  begin
     -- Vivado's bug. Cannot use regular type conversion here,
     -- have to go with explicit function
    return to_u_signed_array(a);
  end function;

end package body;
