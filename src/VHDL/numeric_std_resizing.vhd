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
--# The package considers the most significant bit to be the leftmost.
--#
--# The package uses unresolved numbers types (unresolved_signed, 
--# unresolved_unsigned). In VHDL-2008 their resolved versions are defined as
--# their subtypes. So you can safely use the functions presented here with
--# signed and unsigned too.
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

    variable v : std_ulogic_vector(s'high downto s'low); -- var to resize
    variable r : std_ulogic_vector(new_size-1 downto 0); -- result
    
    alias sr : std_ulogic_vector(s'reverse_range) is s;
    alias rr : std_ulogic_vector(r'reverse_range) is r;
  begin
    -- v'range is downto regardless of s'range
    v := sr when s'ascending else s;
  
    case method is
      when truncate_LSBs =>
        r := v( v'left downto (v'left - (new_size - 1)) );
      when truncate_MSBs =>
        r := v( (v'right + (new_size - 1)) downto v'right);
      when extend_LSB   =>
        r(r'left downto (new_size - v'length)) := v;
        r(r'left - v'length downto 0) := (others => extension);
      when extend_MSB   =>
        r(r'left downto v'length) := (others => extension);
        r(v'length-1 downto 0) := v;
    end case;
    
    -- Choose the same range as input
    if s'ascending then
        return rr;
    else 
        return r;
    end if;
  end function;
  
  --## Resizizng function for unsigned number clearly stating how exactly the 
  --# resizing will be done. Extends numbers with zeros.
  function resize_explicit (s        : u_unsigned;
                            new_size : positive;
                            method   : resize_method) return u_unsigned is
  begin
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
    case method is
      when extend_MSB   =>
        return u_signed(
          resize_explicit(std_ulogic_vector(s), new_size, method, s(s'left)));
      when others =>
        return u_signed(
          resize_explicit(std_ulogic_vector(s), new_size, method, '0'));
    end case;
  end function;
    
end package body;
