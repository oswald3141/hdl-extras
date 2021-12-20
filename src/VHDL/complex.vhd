-------------------------------------------------------------------------------
--# Synthesisable package describing a signed complex number
--# 
--# The package is tool-independent. However, it may contain workarounds
--# mitigating specific Vivado bugs.
--# 
--# Represents complex numbers in the Cartesian form. Doesn't provide
--# multiplication operator overload due to the complexity of this operation.
--# One had better write a separate entity for that.
--# 
--# The package also provides the definition of array of complex numbers.
--# Additionaly, there are packing/unpacking and resizing functions simillar to
--# ones defined in numeric_std_resizing and packing_common.
--#
--# The code is distributed under The MIT License
--# Copyright (c) 2021 Andrey Smolyakov
--#     (andreismolyakow 'at' gmail 'punto' com)
--# See LICENSE for the complete license text
-------------------------------------------------------------------------------

library IEEE;
context ieee.ieee_std_context;

library hdl_extras;
use hdl_extras.numeric_std_resizing.all;
use hdl_extras.common_types.all;
use hdl_extras.packing_common.all;

package complex is

  --## Unresolved signed complex number.
  type u_complex is record
   re : u_signed;
   im : u_signed;
  end record;
  
  --## Array of unresolved signed complex numbers.
  type u_complex_array is array (natural range <>) of u_complex;
  
  --## Resolved signed complex number.
  subtype complex is (re(resolved), im(resolved)) u_complex;
  
  --## Array of resolved signed complex numbers.
  --#  This is a valid VHDL-2008 syntax, it successfully compiles in ModelSim
  --#  without producing any errors or warnings. But it breaks Vivado 2020.2.
  --#  So it is commented out for now.
  --subtype complex_array is ((re(resolved), im(resolved))) u_complex_array;
  
  --## Adds two complex numbers. Result width: maximum(L'length, R'length)
  --# Args:
  --#  L: Summand 1
  --#  R: Summand 2
  --# Returns:
  --#  Sum.
  function "+"(L, R : u_complex) return u_complex;
  
  --## Subtracts one complex number from the other. Result width:
  --#  maximum(L'length, R'length)
  --# Args:
  --#  L: Minuend
  --#  R: Subtrahend
  --# Returns:
  --#  Difference.
  function "-"(L, R : u_complex) return u_complex;


  --## Resize complex number clearly stating how exactly the components
  --#  resizing will be done. Extends most significant bits of components
  --#  with their sign bits, and least significant bits with zeros.
  --#
  --# Args:
  --#   s : Number to resize
  --#   new_size: New components size
  --#   method: Resizizng method
  --# Returns:
  --#   Complex number with resized components.
  alias resize_method is resize_method;
  function resize_explicit(s        : u_complex;
                           new_size : positive;
                           method   : resize_method) return u_complex;
  
  --## Compute the size of a packed complex number.
  --#
  --# Args:
  --#   n: Number to be packed.
  --# Returns:
  --#   Number of bits in a vector yielded by the packing function. 
  function packed_length(n : u_complex) return natural;
  
  --## Pack a complex number into a single std_ulogic_vector.
  --#
  --# Args:
  --#   n : Number to be packed.
  --# Returns:
  --#   Vector with number's bits.  
  function to_sulv(n : u_complex) return std_ulogic_vector;
  
  --## Unpack a complex number from a signle std_ulogic_vector.
  --#
  --# Args:
  --#   s: Vector to be unpacked
  --# Returns:
  --#   Unpacked complex number.
  function from_sulv(s : std_ulogic_vector) return u_complex;
  
  --## Compute the size of a packed complex numbers array.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Number of bits in a vector yielded by the packing function.  
  function packed_length(a : u_complex_array) return natural;
  
  --## Pack a complex numbers array into a single std_ulogic_vector.
  --#
  --# Args:
  --#   a: Array to be packed.
  --# Returns:
  --#   Vector with array bits.  
  function to_sulv(a : u_complex_array) return std_ulogic_vector;
  
  --## Unpack a complex numbers array from a signle std_ulogic_vector.
  --#
  --# Args:
  --#   s: Vector to be unpacked
  --#   n: Number of array elements in the vector
  --# Returns:
  --#   Unpacked array.  
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return u_complex_array;

  
  --## Fixed delay line for a complex number
  component fixed_delay_line_complex is
    generic (
      STAGES : natural  --# Number of delay stages (0 for short circuit)
    );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;   --# System clock
      -- No reset so this can be inferred as SRL16/32
      
      --# {{control|}}
      Enable : in std_ulogic;  --# Synchronous enable
      
      --# {{data|}}
      Data_in  : in u_complex; --# Input data
      Data_out : out u_complex --# Delayed output data
    );
  end component;

