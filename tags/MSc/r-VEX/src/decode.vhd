--------------------------------------------------------------------------------
-- r-VEX | syllable decoder
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
-- For a detailed representation of the syllable layout,
-- read doc/syllable_layout.txt.
--------------------------------------------------------------------------------
-- decode.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity decode is
	port ( clk             : in std_logic; -- system clock
	       reset           : in std_logic; -- system reset
	       new_decode      : in std_logic; -- '1' when execute output is valid
	       fetch_ok        : in std_logic; -- '1' when syllable is fetched
	       start           : in std_logic; -- '1' when input is valid
	       -- syllable 0 related inputs
	       syllable_0      : in std_logic_vector(31 downto 0);  -- syllable
	       data_r1_0       : in std_logic_vector(31 downto 0);  -- register 1 contents
	       data_r2_0       : in std_logic_vector(31 downto 0);  -- register 2 contents
	       data_rb_0       : in std_logic;                      -- branch register contents
	       -- syllable 1 related inputs
	       syllable_1      : in std_logic_vector(31 downto 0);  -- syllable
	       data_r1_1       : in std_logic_vector(31 downto 0);  -- register 1 contents
	       data_r2_1       : in std_logic_vector(31 downto 0);  -- register 2 contents
	       data_rb_1       : in std_logic;                      -- branch register contents
	       -- syllable 2 related inputs
	       syllable_2      : in std_logic_vector(31 downto 0);  -- syllable
	       data_r1_2       : in std_logic_vector(31 downto 0);  -- register 1 contents
	       data_r2_2       : in std_logic_vector(31 downto 0);  -- register 2 contents
	       data_rb_2       : in std_logic;                      -- branch register contents
	       -- syllable 3 related inputs
	       syllable_3      : in std_logic_vector(31 downto 0);  -- syllable
	       data_r1_3       : in std_logic_vector(31 downto 0);  -- register 1 contents
	       data_r2_3       : in std_logic_vector(31 downto 0);  -- register 2 contents
	       data_rb_3       : in std_logic;                      -- branch register contents

	       -- syllable 0 related outputs
	       opcode_0        : out std_logic_vector(6 downto 0);  -- opcode
	       address_r1_0    : out std_logic_vector(5 downto 0);  -- register 1 address
	       address_r2_0    : out std_logic_vector(5 downto 0);  -- register 2 address
	       address_rb_0    : out std_logic_vector(2 downto 0);  -- branch register address
	       operand1_0      : out std_logic_vector(31 downto 0); -- operand 1
	       operand2_0      : out std_logic_vector(31 downto 0); -- operand 2
	       operandb_0      : out std_logic;                     -- branch operand
	       branch_dest_0   : out std_logic;                     -- '1' when target is BR for ALU op
	       address_dest_0  : out std_logic_vector(5 downto 0);  -- destination register address
	       address_destb_0 : out std_logic_vector(2 downto 0);  -- destination branch register address
	       target_0        : out std_logic_vector(2 downto 0);  -- writeback target
	       -- syllable 1 related outputs
	       opcode_1        : out std_logic_vector(6 downto 0);  -- opcode
	       address_r1_1    : out std_logic_vector(5 downto 0);  -- register 1 address
	       address_r2_1    : out std_logic_vector(5 downto 0);  -- register 2 address
	       address_rb_1    : out std_logic_vector(2 downto 0);  -- branch register address
	       operand1_1      : out std_logic_vector(31 downto 0); -- operand 1
	       operand2_1      : out std_logic_vector(31 downto 0); -- operand 2
	       operandb_1      : out std_logic;                     -- branch operand
	       branch_dest_1   : out std_logic;                     -- '1' when target is BR for ALU op
	       address_dest_1  : out std_logic_vector(5 downto 0);  -- destination register address
	       address_destb_1 : out std_logic_vector(2 downto 0);  -- destination branch register address
	       target_1        : out std_logic_vector(2 downto 0);  -- writeback target
	       -- syllable 2 related outputs
	       opcode_2        : out std_logic_vector(6 downto 0);  -- opcode
	       address_r1_2    : out std_logic_vector(5 downto 0);  -- register 1 address
	       address_r2_2    : out std_logic_vector(5 downto 0);  -- register 2 address
	       address_rb_2    : out std_logic_vector(2 downto 0);  -- branch register address
	       operand1_2      : out std_logic_vector(31 downto 0); -- operand 1
	       operand2_2      : out std_logic_vector(31 downto 0); -- operand 2
	       operandb_2      : out std_logic;                     -- branch operand
	       branch_dest_2   : out std_logic;                     -- '1' when target is BR for ALU op
	       address_dest_2  : out std_logic_vector(5 downto 0);  -- destination register address
	       address_destb_2 : out std_logic_vector(2 downto 0);  -- destination branch register address
	       target_2        : out std_logic_vector(2 downto 0);  -- writeback target
	       -- syllable 3 related outputs
	       opcode_3        : out std_logic_vector(6 downto 0);  -- opcode
	       address_r1_3    : out std_logic_vector(5 downto 0);  -- register 1 address
	       address_r2_3    : out std_logic_vector(5 downto 0);  -- register 2 address
	       address_rb_3    : out std_logic_vector(2 downto 0);  -- branch register address
	       operand1_3      : out std_logic_vector(31 downto 0); -- operand 1
	       operand2_3      : out std_logic_vector(31 downto 0); -- operand 2
	       operandb_3      : out std_logic;                     -- branch operand
	       branch_dest_3   : out std_logic;                     -- '1' when target is BR for ALU op
	       address_dest_3  : out std_logic_vector(5 downto 0);  -- destination register address
	       address_destb_3 : out std_logic_vector(2 downto 0);  -- destination branch register address
	       target_3        : out std_logic_vector(2 downto 0);  -- writeback target
	       address_dr_3    : out std_logic_vector((DMEM_LOGDEP - 1) downto 0); -- data memory address
	       address_off_3   : out std_logic_vector(1 downto 0);                 -- data memory offset
		   
	       offset          : out std_logic_vector((BROFF_WIDTH - 1) downto 0); -- branch offset (imm or lr) value
	       ops_ready       : out std_logic;  -- '1' when operands are ready
	       accept_in       : out std_logic;  -- '1' when accepting new input
	       done            : out std_logic); -- '1' when STOP opcode is decoded
