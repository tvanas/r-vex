-----------------------------------------------------------
--               rho-VEX | Testbench system
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- testbenches/tb_system.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity tb_system is
end tb_system;

architecture test of tb_system is
	component system is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       run       : in std_logic);
	end component system;

	signal clk_s   : std_logic := '0';
	signal reset_s : std_logic := '0';
	signal run_s   : std_logic := '0';
begin
	system_0 : system port map (clk_s, reset_s, run_s);

	clk_s <= not clk_s after 10 ns;

	reset_s <= '1' after 10 ns,
	           '0' after 40 ns;
	
	run_s <= '1' after 100 ns,
	         '0' after 120 ns;
end architecture test;

