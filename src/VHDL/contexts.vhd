-------------------------------------------------------------------------------
--# Context importing the entire hdl_extras library
--#
--# This piece of code is tool-independent.
--#
--# The code is distributed under The MIT License
--# Copyright (c) 2021 Andrey Smolyakov
--#     (andreismolyakow 'at' gmail 'punto' com)
--# See LICENSE for the complete license text
-------------------------------------------------------------------------------

--## All of the library's packages
context entire_lib is
  library hdl_extras;
  use hdl_extras.common_types.all;
  use hdl_extras.complex.all;
  use hdl_extras.numeric_std_resizing.all;
  use hdl_extras.packing_common.all;
  use hdl_extras.pipelining.all;
  use hdl_extras.sizing.all;
  use hdl_extras.synchronizing.all;
end context;

--## Types definitios and type conversion functions
--#  (including packing functions)
context types is
  library hdl_extras;
  
  -- Common types
  use hdl_extras.common_types.all;
  use hdl_extras.packing_common.all;
  
  -- Signed complex number type
  use hdl_extras.complex.u_complex;
  use hdl_extras.complex.complex;
  use hdl_extras.complex.u_complex_array;
  use hdl_extras.complex.packed_length;
  use hdl_extras.complex.to_sulv;
  use hdl_extras.complex.from_sulv;
  
  -- Not available in the current version.
  -- See complex.vhd for the further details.
  -- use hdl_extras.complex_array;
end context;
