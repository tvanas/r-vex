--------------------------------------------------------------------------------
-- UART | Package
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
-- uart_pkg.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package uart_pkg is
	function init_message(index  : std_logic_vector(7 downto 0);
	                      cycles : std_logic_vector(31 downto 0)) return std_logic_vector;

	function to_hex_ascii(hex : std_logic_vector(3 downto 0)) return std_logic_vector;
end package;


package body uart_pkg is
	function init_message(index  : std_logic_vector(7 downto 0);
	                      cycles : std_logic_vector(31 downto 0)) return std_logic_vector is
	begin
		case index is
			when x"00" =>
				return "00001101"; -- CR Carriage Return
			when x"01" =>		
				return "00001010"; -- LF Line Feed
			when x"03" =>
				return "00001101"; -- CR Carriage Return
			when x"04" =>		
				return "00001010"; -- LF Line Feed
			when x"05" =>
				return "01110010"; -- r
			when x"06" =>
				return "00101101"; -- -
			when x"07" =>
				return "01010110"; -- V
			when x"08" =>
				return "01000101"; -- E
			when x"09" =>
				return "01011000"; -- X
			when x"0A" =>
				return "00001101"; -- CR Carriage Return
			when x"0B" =>
				return "00001010"; -- LF Line Feed
			when x"0C" =>
				return "00101101"; -- -
			when x"0D" =>
				return "00101101"; -- -
			when x"0E" =>
				return "00101101"; -- -
			when x"0F" =>
				return "00101101"; -- -
			when x"10" =>
				return "00101101"; -- -
			when x"11" =>
				return "00001101"; -- CR Carriage Return
			when x"12" =>
				return "00001010"; -- LF Line Feed
			when x"13" =>
				return "01000011"; -- C
			when x"14" =>
				return "01111001"; -- y
			when x"15" =>
				return "01100011"; -- c
			when x"16" =>
				return "01101100"; -- l
			when x"17" =>
				return "01100101"; -- e
			when x"18" =>
				return "01110011"; -- s
			when x"19" =>
				return "00111010"; -- :
			when x"1A" =>
				return "00100000"; -- SP Space
			when x"1B" =>
				return "00110000"; -- 0
			when x"1C" =>
				return "01111000"; -- x
			when x"1D" =>
				return to_hex_ascii(cycles(31 downto 28)); 
			when x"1E" =>
				return to_hex_ascii(cycles(27 downto 24)); 
			when x"1F" =>
				return to_hex_ascii(cycles(23 downto 20)); 
			when x"20" =>
				return to_hex_ascii(cycles(19 downto 16)); 
			when x"21" =>
				return to_hex_ascii(cycles(15 downto 12)); 
			when x"22" =>
				return to_hex_ascii(cycles(11 downto 8)); 
			when x"23" =>
				return to_hex_ascii(cycles(7 downto 4)); 
			when x"24" =>
				return to_hex_ascii(cycles(3 downto 0)); 
			when x"25" =>
				return "00001101"; -- CR Carriage Return
			when x"26" =>
				return "00001010"; -- LF Line Feed
			when x"27" =>
				return "00001101"; -- CR Carriage Return
			when x"28" =>
				return "00001010"; -- LF Line Feed
			when x"29" =>
				return "01000100"; -- D
			when x"2A" =>
				return "01100001"; -- a
			when x"2B" =>
				return "01110100"; -- t
			when x"2C" =>
				return "01100001"; -- a
			when x"2D" =>
				return "00100000"; -- SP Space
			when x"2E" =>
				return "01101101"; -- m
			when x"2F" =>
				return "01100101"; -- e
			when x"30" =>
				return "01101101"; -- m
			when x"31" =>
				return "01101111"; -- o
			when x"32" =>
				return "01110010"; -- r
			when x"33" =>
				return "01111001"; -- y
			when x"34" =>
				return "00100000"; -- SP Space
			when x"35" =>
				return "01100100"; -- d
			when x"36" =>
				return "01110101"; -- u
			when x"37" =>
				return "01101101"; -- m
			when x"38" =>
				return "01110000"; -- p
			when x"39" =>
				return "00001101"; -- CR Carriage Return
			when x"3A" =>		
				return "00001010"; -- LF Line Feed
			when x"3B" =>
				return "00001101"; -- CR Carriage Return
			when x"3C" =>		
				return "00001010"; -- LF Line Feed
			when x"3D" =>
				return "01100001"; -- a
			when x"3E" =>
				return "01100100"; -- d
			when x"3F" =>
				return "01100100"; -- d
			when x"40" =>
				return "01110010"; -- r
			when x"41" =>
				return "00100000"; -- SP Space
			when x"42" =>
				return "01111100"; -- |
			when x"43" =>
				return "00100000"; -- SP Space
			when x"44" =>
				return "01100011"; -- c
			when x"45" =>
				return "01101111"; -- o
			when x"46" =>
				return "01101110"; -- n
			when x"47" =>
				return "01110100"; -- t
			when x"48" =>
				return "01100101"; -- e
			when x"49" =>
				return "01101110"; -- n
			when x"4A" =>
				return "01110100"; -- t
			when x"4B" =>
				return "01110011"; -- s
			when x"4C" =>
				return "00001101"; -- CR Carriage Return
			when x"4D" =>		
				return "00001010"; -- LF Line Feed
			when x"4E" =>
				return "00101101"; -- -
			when x"4F" =>
				return "00101101"; -- -
			when x"50" =>
				return "00101101"; -- -
			when x"51" =>
				return "00101101"; -- -
			when x"52" =>
				return "00101101"; -- -
			when x"53" =>
				return "00101011"; -- +
			when x"54" =>
				return "00101101"; -- -
			when x"55" =>
				return "00101101"; -- -
			when x"56" =>
				return "00101101"; -- -
			when x"57" =>
				return "00101101"; -- -
			when x"58" =>
				return "00101101"; -- -
			when x"59" =>
				return "00101101"; -- -
			when x"5A" =>
				return "00101101"; -- -
			when x"5B" =>
				return "00101101"; -- -
			when x"5C" =>
				return "00101101"; -- -
			when x"5D" =>
				return "00101101"; -- -
			when x"5E" =>
				return "00101101"; -- -
			when others =>
				return "00000000"; -- null
		end case;
	end function init_message;

	function to_hex_ascii(hex : std_logic_vector(3 downto 0)) return std_logic_vector is
	begin
		case hex is
			when x"0" => 
				return "00110000";
			when x"1" =>
				return "00110001";
			when x"2" =>
				return "00110010";
			when x"3" =>
				return "00110011";
			when x"4" =>
				return "00110100";
			when x"5" =>
				return "00110101";
			when x"6" =>
				return "00110110";
			when x"7" =>
				return "00110111";
			when x"8" =>
				return "00111000";
			when x"9" =>
				return "00111001";
			when x"A" =>
				return "01000001";
			when x"B" =>
				return "01000010";
			when x"C" =>
				return "01000011";
			when x"D" =>
				return "01000100";
			when x"E" =>
				return "01000101";
			when x"F" =>
				return "01000110";
			when others =>
				return "00000000";
		end case;
	end function to_hex_ascii;
end package body uart_pkg;