end entity decode;


architecture behavioural of decode is
	type decode_states is (reset_state, waiting, fetch_regs, send_operands);
	signal current_state, next_state: decode_states;
	
	signal address_dr_3_s : std_logic_vector(9 downto 0) := (others => '0');
	signal accept_in_i : std_logic := '0';
	signal done_i : std_logic := '0';
begin
	accept_in <= accept_in_i;
	done <= done_i;

	address_dr_3_s <= (data_r1_3(9 downto 0) + ('0' & syllable_3(10 downto 2)));
	
	-- Synchronizes decoder states
	synchronize: process (clk, reset)
	begin
		if (reset = '1') then
			current_state <= reset_state;
		elsif (clk = '1' and clk'event) then
			current_state <= next_state;
		end if;
	end process synchronize;

	-- Controls outputs of decode stage
	decode_out: process(current_state, syllable_0, syllable_1, address_dr_3_s,
	                      data_r1_0, data_r2_0, data_rb_0, syllable_2, 
	                      syllable_3, data_r1_1, data_r2_1, data_rb_1, data_r1_2,
	                      data_r2_2, data_rb_2, data_r1_3, data_r2_3, data_rb_3)
	begin
		-------------------------
		-- syllable 0 handling --
		-------------------------
		opcode_0 <= (others => 'X');
		address_r1_0 <= (others => 'X');
		address_r2_0 <= (others => 'X');
		address_rb_0 <= (others => 'X');
		operand1_0 <= (others => 'X');
		operand2_0 <= (others => 'X');
		operandb_0 <= 'X';
		branch_dest_0 <= 'X';
		address_dest_0 <= (others => 'X');
		address_destb_0 <= (others => 'X');
		target_0 <= (others => 'X');
		address_dr_3 <= (others => 'X');
		address_off_3 <= (others => 'X');
		offset <= (others => 'X');

		-------------------------
		-- syllable 1 handling --
		-------------------------
		opcode_1 <= (others => 'X');
		address_r1_1 <= (others => 'X');
		address_r2_1 <= (others => 'X');
		address_rb_1 <= (others => 'X');
		operand1_1 <= (others => 'X');
		operand2_1 <= (others => 'X');
		operandb_1 <= 'X';
		branch_dest_1 <= 'X';
		address_dest_1 <= (others => 'X');
		address_destb_1 <= (others => 'X');
		target_1 <= (others => 'X');

		-------------------------
		-- syllable 2 handling --
		-------------------------
		opcode_2 <= (others => 'X');
		address_r1_2 <= (others => 'X');
		address_r2_2 <= (others => 'X');
		address_rb_2 <= (others => 'X');
		operand1_2 <= (others => 'X');
		operand2_2 <= (others => 'X');
		operandb_2 <= 'X';
		branch_dest_2 <= 'X';
		address_dest_2 <= (others => 'X');
		address_destb_2 <= (others => 'X');
		target_2 <= (others => 'X');

		-------------------------
		-- syllable 3 handling --
		-------------------------
		opcode_3 <= (others => 'X');
		address_r1_3 <= (others => 'X');
		address_r2_3 <= (others => 'X');
		address_rb_3 <= (others => 'X');
		operand1_3 <= (others => 'X');
		operand2_3 <= (others => 'X');
		operandb_3 <= 'X';
		branch_dest_3 <= 'X';
		address_dest_3 <= (others => 'X');
		address_destb_3 <= (others => 'X');
		target_3 <= (others => 'X');

		ops_ready <= 'X';

		case current_state is
			when reset_state =>
				-------------------------
				-- syllable 0 handling --
				-------------------------
				opcode_0 <= (others => '0');
				address_r1_0 <= (others => '0');
				address_r2_0 <= (others => '0');
				address_rb_0 <= (others => '0');
				operand1_0 <= (others => '0');
				operand2_0 <= (others => '0');
				operandb_0 <= '0';
				branch_dest_0 <= '0';
				address_dest_0 <= (others => '0');
				address_destb_0 <= (others => '0');
				target_0 <= (others => '0');
				address_dr_3 <= (others => '0');
				address_off_3 <= (others => '0');
				offset <= (others => '0');

				-------------------------
				-- syllable 1 handling --
				-------------------------
				opcode_1 <= (others => '0');
				address_r1_1 <= (others => '0');
				address_r2_1 <= (others => '0');
				address_rb_1 <= (others => '0');
				operand1_1 <= (others => '0');
				operand2_1 <= (others => '0');
				operandb_1 <= '0';
				branch_dest_1 <= '0';
				address_dest_1 <= (others => '0');
				address_destb_1 <= (others => '0');
				target_1 <= (others => '0');

				-------------------------
				-- syllable 2 handling --
				-------------------------
				opcode_2 <= (others => '0');
				address_r1_2 <= (others => '0');
				address_r2_2 <= (others => '0');
				address_rb_2 <= (others => '0');
				operand1_2 <= (others => '0');
				operand2_2 <= (others => '0');
				operandb_2 <= '0';
				branch_dest_2 <= '0';
				address_dest_2 <= (others => '0');
				address_destb_2 <= (others => '0');
				target_2 <= (others => '0');

				-------------------------
				-- syllable 3 handling --
				-------------------------
				opcode_3 <= (others => '0');
				address_r1_3 <= (others => '0');
				address_r2_3 <= (others => '0');
				address_rb_3 <= (others => '0');
				operand1_3 <= (others => '0');
				operand2_3 <= (others => '0');
				operandb_3 <= '0';
				branch_dest_3 <= '0';
				address_dest_3 <= (others => '0');
				address_destb_3 <= (others => '0');
				target_3 <= (others => '0');

				ops_ready <= '0';
				accept_in_i <= '0';
				done_i <= '0';
			when waiting =>
				target_0 <= (others => '0');
				target_1 <= (others => '0');
				target_2 <= (others => '0');
				target_3 <= (others => '0');
				
				ops_ready <= '0';
				accept_in_i <= '1';		
				done_i <= '0';
			when fetch_regs =>
				-------------------------
				-- syllable 0 handling --
				-------------------------
				opcode_0 <= syllable_0(31 downto 25);

				if (std_match(syllable_0(31 downto 25), CTRL_RETURN)) then
					address_r1_0 <= "000001"; -- stack pointer in $r0.1
				else
					address_r1_0 <= syllable_0(16 downto 11);
				end if;

				if (std_match(syllable_0(31 downto 25), CTRL_IGOTO) or 
				      std_match(syllable_0(31 downto 25), CTRL_ICALL) or 
				      std_match(syllable_0(31 downto 25), CTRL_RETURN)) then
					address_r2_0 <= syllable_0(22 downto 17);
				else
					address_r2_0 <= syllable_0(10 downto 5);
				end if;

				-- BR and BRF operations have the source BR register address
				-- on the location where normally the destination BR register
				-- address resides
				if (std_match(syllable_0(31 downto 25), CTRL_BR) or 
				      std_match(syllable_0(31 downto 25), CTRL_BRF)) then
					address_rb_0 <= syllable_0(4 downto 2);
				else
					address_rb_0 <= syllable_0(27 downto 25);
				end if;

				operand1_0 <= (others => '0');
				operand2_0 <= (others => '0');
				operandb_0 <= '0';
				branch_dest_0 <= '0';
				address_dest_0 <= syllable_0(22 downto 17);
				address_destb_0 <= syllable_0(4 downto 2);

				address_dr_3 <= address_dr_3_s(9 downto 2);
				address_off_3 <= address_dr_3_s(1 downto 0);
				target_0 <= (others => '0');
				offset <= (others => '0');

				-------------------------
				-- syllable 1 handling --
				-------------------------
				opcode_1 <= syllable_1(31 downto 25);
				address_r1_1 <= syllable_1(16 downto 11);
				address_r2_1 <= syllable_1(10 downto 5);
				address_rb_1 <= syllable_1(27 downto 25);
				operand1_1 <= (others => '0');
				operand2_1 <= (others => '0');
				operandb_1 <= '0';
				branch_dest_1 <= '0';
				address_dest_1 <= syllable_1(22 downto 17);
				address_destb_1 <= syllable_1(4 downto 2);
				target_1 <= (others => '0');

				-------------------------
				-- syllable 2 handling --
				-------------------------
				opcode_2 <= syllable_2(31 downto 25);
				address_r1_2 <= syllable_2(16 downto 11);
				address_r2_2 <= syllable_2(10 downto 5);
				address_rb_2 <= syllable_2(27 downto 25);
				operand1_2 <= (others => '0');
				operand2_2 <= (others => '0');
				operandb_2 <= '0';
				branch_dest_2 <= '0';
				address_dest_2 <= syllable_2(22 downto 17);
				address_destb_2 <= syllable_2(4 downto 2);
				target_2 <= (others => '0');

				-------------------------
				-- syllable 3 handling --
				-------------------------
				opcode_3 <= syllable_3(31 downto 25);
				address_r1_3 <= syllable_3(16 downto 11);

				if (std_match(syllable_3(31 downto 25), MEM_STW) or 
				      std_match(syllable_3(31 downto 25), MEM_STH) or 
				      std_match(syllable_3(31 downto 25), MEM_STB)) then
					address_r2_3 <= syllable_3(22 downto 17);
				else
					address_r2_3 <= syllable_3(10 downto 5);
				end if;

				address_rb_3 <= syllable_3(27 downto 25);
				operand1_3 <= (others => '0');
				operand2_3 <= (others => '0');
				operandb_3 <= '0';
				branch_dest_3 <= '0';
				address_dest_3 <= syllable_3(22 downto 17);
				address_destb_3 <= syllable_3(4 downto 2);
				target_3 <= (others => '0');

				ops_ready <= '0';
				accept_in_i <= '0';			
				done_i <= '0';
			when send_operands =>
				-------------------------
				-- syllable 0 handling --
				-------------------------
				opcode_0 <= syllable_0(31 downto 25);

				if (std_match(syllable_0(31 downto 25), CTRL_RETURN)) then
					address_r1_0 <= "000001"; -- stack pointer in $r0.1
				else
					address_r1_0 <= syllable_0(16 downto 11);
				end if;

				if (std_match(syllable_0(31 downto 25), CTRL_IGOTO) or 
				      std_match(syllable_0(31 downto 25), CTRL_ICALL) or 
				      std_match(syllable_0(31 downto 25), CTRL_RETURN)) then
					address_r2_0 <= syllable_0(22 downto 17);
				else
					address_r2_0 <= syllable_0(10 downto 5);
				end if;

				-- BR and BRF operations have the source BR register address
				-- on the location where normally the destination BR register
				-- address resides
				if (std_match(syllable_0(31 downto 25), CTRL_BR) or 
				      std_match(syllable_0(31 downto 25), CTRL_BRF)) then
					address_rb_0 <= syllable_0(4 downto 2);
				else
					address_rb_0 <= syllable_0(27 downto 25);
				end if;

				operand1_0 <= data_r1_0;

				-- operand type check (immediate or register value)
				case (syllable_0(24 downto 23)) is
					when SHORT_IMM =>
						operand2_0(31 downto 9) <= (others => '0');
						operand2_0(8 downto 0) <= syllable_0(10 downto 2);
					when BRANCH_IMM =>
						operand2_0(31 downto 12) <= (others => '0');
						operand2_0(11 downto 0) <= syllable_0(16 downto 5);
					when others =>
						operand2_0 <= data_r2_0;
				end case;

				operandb_0 <= data_rb_0;
				address_dest_0 <= syllable_0(22 downto 17);
				address_destb_0 <= syllable_0(4 downto 2);

				if (std_match(syllable_0(31 downto 25), ALU_ADDCG) or 
				      std_match(syllable_0(31 downto 25), ALU_DIVS)) then
					-- ALU operation with BR and GR dest
					target_0 <= WRITE_G_B;
					done_i <= '0';
					branch_dest_0 <= '0';
				elsif (std_match(syllable_0(31 downto 25), ALU_MTB)) then
					-- ALU operation with BR dest
					target_0 <= WRITE_B;
					done_i <= '0';
					branch_dest_0 <= '0';
				elsif (std_match(syllable_0(31 downto 25), NOP)) then
					-- NOP (no) operation
					target_0 <= "000";
					done_i <= '0';
					branch_dest_0 <= '0';
				elsif (std_match(syllable_0(31 downto 25), STOP)) then
					-- STOP operation
					target_0 <= "000";
					done_i <= '1';
					branch_dest_0 <= '0';
				elsif (std_match(syllable_0(31 downto 25), CTRL_OP)) then
					-- CTRL operation
					done_i <= '0';
					branch_dest_0 <= '0';
					
					if (std_match(syllable_0(31 downto 25), CTRL_RETURN) or
					      std_match(syllable_0(31 downto 25), CTRL_CALL) or
					      std_match(syllable_0(31 downto 25), CTRL_ICALL)) then
						target_0 <= WRITE_P_G;
					else
						target_0 <= WRITE_P;
					end if;
				elsif (syllable_0(31 downto 25) >= ALU_CMPEQ and 
				         syllable_0(31 downto 25) <= ALU_ANDL) then
					-- ALU operation with BR or GR dest
					done_i <= '0';
					
					if (syllable_0(22 downto 17) = "000000") then
						branch_dest_0 <= '1';
						target_0 <= WRITE_B;
					else
						branch_dest_0 <= '0';
						target_0 <= WRITE_G;
					end if;
				else -- normal ALU or MUL operation
					branch_dest_0 <= '0';
					target_0 <= WRITE_G;
					done_i <= '0';
				end if;

				-- offset input is used for overloading in ICALL and IGOTO	
				case (syllable_0(31 downto 25)) is
					when CTRL_ICALL =>
						offset <= data_r2_0(11 downto 0);
						address_dest_0 <= syllable_0(22 downto 17);
					when CTRL_IGOTO =>
						offset <= data_r2_0(11 downto 0);
						address_dest_0 <= syllable_0(22 downto 17);
					when CTRL_RETURN =>
						offset <= syllable_0(16 downto 5);
						address_dest_0 <= "000001";
					when others =>
						offset <= syllable_0(16 downto 5);
						address_dest_0 <= syllable_0(22 downto 17);
				end case;
				
				address_dr_3 <= address_dr_3_s(9 downto 2);
				address_off_3 <= address_dr_3_s(1 downto 0);

				-------------------------
				-- syllable 1 handling --
				-------------------------
				opcode_1 <= syllable_1(31 downto 25);
				address_r1_1 <= syllable_1(16 downto 11);
				address_r2_1 <= syllable_1(10 downto 5);
				address_rb_1 <= syllable_1(27 downto 25);
				operand1_1 <= data_r1_1;

				-- operand type check (immediate or register value)
				case (syllable_1(24 downto 23)) is
					when SHORT_IMM =>
						operand2_1(31 downto 9) <= (others => '0');
						operand2_1(8 downto 0) <= syllable_1(10 downto 2);
					when others =>
						operand2_1 <= data_r2_1;
				end case;

				operandb_1 <= data_rb_1;
				address_dest_1 <= syllable_1(22 downto 17);
				address_destb_1 <= syllable_1(4 downto 2);

				if (std_match(syllable_1(31 downto 25), ALU_ADDCG) or
				      std_match(syllable_1(31 downto 25), ALU_DIVS)) then
					-- ALU operation with BR and GR dest
					target_1 <= WRITE_G_B;
					branch_dest_1 <= '0';
				elsif (std_match(syllable_1(31 downto 25), ALU_MTB)) then
					-- ALU operation with BR dest
					target_1 <= WRITE_B;
					branch_dest_1 <= '0';
				elsif (syllable_1(31 downto 25) >= ALU_CMPEQ and 
				         syllable_1(31 downto 25) <= ALU_ANDL) then
					-- ALU operation with BR or GR dest					
					if (syllable_1(22 downto 17) = "000000") then
						branch_dest_1 <= '1';
						target_1 <= WRITE_B;
					else
						branch_dest_1 <= '0';
						target_1 <= WRITE_G;
					end if;
				elsif (syllable_1(31 downto 25) = NOP) then
					branch_dest_1 <= '0';
					target_1 <= WRITE_NOP;
				else -- normal ALU operation
					branch_dest_1 <= '0';
					target_1 <= WRITE_G;
				end if;

				-------------------------
				-- syllable 2 handling --
				-------------------------
				opcode_2 <= syllable_2(31 downto 25);
				address_r1_2 <= syllable_2(16 downto 11);
				address_r2_2 <= syllable_2(10 downto 5);
				address_rb_2 <= syllable_2(27 downto 25);
				operand1_2 <= data_r1_2;

				-- operand type check (immediate or register value)
				case (syllable_2(24 downto 23)) is
					when SHORT_IMM =>
						operand2_2(31 downto 9) <= (others => '0');
						operand2_2(8 downto 0) <= syllable_2(10 downto 2);
					when others =>
						operand2_2 <= data_r2_2;
				end case;

				operandb_2 <= data_rb_2;
				address_dest_2 <= syllable_2(22 downto 17);
				address_destb_2 <= syllable_2(4 downto 2);

				if (std_match(syllable_2(31 downto 25), ALU_ADDCG) or
				      std_match(syllable_2(31 downto 25), ALU_DIVS)) then
					-- ALU operation with BR and GR dest
					target_2 <= WRITE_G_B;
					branch_dest_2 <= '0';
				elsif (std_match(syllable_2(31 downto 25), ALU_MTB)) then
					-- ALU operation with BR dest
					target_2 <= WRITE_B;
					branch_dest_2 <= '0';
				elsif (syllable_2(31 downto 25) >= ALU_CMPEQ and
				         syllable_2(31 downto 25) <= ALU_ANDL) then
					-- ALU operation with BR or GR dest					
					if (syllable_2(22 downto 17) = "000000") then
						branch_dest_2 <= '1';
						target_2 <= WRITE_B;
					else
						branch_dest_2 <= '0';
						target_2 <= WRITE_G;
					end if;
				elsif (syllable_2(31 downto 25) = NOP) then
					branch_dest_2 <= '0';
					target_2 <= WRITE_NOP;
				else
					-- normal ALU or MUL operation
					branch_dest_2 <= '0';
					target_2 <= WRITE_G;
				end if;
	
				-------------------------
				-- syllable 3 handling --
				-------------------------
				opcode_3 <= syllable_3(31 downto 25);
				address_r1_3 <= syllable_3(16 downto 11);

				if (std_match(syllable_3(31 downto 25), MEM_STW) or
				      std_match(syllable_3(31 downto 25), MEM_STH) or
					  std_match(syllable_3(31 downto 25), MEM_STB)) then
					address_r2_3 <= syllable_3(22 downto 17);
				else
					address_r2_3 <= syllable_3(10 downto 5);
				end if;

				address_rb_3 <= syllable_3(27 downto 25);
				operand1_3 <= data_r1_3;

				-- operand type check (immediate or register value)
				case (syllable_3(24 downto 23)) is
					when SHORT_IMM =>
						operand2_3(31 downto 9) <= (others => '0');
						operand2_3(8 downto 0) <= syllable_3(10 downto 2);
					when others =>
						operand2_3 <= data_r2_3;
				end case;

				operandb_3 <= data_rb_3;
				address_dest_3 <= syllable_3(22 downto 17);
				address_destb_3 <= syllable_3(4 downto 2);

				if (std_match(syllable_3(31 downto 25), ALU_ADDCG) or
				      std_match(syllable_3(31 downto 25), ALU_DIVS)) then
					-- ALU operation with BR and GR dest
					target_3 <= WRITE_G_B;
					branch_dest_3 <= '0';
				elsif (std_match(syllable_3(31 downto 25), ALU_MTB)) then
					-- ALU operation with BR dest
					target_3 <= WRITE_B;
					branch_dest_3 <= '0';
				elsif (syllable_3(31 downto 25) >= ALU_CMPEQ and
				         syllable_3(31 downto 25) <= ALU_ANDL) then
					-- ALU operation with BR or GR dest					
					if (syllable_3(22 downto 17) = "000000") then
						branch_dest_3 <= '1';
						target_3 <= WRITE_B;
					else
						branch_dest_3 <= '0';
						target_3 <= WRITE_G;
					end if;
				elsif (syllable_3(31 downto 25) = NOP) then
					branch_dest_3 <= '0';
					target_3 <= WRITE_NOP;
				elsif (std_match(syllable_3(31 downto 25), MEM_OP)) then
					-- MEM operation
					branch_dest_0 <= '0';
					
					if (std_match(syllable_3(31 downto 25), MEM_STW) or
					      std_match(syllable_3(31 downto 25), MEM_STH) or
					      std_match(syllable_3(31 downto 25), MEM_STB)) then
						-- MEM STORE operation
						target_3 <= WRITE_M;
					else
						-- MEM LOAD operation
						target_3 <= WRITE_MG;
					end if;
				else
					-- normal ALU operation
					branch_dest_3 <= '0';
					target_3 <= WRITE_G;
				end if;

				ops_ready <= '1';
				accept_in_i <= '0';			
		end case;
	end process decode_out;

	-- Controls syllable decode states
	decode_control: process(clk, current_state, fetch_ok, new_decode, start)
	begin
		case current_state is
			when reset_state =>			
				next_state <= waiting;
			when waiting =>
				if (fetch_ok = '1') then
					next_state <= fetch_regs;
				else
					next_state <= waiting;
				end if;
			when fetch_regs =>
				next_state <= send_operands;
			when send_operands =>
				if (new_decode = '1' and start = '1') then
					next_state <= waiting;
				else
					next_state <= send_operands;
				end if;
		end case;
	end process decode_control;	
end architecture behavioural;

