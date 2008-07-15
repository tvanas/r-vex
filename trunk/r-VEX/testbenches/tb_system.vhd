-----------------------------------------------------------
--               rho-VEX | Testbench system
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- tb_system.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity tb_system is
end tb_system;

architecture test of tb_system is
	component system is
		port ( clk       : in std_logic;
		       reset     : in std_logic;

		       tx        : out std_logic);
	end component system;

	signal tx_s        : std_logic := '0';
	signal clk_s       : std_logic := '0';
	signal reset_s     : std_logic := '0';
begin
	system_0 : system port map (clk => clk_s,
	                            reset => reset_s,
				    
	                            tx => tx_s);

	clk_s <= not clk_s after 10 ns;

	reset_s <= not ACTIVE_LOW after 10 ns,
               ACTIVE_LOW     after 50 ns;
end architecture test;

