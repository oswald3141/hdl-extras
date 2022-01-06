-------------------------------------------------------------------------------
--# Resizeable pipeline registers
--# 
--# fixed_delay_line_* is a set of simple delay lines with different ports
--# types friedly to inferring SRL primitives. You can force the synthesis
--# synesis tool to infer a specific stype of shift registers implementation by
--# setting ATTR_SRL_STYLE parameter to something other than "auto". If you
--# don't want to constant the tool here, just leave ATTR_SRL_STYLE generic
--# constant unchanged.  Vivado 2020.2 supports the following values for this
--# attribute:
--# - register: The tool does not infer an SRL, but instead only uses
--#   registers.
--# - srl: The tool infers an SRL without any registers before or after.
--# - srl_reg: The tool infers an SRL and leaves one register after the SRL.
--# - reg_srl: The tool infers an SRL and leaves one register before the SRL.
--# - reg_srl_reg: The tool infers an SRL and leaves one register before and
--#   one register after the SRL.
--# - block: The tool infers the SRL inside a block RAM.
--# 
--# This package also provides configurable shift register components intended
--# to be used as placeholders for register retiming during synthesis
--# (pipeline_*). These components can be placed after a section of
--# combinational logic. With retiming activated in the synesis tool, the
--# flip-flops will be distributed through the combinational logic to balance
--# delays. The number of pipeline stages is controlled with the
--# PIPELINE_STAGES generic.
--# 
--# The package is implemented with taking advantage of some VHDL-2008 features
--# such as generic types and functions, unresolved numeric types, and
--# definition of the resolved types as subtypes of the unresolved ones. Due to
--# these features, the package provides components independent from data ports
--# types, so they can be used for delaying or pipelining objects of
--# user-defined types (like records and arrays) without verbose type
--# conversions.
--# 
--# The package uses unresolved ports types (std_ulogic, std_ulogic_vector,
--# unresolved_signed,unresolved_unsigned). In VHDL-2008 their resolved
--# versions are defined as their subtypes. So you can safely use the components
--# presented here with std_logic, std_logic_vector, signed and unsigned.
--# 
--# The package is optimized for use with Xilinx Vivado. Attributes used by
--# entities presented here are Vivado-specific. Other tool would just probably
--# ignore them. The package also contains workarounds for some Vivado's bugs.
--# If you intend to use the package with different synthesis tools, it would
--# be better to reimplement it.
--# 
--# EXAMPLE USAGE:
--# library work; use work.pipelining.pipeline_universal;
--# 
--# type my_record is record
--#   field_1 : u_unsigned(3 downto 0);
--#   field_2 : std_ulogic;
--# end record my_record;
--# 
--# constant EMPTY_RECORD : my_record :=
--#     (field_1 => (others => '0'), field_2 => '0');
--# ...
--# pipeline_inst : pipeline_universal
--#   generic map (
--#     ELEMENT_TYPE => my_record,
--#     RESET_ELEMENT => EMPTY_RECORD,
--#     PIPELINE_STAGES => 3,
--#     ATTR_RETIMING_BACKWARD => true,
--#     ATTR_RETIMING_FORWARD => false,
--#     RESET_ACTIVE_LEVEL => '1' )
--#   port map (Clock, Reset, sig_1, sig_2);
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

