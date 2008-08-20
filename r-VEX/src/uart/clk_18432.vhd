--------------------------------------------------------------------------------
-- UART | 1.8432 MHz Clock Generator
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
-- Input:      clk        | System clock
--             reset      | System reset
--
-- Output:     clk_18432  | 1.8432 MHz clock
--------------------------------------------------------------------------------
-- Generates a 1.8432 MHz clock signal from a 50 MHz input
-- clock signal. From this signal, 115200 bps baud ticks
-- can be easily generated (divide by 16)
--
-- 50 MHz * 1152/15625 = 3.6864 MHz (high/low switching
-- frequency)
--------------------------------------------------------------------------------
-- clk_18432.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity clk_18432 is
	port ( clk       : in std_logic;
	       reset     : in std_logic;

	       clk_18432 : out std_logic );
end clk_18432;

architecture behavioural of clk_18432 is
	constant NUMERATOR   : std_logic_vector(14 downto 0) := "000010010000000"; --  1152;
	constant DENOMINATOR : std_logic_vector(14 downto 0) := "011110100001001"; -- 15625;

	signal clk_out : std_logic := '0';
	signal counter : std_logic_vector(14 downto 0) := (others => '0');
begin

clk_18432 <= clk_out;

process (clk, reset)
begin
	if (reset = '1') then
		clk_out <= '1';
		counter <= DENOMINATOR - NUMERATOR - 1;
	elsif (clk = '1' and clk'event) then
		if counter(14) = '1' then
			clk_out <= not clk_out;
			counter <= counter + DENOMINATOR - NUMERATOR;
		else
			counter <= counter - NUMERATOR;
		end if;
	end if;
end process;

end architecture behavioural;

