--------------------------------------------------------------------------------
-- r-VEX | Clock divider
--------------------------------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-- Computer Engineering Laboratory
-- Faculty of Electrical Engineering, Mathematics and Computer Science
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
--------------------------------------------------------------------------------
-- Used because to meet timing constraints
--------------------------------------------------------------------------------
-- clk_div.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
	port ( clk : in std_logic;       -- system clock

	       clk_out : out std_logic); -- output clock (0.5 * clk freq)
end clk_div;


architecture behavioral of clk_div is
	signal clk_s   : std_logic := '0';
begin
	clk_out <= clk_s;

	clock_divider : process(clk)
	begin
		if (clk = '1' and clk'event) then
			clk_s <= not clk_s;
		end if;
	end process;
end behavioral;