package pipelining is

  --## Pipeline registers for data of any type
  component pipeline_universal is
    generic (
  	  type ELEMENT_TYPE; --## Type of pipeline element
      RESET_ELEMENT : ELEMENT_TYPE; --## Reset pipeline element
      PIPELINE_STAGES : positive; --# Number of pipeline stages to insert
      ATTR_RETIMING_BACKWARD : boolean := true; --# Control retim. direction
      ATTR_RETIMING_FORWARD : boolean := false;
      RESET_ACTIVE_LEVEL : std_ulogic := '1' --# Synch. reset control level
    );
    port (
      --# {{clocks|}}
      Clock   : in std_ulogic; --# System clock
      Reset   : in std_ulogic; --# Synchronous reset
      --# {{data|}}
      Sig_in  : in ELEMENT_TYPE; --# Signal from block to be pipelined
      Sig_out : out ELEMENT_TYPE --# Pipelined result
    );
  end component;

  --## Pipeline registers for std_ulogic and std_logic.
  component pipeline_ul is
    generic (
      PIPELINE_STAGES : positive; --# Number of pipeline stages to insert
      ATTR_RETIMING_BACKWARD : boolean := true; --# Control retim. direction
      ATTR_RETIMING_FORWARD : boolean := false;
      RESET_ACTIVE_LEVEL : std_ulogic := '1' --# Synch. reset control level
    );
    port (
      --# {{clocks|}}
      Clock   : in std_ulogic; --# System clock
      Reset   : in std_ulogic; --# Synchronous reset
      --# {{data|}}
      Sig_in  : in std_ulogic; --# Signal from block to be pipelined
      Sig_out : out std_ulogic --# Pipelined result
    );
  end component;

  --## Pipeline registers for std_ulogic_vector and std_logic_vector.
  component pipeline_sulv is
    generic (
      PIPELINE_STAGES : positive; --# Number of pipeline stages to insert
      ATTR_RETIMING_BACKWARD : boolean := true; --# Control retim. direction
      ATTR_RETIMING_FORWARD : boolean := false;
      RESET_ACTIVE_LEVEL : std_ulogic := '1' --# Synch. reset control level
    );
    port (
      --# {{clocks|}}
      Clock   : in std_ulogic; --# System clock
      Reset   : in std_ulogic; --# Synchronous reset
      --# {{data|}}
      Sig_in  : in std_ulogic_vector; --# Signal from block to be pipelined
      Sig_out : out std_ulogic_vector --# Pipelined result
    );
  end component;

  --## Pipeline registers for unsigned.
  component pipeline_u is
    generic (
      PIPELINE_STAGES : positive; --# Number of pipeline stages to insert
      ATTR_RETIMING_BACKWARD : boolean := true; --# Control retim. direction
      ATTR_RETIMING_FORWARD : boolean := false;
      RESET_ACTIVE_LEVEL : std_ulogic := '1' --# Synch. reset control level
    );
    port (
      --# {{clocks|}}
      Clock   : in std_ulogic; --# System clock
      Reset   : in std_ulogic;
      --# {{data|}}
      Sig_in  : in u_unsigned; --# Signal from block to be pipelined
      Sig_out : out u_unsigned --# Pipelined result
    );
  end component;

  --## Pipeline registers for signed.
  component pipeline_s is
    generic (
      PIPELINE_STAGES : positive; --# Number of pipeline stages to insert
      ATTR_RETIMING_BACKWARD : boolean := true; --# Control retim. direction
      ATTR_RETIMING_FORWARD : boolean := false;
      RESET_ACTIVE_LEVEL : std_ulogic := '1' --# Synch. reset control level
    );
    port (
      --# {{clocks|}}
      Clock   : in std_ulogic; --# System clock
      Reset   : in std_ulogic; --# Synchronous reset
      --# {{data|}}
      Sig_in  : in u_signed; --# Signal from block to be pipelined
      Sig_out : out u_signed --# Pipelined result
    );
  end component;
  
  --## Fixed delay line for data of any type
  component fixed_delay_line_universal is
    generic (
	  type ELEMENT_TYPE; --# Type of the element being delayed
      STAGES : natural;  --# Number of delay stages (0 for short circuit)
      ATTR_SRL_STYLE : string := "auto" --# Style of SRL inference
      );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable : in std_ulogic;          --# Synchronous enable

      --# {{data|}}
      Data_in  : in ELEMENT_TYPE;      --# Input data
      Data_out : out ELEMENT_TYPE      --# Delayed output data
      );
  end component;
  
  --## Fixed delay line for std_ulogic data.
  component fixed_delay_line_ul is
    generic (
      STAGES : natural;  --# Number of delay stages (0 for short circuit)
      ATTR_SRL_STYLE : string := "auto" --# Style of SRL inference
      );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable : in std_ulogic;          --# Synchronous enable

      --# {{data|}}
      Data_in  : in std_ulogic;        --# Input data
      Data_out : out std_ulogic        --# Delayed output data
      );
  end component;

  --## Fixed delay line for std_ulogic_vector data.
  component fixed_delay_line_sulv is
    generic (
      STAGES : natural;  --# Number of delay stages (0 for short circuit)
      ATTR_SRL_STYLE : string := "auto" --# Style of SRL inference
      );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable : in std_ulogic;          --# Synchronous enable

      --# {{data|}}
      Data_in  : in std_ulogic_vector; --# Input data
      Data_out : out std_ulogic_vector --# Delayed output data
      );
  end component;

  --## Fixed delay line for signed data.
  component fixed_delay_line_signed is
    generic (
      STAGES : natural;  --# Number of delay stages (0 for short circuit)
      ATTR_SRL_STYLE : string := "auto" --# Style of SRL inference
      );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable : in std_ulogic;          --# Synchronous enable

      --# {{data|}}
      Data_in  : in u_signed; --# Input data
      Data_out : out u_signed --# Delayed output data
      );
  end component;

  --## Fixed delay line for unsigned data.
  component fixed_delay_line_unsigned is
    generic (
      STAGES : natural;  --# Number of delay stages (0 for short circuit)
      ATTR_SRL_STYLE : string := "auto" --# Style of SRL inference
      );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable : in std_ulogic;          --# Synchronous enable

      --# {{data|}}
      Data_in  : in u_unsigned; --# Input data
      Data_out : out u_unsigned --# Delayed output data
      );
  end component;
  
  
  --## Dynamic delay line for data of any type
  component dynamic_delay_line_universal is
    generic (
      type ELEMENT_TYPE  --# Type of the element being delayed
    );
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable  : in std_ulogic;         --# Synchronous enable
      Address : in u_unsigned;         --# Selected delay stage

      --# {{data|}}
      Data_in  : in  ELEMENT_TYPE; --# Input data
      Data_out : out ELEMENT_TYPE  --# Delayed output data
      );
  end component;
  
  --## Dynamic delay line for std_ulogic_vector data.
  component dynamic_delay_line_sulv is
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable  : in std_ulogic;         --# Synchronous enable
      Address : in u_unsigned;         --# Selected delay stage

      --# {{data|}}
      Data_in  : in std_ulogic_vector; --# Input data
      Data_out : out std_ulogic_vector --# Delayed output data
      );
  end component;

  --## Dynamic delay line for signed data.
  component dynamic_delay_line_signed is
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable  : in std_ulogic;         --# Synchronous enable
      Address : in u_unsigned;         --# Selected delay stage

      --# {{data|}}
      Data_in  : in u_signed;          --# Input data
      Data_out : out u_signed          --# Delayed output data
      );
  end component;

  --## Dynamic delay line for unsigned data.
  component dynamic_delay_line_unsigned is
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable  : in std_ulogic;         --# Synchronous enable
      Address : in u_unsigned;         --# Selected delay stage

      --# {{data|}}
      Data_in  : in u_unsigned;        --# Input data
      Data_out : out u_unsigned        --# Delayed output data
      );
  end component;
  
  --## Dynamic delay line for std_ulogic data.
  component dynamic_delay_line_ul is
    port (
      --# {{clocks|}}
      Clock : in std_ulogic;           --# System clock
      -- No reset so this can be inferred as SRL16/32

      --# {{control|}}
      Enable  : in std_ulogic;         --# Synchronous enable
      Address : in u_unsigned;         --# Selected delay stage

      --# {{data|}}
      Data_in  : in std_ulogic;        --# Input data
      Data_out : out std_ulogic        --# Delayed output data
      );
  end component;