end package complex;

package body complex is

  function "+"(L, R : u_complex) return u_complex is
    constant RES_W : positive := maximum(L.re'length, R.re'length);
    variable res : u_complex(re(RES_W-1 downto 0), im(RES_W-1 downto 0));
  begin
    res := ( 
        re => L.re + R.re,
        im => L.im + R.im
    );
    return res;
  end function;
  
  function "-"(L, R : u_complex) return u_complex is
    constant RES_W : positive := maximum(L.re'length, R.re'length);
    variable res : u_complex(re(RES_W-1 downto 0), im(RES_W-1 downto 0));
  begin
    res := ( 
        re => L.re - R.re,
        im => L.im - R.im
    );
    return res;
  end function;
  
  function resize_explicit(s : u_complex;
                           new_size : positive;
                           method : resize_method) return u_complex is
    variable v : u_complex(re(new_size-1 downto 0), im(new_size-1 downto 0));
  begin
    v.re := resize_explicit(s.re, new_size, method);
    v.im := resize_explicit(s.im, new_size, method);
    return v;
  end function;

  function packed_length(n : u_complex) return natural is
  begin
    return n.re'length + n.im'length;
  end function;

  function to_sulv(n : u_complex) return std_ulogic_vector is
  begin
      return std_ulogic_vector(n.im) & std_ulogic_vector(n.re);
  end function;
  
  function from_sulv(s : std_ulogic_vector) return u_complex is
      constant COMP_LENGTH : positive := s'length/2;
      subtype comp_range is natural range COMP_LENGTH-1 downto 0;
      variable v : u_complex(re(comp_range), im(comp_range));
  begin
      v.im := u_signed(s(s'high downto s'low+COMP_LENGTH));
      v.re := u_signed(s(s'low+COMP_LENGTH-1 downto s'low));
      return v;
  end function;
  
  function to_sulv_array(a : u_complex_array) return sulv_array is
    subtype packed_range is natural range packed_length(a)-1 downto 0;
    variable sa : sulv_array(a'range)(packed_range);
  begin
    for i in a'range loop
      sa(i) := to_sulv(a(i));
    end loop;
    return sa;
  end function;
  
  function from_sulv_array(sa : sulv_array) return u_complex_array is
    subtype unpacked_range is natural range sa'element'length/2-1 downto 0;
    variable ca : u_complex_array(sa'range)
                    (re(unpacked_range), im(unpacked_range));
  begin
    for i in sa'range loop
      ca(i) := from_sulv(sa(i));
    end loop;
    return ca;
  end function;
  
  function packed_length(a : u_complex_array) return natural is
  begin
    return packed_length(to_sulv_array(a));
  end function;
  
  function to_sulv(a : u_complex_array) return std_ulogic_vector is
  begin
    return to_sulv(to_sulv_array(a));
  end function to_sulv;
  
  function from_sulv(s : std_ulogic_vector;
                     n : positive) return u_complex_array is
    constant sa : sulv_array := from_sulv(s,n); 
  begin
    return from_sulv_array(sa);
  end function;

end package body complex;


-- Cannot fixed_delay_line_universal
-- here due to a Vivado bug
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.complex.all;

entity fixed_delay_line_complex is
  generic (
    STAGES : natural
  );
  port (
    Clock : in std_ulogic;
    Enable : in std_ulogic;
    Data_in  : in u_complex;
    Data_out : out u_complex
  );
end entity;

architecture rtl of fixed_delay_line_complex is
  signal dly : u_complex_array(0 to STAGES-1)
    (re(Data_in.re'range), im(Data_in.im'range));
begin
  g : if STAGES = 0 generate
    Data_out <= Data_in;
  elsif STAGES > 0 generate
    delay: process(Clock) is
    begin
      if rising_edge(Clock) then
        if Enable = '1' then
          dly <= Data_in & dly(0 to dly'high-1);
        end if;
      end if;
    end process;
    Data_out <= dly(dly'high);
  end generate g;
end architecture rtl;
