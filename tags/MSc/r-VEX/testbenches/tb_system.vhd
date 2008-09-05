-------------------------------------------------------------------------------
-- r-VEX | Testbench system
-------------------------------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-- Computer Engineering Laboratory
-- Delft University of Technology
-- Delft, The Netherlands
--
-- http://r-vex.googlecode.com
--
-- r-VEX is free hardware: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-------------------------------------------------------------------------------
-- tb_system.vhd
-------------------------------------------------------------------------------

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