end package;


library ieee;
use ieee.std_logic_1164.all;

entity pipeline_universal is
  generic (
	type ELEMENT_TYPE;
	RESET_ELEMENT : ELEMENT_TYPE;
    PIPELINE_STAGES : positive;
    ATTR_RETIMING_BACKWARD : boolean;
    ATTR_RETIMING_FORWARD : boolean;
    RESET_ACTIVE_LEVEL : std_ulogic := '1'
  );
  port (
    Clock   : in std_ulogic;
    Reset   : in std_ulogic;
    Sig_in  : in ELEMENT_TYPE;
    Sig_out : out ELEMENT_TYPE
  );
end entity;

architecture rtl of pipeline_universal is

  function boolean_to_integer(b : boolean) return integer is
    variable r : integer;
  begin
     r := 1 when b else 0;
    return r;
  end function boolean_to_integer;

  attribute retiming_backward : integer;
  attribute retiming_forward : integer;
  
  attribute retiming_backward of Sig_out : signal is 
    boolean_to_integer(ATTR_RETIMING_BACKWARD);
  attribute retiming_forward of Sig_out : signal is
    boolean_to_integer(ATTR_RETIMING_FORWARD);
begin

  assert (ATTR_RETIMING_BACKWARD xor ATTR_RETIMING_FORWARD) report
    "It's impossible to set both the forward and the backward retiming!"
        severity FAILURE;

  reg: process(Clock)
    type sig_word_vector is array ( natural range <> ) of ELEMENT_TYPE;
    variable pl_regs : sig_word_vector(1 to PIPELINE_STAGES);
  begin
    if rising_edge(Clock) then
      if Reset = RESET_ACTIVE_LEVEL then
        pl_regs := (others => RESET_ELEMENT);
      else
        if PIPELINE_STAGES = 1 then
          pl_regs(1) := Sig_in;
        else
          pl_regs := Sig_in & pl_regs(1 to pl_regs'high-1);
        end if;
      end if;
    end if;

    Sig_out <= pl_regs(pl_regs'high);
  end process;
end architecture;


library ieee;
use ieee.std_logic_1164.all;

entity pipeline_ul is
  generic (
    PIPELINE_STAGES : positive;
    ATTR_RETIMING_BACKWARD : boolean;
    ATTR_RETIMING_FORWARD : boolean;
    RESET_ACTIVE_LEVEL : std_ulogic := '1'
  );
  port (
    Clock   : in std_ulogic;
    Reset   : in std_ulogic;
    Sig_in  : in std_ulogic;
    Sig_out : out std_ulogic
  );
end entity;

architecture rtl of pipeline_ul is
begin
  pipeline_inst : entity work.pipeline_universal(rtl)
	generic map (
	  ELEMENT_TYPE => Sig_in'subtype,
	  RESET_ELEMENT => '0',
	  PIPELINE_STAGES => PIPELINE_STAGES,
	  ATTR_RETIMING_BACKWARD => ATTR_RETIMING_BACKWARD,
      ATTR_RETIMING_FORWARD => ATTR_RETIMING_FORWARD,
	  RESET_ACTIVE_LEVEL => RESET_ACTIVE_LEVEL)
    port map (Clock, Reset, Sig_in, Sig_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;

entity pipeline_sulv is
  generic (
    PIPELINE_STAGES : positive;
    ATTR_RETIMING_BACKWARD : boolean;
    ATTR_RETIMING_FORWARD : boolean;
    RESET_ACTIVE_LEVEL : std_ulogic := '1'
  );
  port (
    Clock   : in std_ulogic;
    Reset   : in std_ulogic;
    Sig_in  : in std_ulogic_vector;
    Sig_out : out std_ulogic_vector
  );
end entity;

architecture rtl of pipeline_sulv is
begin
  pipeline_inst : entity work.pipeline_universal(rtl)
	generic map (
	  ELEMENT_TYPE => Sig_in'subtype,
	  RESET_ELEMENT => (Sig_in'range => '0'),
	  PIPELINE_STAGES => PIPELINE_STAGES,
	  ATTR_RETIMING_BACKWARD => ATTR_RETIMING_BACKWARD,
      ATTR_RETIMING_FORWARD => ATTR_RETIMING_FORWARD,
	  RESET_ACTIVE_LEVEL => RESET_ACTIVE_LEVEL)
	port map (Clock, Reset, Sig_in, Sig_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_u is
  generic (
    PIPELINE_STAGES : positive;
    ATTR_RETIMING_BACKWARD : boolean;
    ATTR_RETIMING_FORWARD : boolean;
    RESET_ACTIVE_LEVEL : std_ulogic := '1'
  );
  port (
    Clock   : in std_ulogic;
    Reset   : in std_ulogic;
    Sig_in  : in u_unsigned;
    Sig_out : out u_unsigned
  );
end entity;

architecture rtl of pipeline_u is
  signal s1, s2 : std_ulogic_vector(Sig_out'range);
begin
  s1 <= std_ulogic_vector(Sig_in);
  pipeline_inst : entity work.pipeline_sulv(rtl)
	generic map (PIPELINE_STAGES, ATTR_RETIMING_BACKWARD, 
        ATTR_RETIMING_FORWARD, RESET_ACTIVE_LEVEL)
	port map (Clock => Clock, Reset => Reset, Sig_in => s1, Sig_out => s2);
  Sig_out <= u_unsigned(s2);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_s is
  generic (
    PIPELINE_STAGES : positive;
    ATTR_RETIMING_BACKWARD : boolean;
    ATTR_RETIMING_FORWARD : boolean;
    RESET_ACTIVE_LEVEL : std_ulogic := '1'
  );
  port (
    Clock   : in std_ulogic;
    Reset   : in std_ulogic;
    Sig_in  : in u_signed;
    Sig_out : out u_signed
  );
end entity;

architecture rtl of pipeline_s is
  signal s1, s2 : std_ulogic_vector(Sig_out'range);
begin
  s1 <= std_ulogic_vector(Sig_in);
  pipeline_inst : entity work.pipeline_sulv(rtl)
	generic map (PIPELINE_STAGES, ATTR_RETIMING_BACKWARD, 
        ATTR_RETIMING_FORWARD, RESET_ACTIVE_LEVEL)
	port map (Clock => Clock, Reset => Reset, Sig_in => s1, Sig_out => s2);
  Sig_out <= u_signed(s2);
end architecture;


library ieee;
use ieee.std_logic_1164.all;

entity fixed_delay_line_universal is
  generic (
    type ELEMENT_TYPE;
    STAGES : natural;
    ATTR_SRL_STYLE : string := "auto"
    );
  port (
    Clock : in std_ulogic;
    Enable : in std_ulogic;
    Data_in  : in ELEMENT_TYPE;
    Data_out : out ELEMENT_TYPE
    );
end entity;

architecture rtl of fixed_delay_line_universal is
  function is_style_auto(attr_gen : string) return boolean is
    constant str_auto : string := "auto";
  begin
    if attr_gen'length /= str_auto'length then
      return false;
    else
      return (attr_gen = str_auto);
    end if;
  end function;

  type elements_vector is array ( natural range <> ) of ELEMENT_TYPE;
begin

  g : if STAGES = 0 generate
    Data_out <= Data_in;
  elsif STAGES > 0 generate
    g_attr : if not is_style_auto(ATTR_SRL_STYLE) generate
      signal dly : elements_vector(0 to STAGES-1);
      attribute srl_style : string;
      attribute srl_style of dly : signal is ATTR_SRL_STYLE;
    begin
      delay: process(Clock) is
      begin
        if rising_edge(Clock) then
          if Enable = '1' then
            dly <= Data_in & dly(0 to dly'high-1);
          end if;
        end if;
      end process;
      Data_out <= dly(dly'high); 
    else generate
      signal dly : elements_vector(0 to STAGES-1);
    begin
      delay: process(Clock) is
      begin
        if rising_edge(Clock) then
          if Enable = '1' then
            dly <= Data_in & dly(0 to dly'high-1);
          end if;
        end if;
      end process;
      Data_out <= dly(dly'high); 
    end generate;
  end generate;

end architecture;


library ieee;
use ieee.std_logic_1164.all;

entity fixed_delay_line_ul is
  generic (
    STAGES : natural;
    ATTR_SRL_STYLE : string := "auto"
    );
  port (
    Clock : in std_ulogic;
    Enable : in std_ulogic;
    Data_in  : in std_ulogic;
    Data_out : out std_ulogic
    );
end entity;

architecture rtl of fixed_delay_line_ul is
begin
  dl_inst : entity work.fixed_delay_line_universal(rtl)
    generic map (
      ELEMENT_TYPE => Data_in'subtype,
      STAGES => STAGES,
      ATTR_SRL_STYLE => ATTR_SRL_STYLE)
	port map (Clock, Enable, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;

entity fixed_delay_line_sulv is
  generic (
    STAGES : natural;
    ATTR_SRL_STYLE : string := "auto"
    );
  port (
    Clock : in std_ulogic;
    Enable : in std_ulogic;
    Data_in  : in std_ulogic_vector;
    Data_out : out std_ulogic_vector
    );
end entity;

architecture rtl of fixed_delay_line_sulv is
begin
  dl_inst : entity work.fixed_delay_line_universal(rtl)
    generic map (
      ELEMENT_TYPE => Data_in'subtype,
      STAGES => STAGES,
      ATTR_SRL_STYLE => ATTR_SRL_STYLE)
	port map (Clock, Enable, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fixed_delay_line_signed is
  generic (
    STAGES : natural;
    ATTR_SRL_STYLE : string := "auto"
    );
  port (
    Clock : in std_ulogic;
    Enable : in std_ulogic;
    Data_in  : in u_signed;
    Data_out : out u_signed
    );
end entity;

architecture rtl of fixed_delay_line_signed is
begin
  dl_inst : entity work.fixed_delay_line_universal(rtl)
    generic map (
      ELEMENT_TYPE => Data_in'subtype,
      STAGES => STAGES,
      ATTR_SRL_STYLE => ATTR_SRL_STYLE)
	port map (Clock, Enable, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fixed_delay_line_unsigned is
  generic (
    STAGES : natural;
    ATTR_SRL_STYLE : string := "auto"
    );
  port (
    Clock : in std_ulogic;
    Enable : in std_ulogic;
    Data_in  : in u_unsigned;
    Data_out : out u_unsigned
    );
end entity;

architecture rtl of fixed_delay_line_unsigned is
begin
  dl_inst : entity work.fixed_delay_line_universal(rtl)
    generic map (
      ELEMENT_TYPE => Data_in'subtype,
      STAGES => STAGES,
      ATTR_SRL_STYLE => ATTR_SRL_STYLE)
	port map (Clock, Enable, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dynamic_delay_line_universal is
  generic (
    type ELEMENT_TYPE
  );
  port (
    Clock : in std_ulogic;
    Enable  : in std_ulogic;
    Address : in u_unsigned;
    Data_in  : in ELEMENT_TYPE;
    Data_out : out ELEMENT_TYPE
    );
end entity;

architecture rtl of dynamic_delay_line_universal is
  constant STAGES : positive := 2**Address'length;
  type word_array is array(natural range <>) of ELEMENT_TYPE;

  signal dly : word_array(0 to STAGES-1);
begin

  delay: process(Clock) is
  begin
    if rising_edge(Clock) then
      if Enable= '1' then
        dly <= Data_in & dly(0 to dly'high-1);
      end if;
    end if;
  end process;

  Data_out <= dly(to_integer(Address));
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dynamic_delay_line_sulv is
  port (
    Clock : in std_ulogic;
    Enable  : in std_ulogic;
    Address : in u_unsigned;
    Data_in  : in std_ulogic_vector;
    Data_out : out std_ulogic_vector
    );
end entity;

architecture rtl of dynamic_delay_line_sulv is
begin
  ddl_inst : entity work.dynamic_delay_line_universal(rtl)
    generic map (ELEMENT_TYPE => Data_in'subtype)
    port map (Clock, Enable, Address, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dynamic_delay_line_signed is
  port (
    Clock : in std_ulogic;
    Enable  : in std_ulogic;
    Address : in u_unsigned;
    Data_in  : in u_signed;
    Data_out : out u_signed
    );
end entity;

architecture rtl of dynamic_delay_line_signed is
begin
  ddl_inst : entity work.dynamic_delay_line_universal(rtl)
    generic map (ELEMENT_TYPE => Data_in'subtype)
    port map (Clock, Enable, Address, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dynamic_delay_line_unsigned is
  port (
    Clock : in std_ulogic;
    Enable  : in std_ulogic;
    Address : in u_unsigned;
    Data_in  : in u_unsigned;
    Data_out : out u_unsigned
    );
end entity;

architecture rtl of dynamic_delay_line_unsigned is
begin
  ddl_inst : entity work.dynamic_delay_line_universal(rtl)
    generic map (ELEMENT_TYPE => Data_in'subtype)
    port map (Clock, Enable, Address, Data_in, Data_out);
end architecture;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dynamic_delay_line_ul is
  port (
    Clock : in std_ulogic;
    Enable  : in std_ulogic;
    Address : in u_unsigned;
    Data_in  : in std_ulogic;
    Data_out : out std_ulogic
    );
end entity;

architecture rtl of dynamic_delay_line_ul is
begin
  ddl_inst : entity work.dynamic_delay_line_universal(rtl)
    generic map (ELEMENT_TYPE => Data_in'subtype)
    port map (Clock, Enable, Address, Data_in, Data_out);
end architecture;
