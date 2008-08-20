--------------------------------------------------------------------------------------------------
-- r-VEX | Writeback stage
--------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------
-- writeback.vhd
--------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity writeback is
	port ( clk               : in std_logic; -- system clock
	       reset             : in std_logic; -- system reset
	       write_en          : in std_logic; -- write enable
	       -- syllable 0 related inputs
	       address_gr_in_0   : in std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_in_0   : in std_logic_vector(2 downto 0);  -- address of BR to be written
	       data_gr_in_0      : in std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_in_0      : in std_logic;                     -- data to be written to BR
	       data_ctrl_in_0    : in std_logic_vector(31 downto 0); -- data to be written to lr or sp from CTRL
	       pc                : in std_logic_vector((ADDR_WIDTH - 1) downto 0); -- current program counter
	       pc_goto           : in std_logic_vector((ADDR_WIDTH - 1) downto 0); -- new program counter value
	       target_0          : in std_logic_vector(2 downto 0);  -- writeback target
	       -- syllable 1 related inputs
	       address_gr_in_1   : in std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_in_1   : in std_logic_vector(2 downto 0);  -- address of BR to be written
	       data_gr_in_1      : in std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_in_1      : in std_logic;                     -- data to be written to BR
	       target_1          : in std_logic_vector(2 downto 0);  -- writeback target
	       -- syllable 2 related inputs
	       address_gr_in_2   : in std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_in_2   : in std_logic_vector(2 downto 0);  -- address of BR to be written
	       data_gr_in_2      : in std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_in_2      : in std_logic;                     -- data to be written to BR
	       target_2          : in std_logic_vector(2 downto 0);  -- writeback target
	       -- syllable 3 related inputs
	       address_gr_in_3   : in std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_in_3   : in std_logic_vector(2 downto 0);  -- address of BR to be written
	       address_mem_in_3  : in std_logic_vector((DMEM_LOGDEP - 1) downto 0); -- address of data memory to be written
	       data_gr_in_3      : in std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_in_3      : in std_logic;                     -- data to be written to BR
	       data_mem_in_3     : in std_logic_vector((DMEM_WIDTH - 1) downto 0);  -- data to be written to data memory
	       data_grm_in_3     : in std_logic_vector(31 downto 0); -- data to be written to GR by MEM unit
	       target_3          : in std_logic_vector(2 downto 0);  -- writeback target

	       written           : out std_logic;                    -- '1' when writeback stage is finished
	       -- syllable 0 related outputs
	       write_en_gr_0     : out std_logic;                     -- write enable for GR
	       write_en_br_0     : out std_logic;                     -- write enable for BR
	       address_gr_out_0  : out std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_out_0  : out std_logic_vector(2 downto 0);  -- address of BR to be written
	       data_gr_out_0     : out std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_out_0     : out std_logic;                     -- data to be written to BR
	       data_pc           : out std_logic_vector((ADDR_WIDTH - 1) downto 0); -- data to be written to program counter
	       -- syllable 1 related outputs
	       write_en_gr_1     : out std_logic;                     -- write enable for GR
	       write_en_br_1     : out std_logic;                     -- write enable for BR
	       address_gr_out_1  : out std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_out_1  : out std_logic_vector(2 downto 0);  -- address of BR to be written
	       data_gr_out_1     : out std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_out_1     : out std_logic;                     -- data to be written to BR
	       -- syllable 2 related outputs
	       write_en_gr_2     : out std_logic;                     -- write enable for GR
	       write_en_br_2     : out std_logic;                     -- write enable for BR
	       address_gr_out_2  : out std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_out_2  : out std_logic_vector(2 downto 0);  -- address of BR to be written
	       data_gr_out_2     : out std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_out_2     : out std_logic;                     -- data to be written to BR
	       -- syllable 3 related outputs
	       write_en_gr_3     : out std_logic;                     -- write enable for GR
	       write_en_br_3     : out std_logic;                     -- write enable for BR
	       write_en_mem_3    : out std_logic;                     -- write enable for data memory
	       address_gr_out_3  : out std_logic_vector(5 downto 0);  -- address of GR to be written
	       address_br_out_3  : out std_logic_vector(2 downto 0);  -- address of BR to be written
	       address_mem_out_3 : out std_logic_vector((DMEM_LOGDEP - 1) downto 0); -- addres of data memory to be written
	       data_gr_out_3     : out std_logic_vector(31 downto 0); -- data to be written to GR
	       data_br_out_3     : out std_logic;                     -- data to be written to BR
	       data_mem_out_3    : out std_logic_vector((DMEM_WIDTH - 1) downto 0)); -- data to be written to data memory
