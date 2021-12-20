-------------------------------------------------------------------------------
--# Functions to change vectors and numbers sizes
--#
--# The package is tool-independent. However, it may contain workarounds
--# mitigating specific Vivado bugs.
--#
--# The package provides functions for vectors resizing with
--# interfaces which show clearly how resizing should be performed (extending
--# or truncating, from the left or from the right).
--# 
--# The package implies, that the numbers ranges are defined with "downto".
--# The bit with the highest index is considered to be the most significant.
--#
--# The package uses unresolved ports types (std_ulogic, std_ulogic_vector,
--# unresolved_signed,unresolved_unsigned). In VHDL-2008 their resolved
--# versions are defined as their subtypes. So you can safely use the functions
--# presented here with std_logic, std_logic_vector, signed and unsigned.
--#
--# The code is distributed under The MIT License
--# Copyright (c) 2021 Andrey Smolyakov
--#     (andreismolyakow 'at' gmail 'punto' com)
--# See LICENSE for the complete license text
-------------------------------------------------------------------------------

library ieee;
context ieee.ieee_std_context;

package numeric_std_resizing is
  --#  Defines how exactly the resizing should be done
  type resize_method is (truncate_LSBs, truncate_MSBs, extend_LSB, extend_MSB);
    
  --## Resizizng function for unsigned number clearly stating how exactly the 
  --#  resizing will be done. Extends numbers with zeros.
  --#
  --# Args:
  --#   s : Vector to resize
  --#   new_size : New vector size
  --#   method : Resizizng method
  --# Returns:
  --#   Resized number.
  function resize_explicit (s        : u_unsigned;
                            new_size : positive;
                            method   : resize_method) return u_unsigned;
    
  --## Resizizng function for signed number clearly stating how exactly the 
  --#  resizing will be done. Extends most significant bits with a sign bit,
  --#  and least significant bits with zeros.
  --#
  --# Args:
  --#   s : Vector to resize
  --#   new_size : New vector size
  --#   method : Resizizng method
  --# Returns:
  --#   Resized number.
  function resize_explicit (s        : u_signed;
                            new_size : positive;
                            method   : resize_method) return u_signed;
end package;


package body numeric_std_resizing is

  --## Resizizng function for std_ulogic_vector clearly stating how exactly the 
  --#  resizing will be done.
  function resize_explicit (s         : std_ulogic_vector;
                            new_size  : positive;
                            method    : resize_method;
                            extension : std_ulogic := '0')
                            return std_ulogic_vector is

    variable v : std_ulogic_vector(new_size-1 downto 0);
  begin
    case method is
      when truncate_LSBs =>
        return s( s'left downto (s'left + 1 - new_size) );
      when truncate_MSBs =>
        return s( (s'right + new_size -1) downto s'right);
      when extend_LSB   =>
        v(v'high downto new_size - s'length) := s;
        v(new_size - s'length - 1 downto 0) := (others => extension);
        return v;
      when extend_MSB   =>
        v(new_size-1 downto s'high+1) := (others => extension);
        v(s'high downto 0) := s;
        return v;
    end case;
  end function;
  
  --## Resizizng function for unsigned number clearly stating how exactly the 
  --# resizing will be done. Extends numbers with zeros.
  function resize_explicit (s        : u_unsigned;
                            new_size : positive;
                            method   : resize_method) return u_unsigned is
  begin
    assert not s'ascending report "The package implies that the number range" &
        " is defined with downto!" severity FAILURE;
    return u_unsigned(
      resize_explicit(std_ulogic_vector(s), new_size, method, '0'));
  end function;
  
  --## Resizizng function for signed number clearly stating how exactly the 
  --# resizing will be done. Extends most significant bits with a sign bit,
  --# and least significant bits with zeros.
  function resize_explicit (s : u_signed;
                            new_size : positive;
                            method : resize_method) return u_signed is
  begin
    assert not s'ascending report "The package implies that the number range" &
      " is defined with downto!" severity FAILURE;
  
    case method is
      when extend_MSB   =>
        return u_signed(
          resize_explicit(std_ulogic_vector(s), new_size, method, s(s'high)));
      when others =>
        return u_signed(
          resize_explicit(std_ulogic_vector(s), new_size, method, '0'));
    end case;
  end function;
    
end package body;
