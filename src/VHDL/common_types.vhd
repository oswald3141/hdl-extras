-------------------------------------------------------------------------------
--# Common data types shared across VHDL-2008 components
--#
--# The package is tool-independent. However, it may contain workarounds
--# mitigating specific Vivado bugs.
--# 
--# This is a set of common types defining unconstrained arrays of IEEE types.
--# It provides a common set of types and conversion functions that can be used
--# to interoperate between different design units that need to make use of
--# fully unconstrained types.
--# 
--# The package directly defines the following types:
--#   - array of std_ulogic_vector (sulv_array),
--#   - array of unresolved_signed (u_signed_array),
--#   - array of unresolved_unsigned (u_unsigned_array. 
--# The package also defines the following types
--#   - array of std_logic_vector (slv_array),
--#   - array of signed (signed_array),
--#   - array of unsigned (unsigned_array)
--# as resolved subtypes of corresponding arrays types defined directly. Thanks
--# to that you can use any function/procedure/entity port/etc. defined as
--# array of unresolved elements with arrays of resolved elements. No type
--# conversion required in such cases.
--#
--# Since the types defined here are closely related (see 9.3.6 in LRM), you
--# can convert between them using regular VHDL type conversion:
--#   constant c : sulv_array(0 to 1)(2 downto 0) := ("000", "010");
--#   signal s : u_signed_array(c'range)(c'element'range);
--#   ...
--#   s <= u_signed_array(c); -- Regular type conversion
--# However, in some contexts it blows Vivado's poor mind and causes an
--# elaboration-time error. You can use explicit type conversion functions
--# presented here to mitigate such errors:
--#   s <= to_u_signed_array(c); -- Type conversion via explicit func.
--# 
--# The code presented here is either inspired by VHDL-extras library or
--# directly copied from it.
--# https://github.com/kevinpt/vhdl-extras
--#
--# The code is distributed under The MIT License
--# Copyright (c) 2021 Andrey Smolyakov
--#     (andreismolyakow 'at' gmail 'punto' com)
--# Copyright (c) 2010 Kevin Thibedeau
--#     (kevin 'period' thibedeau 'at' gmail 'punto' com)
--# See LICENSE for the complete license text
-------------------------------------------------------------------------------

library ieee;
context ieee.ieee_std_context;

package common_types is

  --## Array of std_ulogic_vector.
  type sulv_array is array(natural range <>) of std_ulogic_vector;

  --## Array of unresolved_signed.
  type u_signed_array   is array(natural range <>) of u_signed;

  --## Array of unresolved_unsigned.
  type u_unsigned_array is array(natural range <>) of u_unsigned;
  
   --## Basically, an array of std_logic_vector.
  subtype slv_array is ((resolved)) sulv_array;
  
  --## Basically, an array of signed.
  subtype signed_array is ((resolved)) u_signed_array;
  
  --## Basically, an array of unsigned.
  subtype unsigned_array is ((resolved)) u_unsigned_array;
  
  --## Convert signed array to std_ulogic_vector array.
  --# Args:
  --#  A: Array to convert
  --# Returns:
  --#  Array with new type.
  function to_sulv_array(A : u_signed_array) return sulv_array;
  
  --## Convert unsigned array to std_ulogic_vector array.
  --# Args:
  --#  A: Array to convert
  --# Returns:
  --#  Array with new type.
  function to_sulv_array(A : u_unsigned_array) return sulv_array;

  --## Convert std_ulogic_vector array to signed array.
  --# Args:
  --#  A: Array to convert
  --# Returns:
  --#  Array with new type.
  function to_u_signed_array(A : sulv_array) return u_signed_array;
  
  --## Convert unsigned array to signed array.
  --# Args:
  --#  A: Array to convert
  --# Returns:
  --#  Array with new type.  
  function to_u_signed_array(A : u_unsigned_array) return u_signed_array;
  
  --## Convert std_ulogic_vector array to unsigned array.
  --# Args:
  --#  A: Array to convert
  --# Returns:
  --#  Array with new type.  
  function to_u_unsigned_array(A : sulv_array) return u_unsigned_array;
  
  --## Convert signed array to unsigned array.
  --# Args:
  --#  A: Array to convert
  --# Returns:
  --#  Array with new type.  
  function to_u_unsigned_array(A : u_signed_array) return u_unsigned_array;

end package;

package body common_types is

  function to_sulv_array(a : u_signed_array) return sulv_array is
    variable r : sulv_array(a'range)(a'element'range);
  begin
    for i in a'range loop
      r(i) := std_ulogic_vector(a(i));
    end loop;
    return r;
  end function;

  function to_sulv_array(a : u_unsigned_array) return sulv_array is
    variable r : sulv_array(a'range)(a'element'range);
  begin
    for i in a'range loop
      r(i) := std_ulogic_vector(a(i));
    end loop;
    return r;
  end function;

  function to_u_signed_array(A : sulv_array) return u_signed_array is
    variable r : u_signed_array(a'range)(a'element'range);
  begin
    for i in a'range loop
      r(i) := u_signed(a(i));
    end loop;
    return r;
  end function;

  function to_u_signed_array(A : u_unsigned_array) return u_signed_array is
    variable r : u_signed_array(a'range)(a'element'range);
  begin
    for i in a'range loop
      r(i) := u_signed(a(i));
    end loop;
    return r;
  end function;

  function to_u_unsigned_array(A : sulv_array) return u_unsigned_array is
    variable r : u_unsigned_array(a'range)(a'element'range);
  begin
    for i in a'range loop
      r(i) := u_unsigned(a(i));
    end loop;
    return r;
  end function;
  
  function to_u_unsigned_array(A : u_signed_array) return u_unsigned_array is
    variable r : u_unsigned_array(a'range)(a'element'range);
  begin
    for i in a'range loop
      r(i) := u_unsigned(a(i));
    end loop;
    return r;
  end function;

end package body;