end entity writeback;


architecture behavioural of writeback is
	type writeback_states is (reset_state, waiting, pre_write, write, waiting_branch);
	signal current_state, next_state : writeback_states;
begin
	-- Synchronizes writeback states
	writeback_sync: process(clk, reset)
	begin
		if (reset = '1') then
			current_state <= reset_state;
		elsif (clk = '1' and clk'event) then
			current_state <= next_state;
		end if;
	end process writeback_sync;

	-- Controls output of writeback stage
	writeback_output: process(current_state, address_gr_in_0, address_br_in_0,
	                          address_mem_in_3, data_gr_in_0, data_br_in_0,
	                          data_mem_in_3, data_grm_in_3, data_ctrl_in_0,
	                          pc_goto, pc, target_0, target_1, address_gr_in_1,
	                          data_gr_in_1, address_br_in_1, data_br_in_1,
	                          target_2, address_gr_in_2, data_gr_in_2,
	                          address_br_in_2, data_br_in_2, target_3,
	                          address_gr_in_3, data_gr_in_3, address_br_in_3,
	                          data_br_in_3)
	begin
		case current_state is
			when reset_state =>
				written <= '0';
	
				-------------------------
				-- Syllable 0 handling --
				-------------------------
				write_en_gr_0 <= '0';
				write_en_br_0 <= '0';

				address_gr_out_0 <= (others => '0');
				address_br_out_0 <= (others => '0');
				data_gr_out_0 <= (others => '0');
				data_br_out_0 <= '0';
				data_pc <= (others => '0');

				-------------------------
				-- Syllable 1 handling --
				-------------------------
				write_en_gr_1 <= '0';
				write_en_br_1 <= '0';

				address_gr_out_1 <= (others => '0');
				address_br_out_1 <= (others => '0');
				data_gr_out_1 <= (others => '0');
				data_br_out_1 <= '0';

				-------------------------
				-- Syllable 2 handling --
				-------------------------
				write_en_gr_2 <= '0';
				write_en_br_2 <= '0';

				address_gr_out_2 <= (others => '0');
				address_br_out_2 <= (others => '0');
				data_gr_out_2 <= (others => '0');
				data_br_out_2 <= '0';

				-------------------------
				-- Syllable 3 handling --
				-------------------------
				write_en_gr_3 <= '0';
				write_en_br_3 <= '0';
				write_en_mem_3 <= '0';

				address_gr_out_3 <= (others => '0');
				address_br_out_3 <= (others => '0');
				address_mem_out_3 <= (others => '0');
				data_gr_out_3 <= (others => '0');
				data_br_out_3 <= '0';
				data_mem_out_3 <= (others => '0');
			when waiting =>
				written <= '1';

				-------------------------
				-- Syllable 0 handling --
				-------------------------
				write_en_gr_0 <= '0';
				write_en_br_0 <= '0';

				address_gr_out_0 <= (others => '0');
				address_br_out_0 <= (others => '0');
				data_gr_out_0 <= (others => '0');
				data_br_out_0 <= '0';
				data_pc <= pc + 1;

				-------------------------
				-- Syllable 1 handling --
				-------------------------
				write_en_gr_1 <= '0';
				write_en_br_1 <= '0';

				address_gr_out_1 <= (others => '0');
				address_br_out_1 <= (others => '0');
				data_gr_out_1 <= (others => '0');
				data_br_out_1 <= '0';

				-------------------------
				-- Syllable 2 handling --
				-------------------------
				write_en_gr_2 <= '0';
				write_en_br_2 <= '0';

				address_gr_out_2 <= (others => '0');
				address_br_out_2 <= (others => '0');
				data_gr_out_2 <= (others => '0');
				data_br_out_2 <= '0';

				-------------------------
				-- Syllable 3 handling --
				-------------------------
				write_en_gr_3 <= '0';
				write_en_br_3 <= '0';
				write_en_mem_3 <= '0';

				address_gr_out_3 <= (others => '0');
				address_br_out_3 <= (others => '0');
				address_mem_out_3 <= (others => '0');
				data_gr_out_3 <= (others => '0');
				data_br_out_3 <= '0';
				data_mem_out_3 <= (others => '0');
			when pre_write =>
				written <= '0';

				-------------------------
				-- Syllable 0 handling --
				-------------------------
				write_en_gr_0 <= '0';
				write_en_br_0 <= '0';

				case target_0 is
					when WRITE_G =>
						address_gr_out_0 <= address_gr_in_0;
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= data_gr_in_0;
						data_br_out_0 <= '0';
						data_pc <= pc + 1;
					when WRITE_B =>
						address_gr_out_0 <= (others => '0');
						address_br_out_0 <= address_br_in_0;
						data_gr_out_0 <= (others => '0');
						data_br_out_0 <= data_br_in_0;
						data_pc <= pc + 1;
					when WRITE_G_B =>
						address_gr_out_0 <= address_gr_in_0;
						address_br_out_0 <= address_br_in_0;
						data_gr_out_0 <= data_gr_in_0;
						data_br_out_0 <= data_br_in_0;
						data_pc <= pc + 1;
					when WRITE_P =>
						address_gr_out_0 <= (others => '0');
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= (others => '0');
						data_br_out_0 <= '0';
						data_pc <= pc_goto;
					when WRITE_P_G =>
						address_gr_out_0 <= address_gr_in_0;
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= data_ctrl_in_0;
						data_br_out_0 <= '0';
						data_pc <= pc_goto;
					when others =>
						address_gr_out_0 <= (others => '0');
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= (others => '0');
						data_br_out_0 <= '0';
						data_pc <= pc + 1;
				end case;

				-------------------------
				-- Syllable 1 handling --
				-------------------------
				write_en_gr_1 <= '0';
				write_en_br_1 <= '0';

				case target_1 is
					when WRITE_G =>
						address_gr_out_1 <= address_gr_in_1;
						address_br_out_1 <= (others => '0');
						data_gr_out_1 <= data_gr_in_1;
						data_br_out_1 <= '0';
					when WRITE_B =>
						address_gr_out_1 <= (others => '0');
						address_br_out_1 <= address_br_in_1;
						data_gr_out_1 <= (others => '0');
						data_br_out_1 <= data_br_in_1;
					when WRITE_G_B =>
						address_gr_out_1 <= address_gr_in_1;
						address_br_out_1 <= address_br_in_1;
						data_gr_out_1 <= data_gr_in_1;
						data_br_out_1 <= data_br_in_1;
					when others =>
						address_gr_out_1 <= (others => '0');
						address_br_out_1 <= (others => '0');
						data_gr_out_1 <= (others => '0');
						data_br_out_1 <= '0';
				end case;

				-------------------------
				-- Syllable 2 handling --
				-------------------------
				write_en_gr_2 <= '0';
				write_en_br_2 <= '0';

				case target_2 is
					when WRITE_G =>
						address_gr_out_2 <= address_gr_in_2;
						address_br_out_2 <= (others => '0');
						data_gr_out_2 <= data_gr_in_2;
						data_br_out_2 <= '0';
					when WRITE_B =>
						address_gr_out_2 <= (others => '0');
						address_br_out_2 <= address_br_in_2;
						data_gr_out_2 <= (others => '0');
						data_br_out_2 <= data_br_in_2;
					when WRITE_G_B =>
						address_gr_out_2 <= address_gr_in_2;
						address_br_out_2 <= address_br_in_2;
						data_gr_out_2 <= data_gr_in_2;
						data_br_out_2 <= data_br_in_2;
					when others =>
						address_gr_out_2 <= (others => '0');
						address_br_out_2 <= (others => '0');
						data_gr_out_2 <= (others => '0');
						data_br_out_2 <= '0';
				end case;

				-------------------------
				-- Syllable 3 handling --
				-------------------------
				write_en_gr_3 <= '0';
				write_en_br_3 <= '0';
				write_en_mem_3 <= '0';

				case target_3 is
					when WRITE_G =>
						address_gr_out_3 <= address_gr_in_3;
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= data_gr_in_3;
						data_br_out_3 <= '0';
						data_mem_out_3 <= (others => '0');
					when WRITE_B =>
						address_gr_out_3 <= (others => '0');
						address_br_out_3 <= address_br_in_3;
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= (others => '0');
						data_br_out_3 <= data_br_in_3;
						data_mem_out_3 <= (others => '0');
					when WRITE_G_B =>
						address_gr_out_3 <= address_gr_in_3;
						address_br_out_3 <= address_br_in_3;
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= data_gr_in_3;
						data_br_out_3 <= data_br_in_3;
						data_mem_out_3 <= (others => '0');
					when WRITE_M =>
						address_gr_out_3 <= (others => '0');
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= address_mem_in_3;
						data_gr_out_3 <= (others => '0');
						data_br_out_3 <= '0';
						data_mem_out_3 <= data_mem_in_3;
					when WRITE_MG =>
						address_gr_out_3 <= address_gr_in_0;
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= data_grm_in_3;
						data_br_out_3 <= '0';
						data_mem_out_3 <= (others => '0');
					when others =>
						address_gr_out_3 <= (others => '0');
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= (others => '0');
						data_br_out_3 <= '0';
						data_mem_out_3 <= (others => '0');
				end case;
			when write =>
				written <= '1';

				-------------------------
				-- Syllable 0 handling --
				-------------------------
				case target_0 is
					when WRITE_G =>
						write_en_gr_0 <= '1';
						write_en_br_0 <= '0';
						address_gr_out_0 <= address_gr_in_0;
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= data_gr_in_0;
						data_br_out_0 <= '0';
						data_pc <= pc + 1;
					when WRITE_B =>
						write_en_gr_0 <= '0';
						write_en_br_0 <= '1';
						address_gr_out_0 <= (others => '0');
						address_br_out_0 <= address_br_in_0;
						data_gr_out_0 <= (others => '0');
						data_br_out_0 <= data_br_in_0;
						data_pc <= pc + 1;
					when WRITE_G_B =>
						write_en_gr_0 <= '1';
						write_en_br_0 <= '1';
						address_gr_out_0 <= address_gr_in_0;
						address_br_out_0 <= address_br_in_0;
						data_gr_out_0 <= data_gr_in_0;
						data_br_out_0 <= data_br_in_0;
						data_pc <= pc + 1;
					when WRITE_P =>
						write_en_gr_0 <= '0';
						write_en_br_0 <= '0';
						address_gr_out_0 <= (others => '0');
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= (others => '0');
						data_br_out_0 <= '0';
						data_pc <= pc_goto;
					when WRITE_P_G =>
						write_en_gr_0 <= '1';
						write_en_br_0 <= '0';
						address_gr_out_0 <= address_gr_in_0;
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= data_ctrl_in_0;
						data_br_out_0 <= '0';
						data_pc <= pc_goto;
					when others =>
						write_en_gr_0 <= '0';
						write_en_br_0 <= '0';
						address_gr_out_0 <= (others => '0');
						address_br_out_0 <= (others => '0');
						data_gr_out_0 <= (others => '0');
						data_br_out_0 <= '0';
						data_pc <= pc + 1;
				end case;

				-------------------------
				-- Syllable 1 handling --
				-------------------------
				case target_1 is
					when WRITE_G =>
						write_en_gr_1 <= '1';
						write_en_br_1 <= '0';
						address_gr_out_1 <= address_gr_in_1;
						address_br_out_1 <= (others => '0');
						data_gr_out_1 <= data_gr_in_1;
						data_br_out_1 <= '0';
					when WRITE_B =>
						write_en_gr_1 <= '0';
						write_en_br_1 <= '1';
						address_gr_out_1 <= (others => '0');
						address_br_out_1 <= address_br_in_1;
						data_gr_out_1 <= (others => '0');
						data_br_out_1 <= data_br_in_1;
					when WRITE_G_B =>
						write_en_gr_1 <= '1';
						write_en_br_1 <= '1';
						address_gr_out_1 <= address_gr_in_1;
						address_br_out_1 <= address_br_in_1;
						data_gr_out_1 <= data_gr_in_1;
						data_br_out_1 <= data_br_in_1;
					when others =>
						write_en_gr_1 <= '0';
						write_en_br_1 <= '0';
						address_gr_out_1 <= (others => '0');
						address_br_out_1 <= (others => '0');
						data_gr_out_1 <= (others => '0');
						data_br_out_1 <= '0';
				end case;

				-------------------------
				-- Syllable 2 handling --
				-------------------------
				case target_2 is
					when WRITE_G =>
						write_en_gr_2 <= '1';
						write_en_br_2 <= '0';
						address_gr_out_2 <= address_gr_in_2;
						address_br_out_2 <= (others => '0');
						data_gr_out_2 <= data_gr_in_2;
						data_br_out_2 <= '0';
					when WRITE_B =>
						write_en_gr_2 <= '0';
						write_en_br_2 <= '1';
						address_gr_out_2 <= (others => '0');
						address_br_out_2 <= address_br_in_2;
						data_gr_out_2 <= (others => '0');
						data_br_out_2 <= data_br_in_2;
					when WRITE_G_B =>
						write_en_gr_2 <= '1';
						write_en_br_2 <= '1';
						address_gr_out_2 <= address_gr_in_2;
						address_br_out_2 <= address_br_in_2;
						data_gr_out_2 <= data_gr_in_2;
						data_br_out_2 <= data_br_in_2;
					when others =>
						write_en_gr_2 <= '0';
						write_en_br_2 <= '0';
						address_gr_out_2 <= (others => '0');
						address_br_out_2 <= (others => '0');
						data_gr_out_2 <= (others => '0');
						data_br_out_2 <= '0';
				end case;

				-------------------------
				-- Syllable 3 handling --
				-------------------------
				case target_3 is
					when WRITE_G =>
						write_en_gr_3 <= '1';
						write_en_br_3 <= '0';
						write_en_mem_3 <= '0';
						address_gr_out_3 <= address_gr_in_3;
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= data_gr_in_3;
						data_br_out_3 <= '0';
						data_mem_out_3 <= (others => '0');
					when WRITE_B =>
						write_en_gr_3 <= '0';
						write_en_br_3 <= '1';
						write_en_mem_3 <= '0';
						address_gr_out_3 <= (others => '0');
						address_br_out_3 <= address_br_in_3;
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= (others => '0');
						data_br_out_3 <= data_br_in_3;
						data_mem_out_3 <= (others => '0');
					when WRITE_G_B =>
						write_en_gr_3 <= '1';
						write_en_br_3 <= '1';
						write_en_mem_3 <= '0';
						address_gr_out_3 <= address_gr_in_3;
						address_br_out_3 <= address_br_in_3;
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= data_gr_in_3;
						data_br_out_3 <= data_br_in_3;
						data_mem_out_3 <= (others => '0');
					when WRITE_M =>
						write_en_gr_3 <= '0';
						write_en_br_3 <= '0';
						write_en_mem_3 <= '1';
						address_gr_out_3 <= (others => '0');
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= address_mem_in_3;
						data_gr_out_3 <= (others => '0');
						data_br_out_3 <= '0';
						data_mem_out_3 <= data_mem_in_3;
					when WRITE_MG =>
						write_en_gr_3 <= '1';
						write_en_br_3 <= '0';
						write_en_mem_3 <= '0';
						address_gr_out_3 <= address_gr_in_0;
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= data_grm_in_3;
						data_br_out_3 <= '0';
						data_mem_out_3 <= (others => '0');
					when others =>
						write_en_gr_3 <= '0';
						write_en_br_3 <= '0';
						write_en_mem_3 <= '0';
						address_gr_out_3 <= (others => '0');
						address_br_out_3 <= (others => '0');
						address_mem_out_3 <= (others => '0');
						data_gr_out_3 <= (others => '0');
						data_br_out_3 <= '0';
						data_mem_out_3 <= (others => '0');
				end case;
			when waiting_branch =>
				written <= '1';			
				-- TODO / FIXME!
				-- Maybe the signals for issue 1,2 and 3 should be the same as
				-- in the previous stage

				-------------------------
				-- Syllable 0 handling --
				-------------------------
				write_en_gr_0 <= '0';
				write_en_br_0 <= '0';

				address_gr_out_0 <= (others => '0');
				address_br_out_0 <= (others => '0');
				data_gr_out_0 <= (others => '0');
				data_br_out_0 <= '0';
				data_pc <= pc_goto;

				-------------------------
				-- Syllable 1 handling --
				-------------------------
				write_en_gr_1 <= '0';
				write_en_br_1 <= '0';

				address_gr_out_1 <= (others => '0');
				address_br_out_1 <= (others => '0');
				data_gr_out_1 <= (others => '0');
				data_br_out_1 <= '0';

				-------------------------
				-- Syllable 2 handling --
				-------------------------
				write_en_gr_2 <= '0';
				write_en_br_2 <= '0';

				address_gr_out_2 <= (others => '0');
				address_br_out_2 <= (others => '0');
				data_gr_out_2 <= (others => '0');
				data_br_out_2 <= '0';

				-------------------------
				-- Syllable 3 handling --
				-------------------------
				write_en_gr_3 <= '0';
				write_en_br_3 <= '0';
				write_en_mem_3 <= '0';

				address_gr_out_3 <= (others => '0');
				address_br_out_3 <= (others => '0');
				address_mem_out_3 <= (others => '0');
				data_gr_out_3 <= (others => '0');
				data_br_out_3 <= '0';
				data_mem_out_3 <= (others => '0');
		end case;
	end process writeback_output;
	
	-- Controls writeback stage
	writeback_control: process(clk, current_state, target_0, write_en)
	begin
		case current_state is
			when reset_state =>
				next_state <= waiting;
			when waiting =>
				if (target_0 = WRITE_NOP and target_1 = WRITE_NOP
				      and target_2 = WRITE_NOP and target_3 = WRITE_NOP) then
					next_state <= waiting;
				else
					next_state <= pre_write;
				end if;
			when pre_write =>
				if (write_en = '1') then
					next_state <= write;
				else
					next_state <= pre_write;
				end if;
			when write =>
				case target_0 is
					when WRITE_P =>
						next_state <= waiting_branch;
					when WRITE_P_G =>
						next_state <= waiting_branch;
					when others =>
						next_state <= waiting;
				end case;
			when waiting_branch =>
				next_state <= waiting;
		end case;
	end process writeback_control;
end architecture behavioural;

