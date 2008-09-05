--------------------------------------------------------------------------------
-- r-VEX | BR Register file
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
-- registers_br.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity registers_br is
	port ( clk         : in std_logic;
	       write_en_0   : in std_logic;   -- syllable 0 write enable
	       write_en_1   : in std_logic;   -- syllable 1 write enable
	       write_en_2   : in std_logic;   -- syllable 2 write enable
	       write_en_3   : in std_logic;   -- syllable 3 write enable
	       address_r_0  : in std_logic_vector(2 downto 0); -- syllable 0 address to be read from
	       address_r_1  : in std_logic_vector(2 downto 0); -- syllable 1 address to be read from
	       address_r_2  : in std_logic_vector(2 downto 0); -- syllable 2 address to be read from
	       address_r_3  : in std_logic_vector(2 downto 0); -- syllable 3 address to be read from
	       address_w_0  : in std_logic_vector(2 downto 0); -- syllable 0 address to be written to
	       address_w_1  : in std_logic_vector(2 downto 0); -- syllable 1 address to be written to
	       address_w_2  : in std_logic_vector(2 downto 0); -- syllable 2 address to be written to
	       address_w_3  : in std_logic_vector(2 downto 0); -- syllable 3 address to be written to
	       data_in_0    : in std_logic;   -- syllable 0 input data
	       data_in_1    : in std_logic;   -- syllable 1 input data
	       data_in_2    : in std_logic;   -- syllable 2 input data
	       data_in_3    : in std_logic;   -- syllable 3 input data
			   
	       data_out_0   : out std_logic;  -- syllable 0 output data
	       data_out_1   : out std_logic;  -- syllable 1 output data
	       data_out_2   : out std_logic;  -- syllable 2 output data
	       data_out_3   : out std_logic); -- syllable 3 output data
end entity registers_br;


architecture behavioural of registers_br is
	type regs_t is array (0 to (BR_DEPTH - 1)) of std_logic;
	signal registers : regs_t := (others => '0');
begin
	reg_handler : process(clk)
	begin
		if (clk = '1' and clk'event) then
			if (write_en_0 = '1') then				
				registers(conv_integer(address_w_0)) <= data_in_0;
			end if;
			
			if (write_en_1 = '1') then				
				registers(conv_integer(address_w_1)) <= data_in_1;
			end if;
			
			if (write_en_2 = '1') then				
				registers(conv_integer(address_w_2)) <= data_in_2;
			end if;
			
			if (write_en_3 = '1') then				
				registers(conv_integer(address_w_3)) <= data_in_3;
			end if;
			
			data_out_0 <= registers(conv_integer(address_r_0));
			data_out_1 <= registers(conv_integer(address_r_1));
			data_out_2 <= registers(conv_integer(address_r_2));
			data_out_3 <= registers(conv_integer(address_r_3));
		end if;
	end process reg_handler;
end architecture behavioural;

