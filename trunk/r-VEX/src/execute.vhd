--------------------------------------------------------------------------------
-- r-VEX | Execute stage
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
-- execute.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity execute is
	port ( clk           : in std_logic; -- system clock
	       reset         : in std_logic; -- system reset
	       in_valid      : in std_logic; -- '1' when input is valid
	       -- syllable 0 related inputs
	       opcode_0      : in std_logic_vector(6 downto 0);  -- opcode
	       operand1_0    : in std_logic_vector(31 downto 0); -- operand 1
	       operand2_0    : in std_logic_vector(31 downto 0); -- operand 2
	       operandb_0    : in std_logic;                     -- branch operand
	       branch_dest_0 : in std_logic;                     -- '1' when BR is destination
	       -- syllable 1 related inputs
	       opcode_1      : in std_logic_vector(6 downto 0);  -- opcode
	       operand1_1    : in std_logic_vector(31 downto 0); -- operand 1
	       operand2_1    : in std_logic_vector(31 downto 0); -- operand 2
	       operandb_1    : in std_logic;                     -- branch operand
	       branch_dest_1 : in std_logic;                     -- '1' when BR is destination
	       -- syllable 2 related inputs
	       opcode_2      : in std_logic_vector(6 downto 0);  -- opcode
	       operand1_2    : in std_logic_vector(31 downto 0); -- operand 1
	       operand2_2    : in std_logic_vector(31 downto 0); -- operand 2
	       operandb_2    : in std_logic;                     -- branch operand
	       branch_dest_2 : in std_logic;                     -- '1' when BR is destination
	       -- syllable 3 related inputs
	       opcode_3      : in std_logic_vector(6 downto 0);  -- opcode 
	       operand1_3    : in std_logic_vector(31 downto 0); -- operand 1
	       operand2_3    : in std_logic_vector(31 downto 0); -- operand 2
	       operandb_3    : in std_logic;                     -- branch operand
	       branch_dest_3 : in std_logic;                     -- '1' when BR is destination

	       -- syllable 0 related outputs
	       result_0      : out std_logic_vector(31 downto 0); -- result of ALU or MUL operation
	       resultb_0     : out std_logic;                     -- branch result of ALU or MUL operation
	       -- syllable 1 related outputs
	       result_1      : out std_logic_vector(31 downto 0); -- result of ALU or MUL operation
	       resultb_1     : out std_logic;                     -- branch result of ALU or MUL operation
	       -- syllable 2 related outputs
	       result_2      : out std_logic_vector(31 downto 0); -- result of ALU or MUL operation
	       resultb_2     : out std_logic;                     -- branch result of ALU or MUL operation
	       -- syllable 3 related outputs
	       result_3      : out std_logic_vector(31 downto 0); -- result of ALU or MUL operation
	       resultb_3     : out std_logic;                     -- branch result of ALU or MUL operation

	       out_valid     : out std_logic); -- '1' when results are valid
end entity execute;


