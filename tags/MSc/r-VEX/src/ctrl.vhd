--------------------------------------------------------------------------------
-- r-VEX | Control unit
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
-- ctrl.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.rVEX_pkg.all;
use work.ctrl_operations.all;

entity ctrl is
	port ( clk       : in std_logic;   -- system clock
	       reset     : in std_logic;   -- system reset
	       opcode    : in std_logic_vector(6 downto 0);                 -- CTRL opcode
	       pc        : in std_logic_vector((ADDR_WIDTH - 1) downto 0);  -- current program counter
	       lr        : in std_logic_vector(31 downto 0);                -- current link register ($r0.63) contents
	       sp        : in std_logic_vector(31 downto 0);                -- current stack pointer ($r0.1) contents
	       offset    : in std_logic_vector((BROFF_WIDTH - 1) downto 0); -- branch offset (imm or lr) value
	       br        : in std_logic;   -- branch register contents
	       in_valid  : in std_logic;   -- '1' when input is valud

	       pc_goto   : out std_logic_vector((ADDR_WIDTH - 1) downto 0); -- address to jump to
	       result    : out std_logic_vector(31 downto 0);               -- new lr or sp value
	       out_valid : out std_logic); -- '1' when output is valid  
end entity ctrl;


architecture behavioural of ctrl is
	signal result_i  : std_logic_vector(31 downto 0) := (others => '0');
	signal pc_goto_i : std_logic_vector((ADDR_WIDTH - 1) downto 0) := (others => '0');
begin
	result <= result_i;
	pc_goto <= pc_goto_i;

	-- Controls CTRL operations
	ctrl_control : process(clk, reset)
	begin
		if (reset = '1') then
			out_valid <= '0';
			result_i <= (others => '0');
			pc_goto_i <= (others => '0');
		elsif (clk = '1' and clk'event) then
			if (in_valid = '1') then
				out_valid <= '1'; -- this will be overriden when a non-existent opcode is issued
				case opcode is
					when CTRL_GOTO =>
						pc_goto_i <= f_GOTO (offset);
					when CTRL_IGOTO =>
						pc_goto_i <= f_IGOTO (lr);
					when CTRL_CALL =>
						f_CALL (offset, pc, pc_goto_i, result_i);
					when CTRL_ICALL =>
						f_ICALL (lr, pc, pc_goto_i, result_i);
					when CTRL_BR =>
						pc_goto_i <= f_BR (offset, pc, br);
					when CTRL_BRF =>
						pc_goto_i <= f_BRF (offset, pc, br);
					when CTRL_RETURN =>
						f_RETURN (offset, lr, sp, pc_goto_i, result_i);
					when CTRL_RFI =>
						f_RETURN (offset, lr, sp, pc_goto_i, result_i);
					when CTRL_XNOP =>
						pc_goto_i <= (others => '0');
					when NOP =>
						pc_goto_i <= (others => '0');
					when others =>
						out_valid <= '0';
				end case;
			else
				out_valid <= '0';
			end if;
		end if;
	end process ctrl_control;
end architecture behavioural;

