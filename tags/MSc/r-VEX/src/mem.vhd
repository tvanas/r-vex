--------------------------------------------------------------------------------
-- r-VEX | Memory unit
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
-- mem.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;
use work.mem_operations.all;

entity mem is
	port ( clk       : in std_logic;  -- system clock
	       reset     : in std_logic;  -- system reset
	       opcode    : in std_logic_vector(6 downto 0);   -- opcode
	       data_reg  : in std_logic_vector(31 downto 0);  -- register contents to store
	       pos_off   : in std_logic_vector(1 downto 0);   -- offset in data memory
	       data_ld   : in std_logic_vector((DMEM_WIDTH - 1) downto 0);  -- data loaded from memory
	       in_valid  : in std_logic;  -- '1' when input is valid

	       data_st   : out std_logic_vector((DMEM_WIDTH - 1) downto 0); -- data to be stored in memory
	       data_2reg : out std_logic_vector(31 downto 0); -- data from memory to be stored in register
	       out_valid : out std_logic); -- '1' when output is valid
end entity mem;


architecture behavioural of mem is
	signal result_s : std_logic_vector((DMEM_WIDTH - 1) downto 0) := (others => '0');

	type mem_states is (reset_state, waiting, load, store, output_load,
	                      output_store, output_store1);
	signal current_state, next_state : mem_states;
begin
	-- Calculates load/store values
	mem_cal : process(clk, reset)
	begin
		if (reset = '1') then
			result_s <= (others => '0');
		elsif (clk = '1' and clk'event) then
			case opcode is
				when MEM_LDW =>
					result_s <= f_LDW (data_ld);
				when MEM_LDH =>
					result_s <= f_LDH (data_ld, pos_off);
				when MEM_LDHU =>
					result_s <= f_LDHU (data_ld, pos_off);
				when MEM_LDB =>
					result_s <= f_LDB (data_ld, pos_off);
				when MEM_LDBU =>
					result_s <= f_LDBU (data_ld, pos_off);
				when MEM_STW =>
					result_s <= f_STW (data_reg);
				when MEM_STH =>
					result_s <= f_STH (data_ld, data_reg, pos_off);
				when MEM_STB =>
					result_s <= f_STB (data_ld, data_reg, pos_off);
				when others =>
					result_s <= (others => '0');
			end case;
		end if;
	end process mem_cal;

	-- Synchronizes MEM states
	mem_sync : process(clk, reset)
	begin
		if (reset = '1') then
			current_state <= reset_state;
		elsif (clk = '1' and clk'event) then
			current_state <= next_state;
		end if;
	end process mem_sync;

	-- Controls outputs of memory unit
	mem_output : process(current_state, result_s)
	begin
		case current_state is
			when reset_state =>
				data_st <= (others => '0');
				data_2reg <= (others => '0');
				out_valid <= '0';
			when waiting =>
				data_st <= (others => '0');
				data_2reg <= (others => '0');
				out_valid <= '0';
			when load =>
				data_st <= (others => '0');
				data_2reg <= result_s;
				out_valid <= '0';
			when store =>
				data_st <= result_s;
				data_2reg <= (others => '0');
				out_valid <= '0';
			when output_load =>
				data_st <= (others => '0');
				data_2reg <= result_s;
				out_valid <= '1';
			when output_store =>
				data_st <= result_s;
				data_2reg <= (others => '0');
				out_valid <= '1';
			when output_store1 =>
				data_st <= result_s;
				data_2reg <= (others => '0');
				out_valid <= '1';
		end case;
	end process mem_output;

	-- Controls MEM operations
	mem_control : process(clk, current_state, in_valid, opcode)
	begin
		case current_state is
			when reset_state =>
				next_state <= waiting;
			when waiting =>
				if (in_valid = '1' and std_match(opcode, MEM_OP)) then
					if (std_match(opcode, MEM_STW) or std_match(opcode, MEM_STH)
					      or std_match(opcode, MEM_STB)) then
						-- store operation
						next_state <= store;
					else
						-- load operation
						next_state <= load;
					end if;
				else
					next_state <= waiting;
				end if;
			when load =>
				next_state <= output_load;
			when store =>
				next_state <= output_store;
			when output_load =>
				next_state <= waiting;
			when output_store =>
				next_state <= output_store1;
			when output_store1 =>
				next_state <= waiting;
		end case;
	end process mem_control;
end architecture behavioural;