architecture behavioural of execute is
	-- Arithmetic Logic Unit
	component alu is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       aluop     : in std_logic_vector(6 downto 0);
		       src1      : in std_logic_vector(31 downto 0);
		       src2      : in std_logic_vector(31 downto 0);
		       cin       : in std_logic;

		       result    : out std_logic_vector(31 downto 0);
		       cout      : out std_logic;
		       out_valid : out std_logic);
	end component alu;

	-- Multiplier unit
	component mul is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       mulop     : in std_logic_vector(6 downto 0);
		       src1      : in std_logic_vector(31 downto 0);
		       src2      : in std_logic_vector(31 downto 0);

		       result    : out std_logic_vector(31 downto 0);
		       overflow  : out std_logic;
		       out_valid : out std_logic);
	end component mul;

	-- syllable 0 related signals
	signal opcode_0_s         : std_logic_vector(6 downto 0) := (others => '0');	
	signal operand1_0_s       : std_logic_vector(31 downto 0);
	signal operand2_0_s       : std_logic_vector(31 downto 0);
	signal operandb_0_s       : std_logic := '0';
	signal alu0_result_s      : std_logic_vector(31 downto 0);
	signal alu0_cout_s        : std_logic := '0';
	signal alu0_out_valid_s   : std_logic := '0';
	-- syllable 1 related signals
	signal opcode_1_s         : std_logic_vector(6 downto 0) := (others => '0');
	signal operand1_1_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_1_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operandb_1_s       : std_logic := '0';
	signal alu1_result_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal alu1_cout_s        : std_logic := '0';
	signal alu1_out_valid_s   : std_logic := '0';
	signal mul1_result_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal mul1_overflow_s    : std_logic := '0';
	signal mul1_out_valid_s   : std_logic := '0';
	-- syllable 2 related signals
	signal opcode_2_s         : std_logic_vector(6 downto 0) := (others => '0');
	signal operand1_2_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_2_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operandb_2_s       : std_logic := '0';
	signal alu2_result_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal alu2_cout_s        : std_logic := '0';
	signal alu2_out_valid_s   : std_logic := '0';
	signal mul2_result_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal mul2_overflow_s    : std_logic := '0';
	signal mul2_out_valid_s   : std_logic := '0';
	-- syllable 3 related signals
	signal opcode_3_s         : std_logic_vector(6 downto 0) := (others => '0');
	signal operand1_3_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_3_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operandb_3_s       : std_logic := '0';
	signal alu3_result_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal alu3_cout_s        : std_logic := '0';
	signal alu3_out_valid_s   : std_logic := '0';
	
	type execute_states is (reset_state, waiting, wait_mul, execute, output);
	signal current_state, next_state : execute_states;
