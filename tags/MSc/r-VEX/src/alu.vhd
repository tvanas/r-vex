--------------------------------------------------------------------------------
--  r-VEX | Arithmetic Logic Unit
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
-- alu.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;
use work.alu_operations.all;

entity alu is
	port ( clk       : in std_logic;   -- system clock
	       reset     : in std_logic;   -- system reset
	       aluop     : in std_logic_vector(6 downto 0);   -- opcode
	       src1      : in std_logic_vector(31 downto 0);  -- operand 1
	       src2      : in std_logic_vector(31 downto 0);  -- operand 2
	       cin       : in std_logic;   -- carry input

	       result    : out std_logic_vector(31 downto 0); -- result of operation
	       cout      : out std_logic;  -- carry output
	       out_valid : out std_logic); -- '1' when output is valid
end entity alu;


architecture behavioural of alu is
	signal result_i : std_logic_vector(31 downto 0) := (others => '0');
	signal cout_i   : std_logic := '0';
begin
	result <= result_i;
	cout <= cout_i;

	-- Controls ALU operations
	alu_control : process(clk, reset)
	begin
		if (reset = '1') then
			out_valid <= '0';
			result_i <= (others => '0');
			cout_i <= '0';
		elsif (clk = '1' and clk'event) then
			out_valid <= '1';     -- this will be overriden when a non-existent opcode is issued
			
			if std_match(aluop, ALU_ADD) then
				result_i <= f_ADD (src1, src2);
			elsif std_match(aluop, ALU_ADDCG) then
				f_ADDCG (src1, src2, cin, result_i, cout_i);
			elsif std_match(aluop, ALU_AND) then
				result_i <= f_AND (src1, src2);
			elsif std_match(aluop, ALU_ANDC) then
				result_i <= f_ANDC (src1, src2);
			elsif std_match(aluop, ALU_DIVS) then
				f_DIVS (src1, src2, cin, result_i, cout_i);
			elsif std_match(aluop, ALU_MAX) then
				result_i <= f_MAX (src1, src2);
			elsif std_match(aluop, ALU_MAXU) then
				result_i <= f_MAXU (src1, src2);
			elsif std_match(aluop, ALU_MIN) then
				result_i <= f_MIN (src1, src2);
			elsif std_match(aluop, ALU_MINU) then
				result_i <= f_MINU (src1, src2);
			elsif std_match(aluop, ALU_OR) then
				result_i <= f_OR (src1, src2);
			elsif std_match(aluop, ALU_ORC) then
				result_i <= f_ORC (src1, src2);
			elsif std_match(aluop, ALU_SH1ADD) then
				result_i <= f_SH1ADD (src1, src2);
			elsif std_match(aluop, ALU_SH2ADD) then
				result_i <= f_SH2ADD (src1, src2);
			elsif std_match(aluop, ALU_SH3ADD) then
				result_i <= f_SH3ADD (src1, src2);
			elsif std_match(aluop, ALU_SH4ADD) then
				result_i <= f_SH4ADD (src1, src2);
			elsif std_match(aluop, ALU_SHL) then
				result_i <= f_SHL (src1, src2);
			elsif std_match(aluop, ALU_SHR) then
				result_i <= f_SHR (src1, src2);
			elsif std_match(aluop, ALU_SHRU) then
				result_i <= f_SHRU (src1, src2);
			elsif std_match(aluop, ALU_SUB) then
				result_i <= f_SUB (src1, src2);
			elsif std_match(aluop, ALU_SXTB) then
				result_i <= f_SXTB (src1);
			elsif std_match(aluop, ALU_SXTH) then
				result_i <= f_SXTH (src1);
			elsif std_match(aluop, ALU_ZXTB) then
				result_i <= f_ZXTB (src1);
			elsif std_match(aluop, ALU_ZXTH) then
				result_i <= f_ZXTH (src1);
			elsif std_match(aluop, ALU_XOR) then
				result_i <= f_XOR (src1, src2);
			elsif std_match(aluop, ALU_CMPEQ) then
				result_i <= f_CMPEQ (src1, src2);
			elsif std_match(aluop, ALU_CMPGE) then
				result_i <= f_CMPGE (src1, src2);
			elsif std_match(aluop, ALU_CMPGEU) then
				result_i <= f_CMPGEU (src1, src2);
			elsif std_match(aluop, ALU_CMPGT) then
				result_i <= f_CMPGT (src1, src2);
			elsif std_match(aluop, ALU_CMPGTU) then
				result_i <= f_CMPGTU (src1, src2);
			elsif std_match(aluop, ALU_CMPLE) then
				result_i <= f_CMPLE (src1, src2);
			elsif std_match(aluop, ALU_CMPLEU) then
				result_i <= f_CMPLEU (src1, src2);
			elsif std_match(aluop, ALU_CMPLT) then
				result_i <= f_CMPLT (src1, src2);
			elsif std_match(aluop, ALU_CMPLTU) then
				result_i <= f_CMPLTU (src1, src2);
			elsif std_match(aluop, ALU_CMPNE) then
				result_i <= f_CMPNE (src1, src2);
			elsif std_match(aluop, ALU_NANDL) then
				result_i <= f_NANDL (src1, src2);
			elsif std_match(aluop, ALU_NORL) then
				result_i <= f_NORL (src1, src2);
			elsif std_match(aluop, ALU_ORL) then
				result_i <= f_ORL (src1, src2);
			elsif std_match(aluop, ALU_SLCT) then
				result_i <= f_SLCT (src1, src2, cin);
			elsif std_match(aluop, ALU_SLCTF) then
				result_i <= f_SLCTF (src1, src2, cin);
			elsif std_match(aluop, ALU_MOV) then
				result_i <= src1;
			elsif std_match(aluop, ALU_ANDL) then
				result_i <= f_ANDL (src1, src2);
			elsif std_match(aluop, ALU_MTB) then
				cout_i   <= src1(0); 
			else
				out_valid <= '0';
			end if;
		end if;
	end process alu_control;
end architecture behavioural;
