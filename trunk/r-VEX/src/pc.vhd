--------------------------------------------------------------------------------
-- r-VEX | Program Counter
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
-- pc.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.rVEX_pkg.all;

entity program_counter is
	port ( reset     : in std_logic; -- system reset
	       update_pc : in std_logic; -- update program counter on positive edge of update_pc
	       pc_goto   : in std_logic_vector((ADDR_WIDTH - 1) downto 0);   -- branch-updated program counter value

	       pc        : out std_logic_vector((ADDR_WIDTH - 1) downto 0)); -- current program counter
end entity program_counter;


architecture behavioural of program_counter is
	signal pc_current_i : std_logic_vector((ADDR_WIDTH - 1) downto 0) := x"FF";
begin	
	pc <= pc_current_i;

	update_counter : process (update_pc, pc_current_i, pc_goto, reset)
	begin
		if (reset = '1') then
			pc_current_i <= x"FF";
		elsif (update_pc = '1' and update_pc'event) then
			pc_current_i <= pc_goto;
		end if;
	end process update_counter;
end architecture behavioural;