begin
	alu0 : alu port map (clk => clk,
	                     reset => reset,
	                     aluop => opcode_0_s,
	                     src1 => operand1_0_s,
	                     src2 => operand2_0_s,
	                     cin => operandb_0_s,
	                     
	                     result => alu0_result_s,
	                     cout => alu0_cout_s,
	                     out_valid => alu0_out_valid_s);

	alu1 : alu port map (clk => clk,
	                     reset => reset,
	                     aluop => opcode_1_s,
	                     src1 => operand1_1_s,
	                     src2 => operand2_1_s,
	                     cin => operandb_1_s,
	                     
	                     result => alu1_result_s,
	                     cout => alu1_cout_s,
	                     out_valid => alu1_out_valid_s);
	
	alu2 : alu port map (clk => clk,
	                     reset => reset,
	                     aluop => opcode_2_s,
	                     src1 => operand1_2_s,
	                     src2 => operand2_2_s,
	                     cin => operandb_2_s,
	                     
	                     result => alu2_result_s,
	                     cout => alu2_cout_s,
	                     out_valid => alu2_out_valid_s);
	
	alu3 : alu port map (clk => clk,
	                     reset => reset,
	                     aluop => opcode_3_s,
	                     src1 => operand1_3_s,
	                     src2 => operand2_3_s,
	                     cin => operandb_3_s,
	                     
	                     result => alu3_result_s,
	                     cout => alu3_cout_s,
	                     out_valid => alu3_out_valid_s);
	
	mul1 : mul port map (clk => clk,
	                     reset => reset,
	                     mulop => opcode_1_s,
	                     src1 => operand1_1_s,
	                     src2 => operand2_1_s,
						 
	                     result => mul1_result_s,
	                     overflow => mul1_overflow_s,
	                     out_valid => mul1_out_valid_s);

	mul2 : mul port map (clk => clk,
	                     reset => reset,
	                     mulop => opcode_2_s,
	                     src1 => operand1_2_s,
	                     src2 => operand2_2_s,
						 
	                     result => mul2_result_s,
	                     overflow => mul2_overflow_s,
	                     out_valid => mul2_out_valid_s);
	
	-- Synchronizes execute states
	execute_sync : process(clk, reset)
	begin
		if (reset = '1') then
			current_state <= reset_state;
		elsif (clk = '1' and clk'event) then
			current_state <= next_state;
		end if;
	end process execute_sync;
	
	-- Controls outputs of execute stage
	execute_output : process(current_state, branch_dest_0, alu0_result_s,
	                           alu0_cout_s, mul2_result_s, alu0_out_valid_s,
	                           mul2_out_valid_s, alu1_result_s, alu1_cout_s,
	                           mul1_result_s, alu1_out_valid_s, mul1_out_valid_s,
	                           opcode_0, opcode_1, operand1_0, operand2_0,
	                           operandb_0, operand1_1, operand2_1, operandb_1,
	                           opcode_2, operand1_2, operand2_2, operandb_2,
	                           opcode_3, operand1_3, operand2_3, operandb_3,
	                           branch_dest_1, alu2_result_s, branch_dest_2,
	                           alu2_cout_s, alu3_result_s, branch_dest_3,
	                           alu3_cout_s)
	begin
		out_valid <= 'X';

		-------------------------
		-- syllable 0 handling --
		-------------------------
		opcode_0_s <= (others => 'X');
		operand1_0_s <= (others => 'X');
		operand2_0_s <= (others => 'X');
		operandb_0_s <= 'X';

		-------------------------
		-- syllable 1 handling --
		-------------------------
		opcode_1_s <= (others => 'X');
		operand1_1_s <= (others => 'X');
		operand2_1_s <= (others => 'X');
		operandb_1_s <= 'X';

		-------------------------
		-- syllable 2 handling --
		-------------------------
		opcode_2_s <= (others => 'X');
		operand1_2_s <= (others => 'X');
		operand2_2_s <= (others => 'X');
		operandb_2_s <= 'X';

		-------------------------
		-- syllable 3 handling --
		-------------------------
		opcode_3_s <= (others => 'X');
		operand1_3_s <= (others => 'X');
		operand2_3_s <= (others => 'X');
		operandb_3_s <= 'X';
		
		case current_state is
			when reset_state =>
				out_valid <= '0';

				-------------------------
				-- syllable 0 handling --
				-------------------------
				result_0 <= (others => '0');
				resultb_0 <= '0';
				opcode_0_s <= "0000000";
				operand1_0_s <= (others => '0');
				operand2_0_s <= (others => '0');
				operandb_0_s <= '0';

				-------------------------
				-- syllable 1 handling --
				-------------------------
				result_1 <= (others => '0');
				resultb_1 <= '0';
				opcode_1_s <= "0000000";
				operand1_1_s <= (others => '0');
				operand2_1_s <= (others => '0');
				operandb_1_s <= '0';

				-------------------------
				-- syllable 2 handling --
				-------------------------
				result_2 <= (others => '0');
				resultb_2 <= '0';
				opcode_2_s <= "0000000";
				operand1_2_s <= (others => '0');
				operand2_2_s <= (others => '0');
				operandb_2_s <= '0';

				-------------------------
				-- syllable 3 handling --
				-------------------------
				result_3 <= (others => '0');
				resultb_3 <= '0';
				opcode_3_s <= "0000000";
				operand1_3_s <= (others => '0');
				operand2_3_s <= (others => '0');
				operandb_3_s <= '0';
			when waiting =>
				out_valid <= '0';		

				-------------------------
				-- syllable 0 handling --
				-------------------------
				result_0 <= (others => 'X');
				resultb_0 <= 'X';
				opcode_0_s <= opcode_0;
				operand1_0_s <= operand1_0;
				operand2_0_s <= operand2_0;
				operandb_0_s <= operandb_0;

				-------------------------
				-- syllable 1 handling --
				-------------------------
				result_1 <= (others => 'X');
				resultb_1 <= 'X';
				opcode_1_s <= opcode_1;
				operand1_1_s <= operand1_1;
				operand2_1_s <= operand2_1;
				operandb_1_s <= operandb_1;

				-------------------------
				-- syllable 2 handling --
				-------------------------
				result_2 <= (others => 'X');
				resultb_2 <= 'X';
				opcode_2_s <= opcode_2;
				operand1_2_s <= operand1_2;
				operand2_2_s <= operand2_2;
				operandb_2_s <= operandb_2;

				-------------------------
				-- syllable 3 handling --
				-------------------------
				result_3 <= (others => 'X');
				resultb_3 <= 'X';
				opcode_3_s <= opcode_3;
				operand1_3_s <= operand1_3;
				operand2_3_s <= operand2_3;
				operandb_3_s <= operandb_3;
			when wait_mul =>
				out_valid <= '0';

				-------------------------
				-- syllable 0 handling --
				-------------------------
				result_0 <= alu0_result_s;
				
				if (branch_dest_0 = '1') then
					resultb_0 <= alu0_result_s(0);
				else
					resultb_0 <= alu0_cout_s;
				end if;

				opcode_0_s <= opcode_0;
				operand1_0_s <= operand1_0;
				operand2_0_s <= operand2_0;
				operandb_0_s <= operandb_0;

				-------------------------
				-- syllable 1 handling --
				-------------------------
				if (std_match(opcode_1, MUL_OP)) then
					result_1 <= mul1_result_s;
				else
					result_1 <= alu1_result_s;
				end if;
				
				if (branch_dest_1 = '1') then
					resultb_1 <= alu1_result_s(0);
				else
					resultb_1 <= alu1_cout_s;
				end if;

				opcode_1_s <= opcode_1;
				operand1_1_s <= operand1_1;
				operand2_1_s <= operand2_1;
				operandb_1_s <= operandb_1;

				-------------------------
				-- syllable 2 handling --
				-------------------------
				if (std_match(opcode_2, MUL_OP)) then
					result_2 <= mul2_result_s;
				else
					result_2 <= alu2_result_s;
				end if;
				
				if (branch_dest_2 = '1') then
					resultb_2 <= alu2_result_s(0);
				else
					resultb_2 <= alu2_cout_s;
				end if;

				opcode_2_s <= opcode_2;
				operand1_2_s <= operand1_2;
				operand2_2_s <= operand2_2;
				operandb_2_s <= operandb_2;

				-------------------------
				-- syllable 3 handling --
				-------------------------
				result_3 <= alu3_result_s;
				
				if (branch_dest_3 = '1') then
					resultb_3 <= alu3_result_s(0);
				else
					resultb_3 <= alu3_cout_s;
				end if;

				opcode_3_s <= opcode_3;
				operand1_3_s <= operand1_3;
				operand2_3_s <= operand2_3;
				operandb_3_s <= operandb_3;
			when execute =>
				out_valid <= '1';

				-------------------------
				-- syllable 0 handling --
				-------------------------
				result_0 <= alu0_result_s;
				
				if (branch_dest_0 = '1') then
					resultb_0 <= alu0_result_s(0);
				else
					resultb_0 <= alu0_cout_s;
				end if;

				opcode_0_s <= opcode_0;
				operand1_0_s <= operand1_0;
				operand2_0_s <= operand2_0;
				operandb_0_s <= operandb_0;

				-------------------------
				-- syllable 1 handling --
				-------------------------
				if (std_match(opcode_1, MUL_OP)) then
					result_1 <= mul1_result_s;
				else
					result_1 <= alu1_result_s;
				end if;
				
				if (branch_dest_1 = '1') then
					resultb_1 <= alu1_result_s(0);
				else
					resultb_1 <= alu1_cout_s;
				end if;

				opcode_1_s <= opcode_1;
				operand1_1_s <= operand1_1;
				operand2_1_s <= operand2_1;
				operandb_1_s <= operandb_1;

				-------------------------
				-- syllable 2 handling --
				-------------------------
				if (std_match(opcode_2, MUL_OP)) then
					result_2 <= mul2_result_s;
				else
					result_2 <= alu2_result_s;
				end if;
				
				if (branch_dest_2 = '1') then
					resultb_2 <= alu2_result_s(0);
				else
					resultb_2 <= alu2_cout_s;
				end if;

				opcode_2_s <= opcode_2;
				operand1_2_s <= operand1_2;
				operand2_2_s <= operand2_2;
				operandb_2_s <= operandb_2;

				-------------------------
				-- syllable 3 handling --
				-------------------------
				result_3 <= alu3_result_s;
				
				if (branch_dest_3 = '1') then
					resultb_3 <= alu3_result_s(0);
				else
					resultb_3 <= alu3_cout_s;
				end if;

				opcode_3_s <= opcode_3;
				operand1_3_s <= operand1_3;
				operand2_3_s <= operand2_3;
				operandb_3_s <= operandb_3;
			when output =>
				out_valid <= '1';

				-------------------------
				-- syllable 0 handling --
				-------------------------
				result_0 <= alu0_result_s;
			
				if (branch_dest_0 = '1') then
					resultb_0 <= alu0_result_s(0);
				else
					resultb_0 <= alu0_cout_s;
				end if;

				-------------------------
				-- syllable 1 handling --
				-------------------------
				if (std_match(opcode_1, MUL_OP)) then
					result_1 <= mul1_result_s;
				else
					result_1 <= alu1_result_s;
				end if;
				
				if (branch_dest_1 = '1') then
					resultb_1 <= alu1_result_s(0);
				else
					resultb_1 <= alu1_cout_s;
				end if;

				-------------------------
				-- syllable 2 handling --
				-------------------------
				if (std_match(opcode_2, MUL_OP)) then
					result_2 <= mul2_result_s;
				else
					result_2 <= alu2_result_s;
				end if;			
				if (branch_dest_2 = '1') then
					resultb_2 <= alu2_result_s(0);
				else
					resultb_2 <= alu2_cout_s;
				end if;

				-------------------------
				-- syllable 3 handling --
				-------------------------
				result_3 <= alu3_result_s;
			
				if (branch_dest_3 = '1') then
					resultb_3 <= alu3_result_s(0);
				else
					resultb_3 <= alu3_cout_s;
				end if;
		end case;
	end process execute_output;
	
	-- Controls execute stage
	execute_control : process(clk, current_state, in_valid, alu0_out_valid_s,
	                            alu1_out_valid_s, opcode_0, opcode_1, opcode_2,
	                            opcode_3, alu2_out_valid_s, alu3_out_valid_s)
	begin
		case current_state is
			when reset_state =>
				next_state <= waiting;
			when waiting =>
				if (in_valid = '1') then
					if (opcode_0(6) = '1' or std_match(opcode_0, ALU_SLCT)
					      or std_match(opcode_0, ALU_SLCTF) or opcode_1(6) = '1'
					      or std_match(opcode_1, ALU_SLCT)
					      or std_match(opcode_1, ALU_SLCTF)
					      or opcode_2(6) = '1' or std_match(opcode_2, ALU_SLCT)
					      or std_match(opcode_2, ALU_SLCTF) or opcode_3(6) = '1'
					      or std_match(opcode_3, ALU_SLCT)
					      or std_match(opcode_3, ALU_SLCTF)) then
						-- ALU operation
						next_state <= execute;
					elsif ((std_match(opcode_1, MUL_OP) and not std_match(opcode_1, NOP)) or
					         (std_match(opcode_2, MUL_OP) and not std_match(opcode_1, NOP))) then
						next_state <= wait_mul;
					else
						next_state <= waiting;
					end if;
				else
					next_state <= waiting;
				end if;
			when wait_mul =>
				next_state <= execute;
			when execute =>
				next_state <= output;
			when output =>
				next_state <= waiting;
		end case;
	end process execute_control;
end architecture behavioural;

