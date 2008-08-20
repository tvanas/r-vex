--------------------------------------------------------------------------------
-- r-VEX | Package with common definitions and opcodes
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
-- r-vex_pkg.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

package rVEX_pkg is
	--------------------------------------------------------------------------------
	-- Common definitions
	--------------------------------------------------------------------------------
	-- Active low/high logic on FPGA board
	constant ACTIVE_LOW  : std_logic := '1';							-- '1' for Virtex-II Pro board, '0' for Spartan-3E board 
	
	-- Register file definitions
	constant GR_DEPTH    : integer := 32;                               -- Depth of general purpose register file
	constant BR_DEPTH    : integer := 8;                                -- Depth of branch register file

	-- Memory address definitions
	constant ADDR_WIDTH  : integer := 8;                                -- Width of the instruction memory address vector
	constant BROFF_WIDTH : integer := 12;                               -- Width of branch offset immediate values
	constant DMEM_WIDTH  : integer := 32;                               -- Width of the data memory registers
	constant DMEM_DEPTH  : integer := 256;                              -- Depth of the data memory regissters
	constant DMEM_LOGDEP : integer := 8;                                -- 2log of DMEM_DEPTH

	-- Immediate types
	constant NO_IMM      : std_logic_vector(1 downto 0) := "00";        -- No immediate
	constant SHORT_IMM   : std_logic_vector(1 downto 0) := "01";        -- Short immediate
	constant BRANCH_IMM  : std_logic_vector(1 downto 0) := "10";        -- Branch offset immediate
	constant LONG_IMM    : std_logic_vector(1 downto 0) := "11";        -- Long immediate
	
	-- Writeback targets
	constant WRITE_G     : std_logic_vector(2 downto 0) := "001";       -- Write to GR register file
	constant WRITE_B     : std_logic_vector(2 downto 0) := "010";       -- Write to BR register file
	constant WRITE_G_B   : std_logic_vector(2 downto 0) := "011";       -- Write to GR and BR register files
	constant WRITE_P     : std_logic_vector(2 downto 0) := "100";       -- Write to program counter
	constant WRITE_P_G   : std_logic_vector(2 downto 0) := "101";       -- Write to program counter and GR register file
	constant WRITE_M     : std_logic_vector(2 downto 0) := "110";       -- Write to data memory
	constant WRITE_MG    : std_logic_vector(2 downto 0) := "111";       -- Write to GR register file, with memory unit input
	constant WRITE_NOP   : std_logic_vector(2 downto 0) := "000";       -- Don't write back

	constant SEL_EXE     : std_logic := '0';                            -- Select execute unit as source for GR writeback
	constant SEL_MEM     : std_logic := '1';                            -- Select memory unit as source for GR writeback

	--------------------------------------------------------------------------------
	-- Opcodes
	--------------------------------------------------------------------------------
	constant ALU_OP      : std_logic_vector(6 downto 0) := "1------";   -- ALU operation
	constant MUL_OP      : std_logic_vector(6 downto 0) := "000----";   -- MUL operation
	constant CTRL_OP     : std_logic_vector(6 downto 0) := "010----";   -- CTRL operation
	constant MEM_OP      : std_logic_vector(6 downto 0) := "001----";   -- MEM operation

	constant STOP        : std_logic_vector(6 downto 0) := "0011111";   -- STOP operation
	constant NOP         : std_logic_vector(6 downto 0) := "0000000";   -- No operation

	-- ALU opcodes (integer arithmetic operations)
	constant ALU_ADD     : std_logic_vector(6 downto 0) := "1000001";   -- Add
	constant ALU_AND     : std_logic_vector(6 downto 0) := "1000011";   -- Bitwise AND
	constant ALU_ANDC    : std_logic_vector(6 downto 0) := "1000100";   -- Bitwise complement and AND
	constant ALU_MAX     : std_logic_vector(6 downto 0) := "1000101";   -- Maximum signed
	constant ALU_MAXU    : std_logic_vector(6 downto 0) := "1000110";   -- Maximum unsigned
	constant ALU_MIN     : std_logic_vector(6 downto 0) := "1000111";   -- Minimum signed
	constant ALU_MINU    : std_logic_vector(6 downto 0) := "1001000";   -- Minimum unsigned
	constant ALU_OR      : std_logic_vector(6 downto 0) := "1001001";   -- Bitwise OR
	constant ALU_ORC     : std_logic_vector(6 downto 0) := "1001010";   -- Bitwise complement and OR
	constant ALU_SH1ADD  : std_logic_vector(6 downto 0) := "1001011";   -- Shift left 1 and add
	constant ALU_SH2ADD  : std_logic_vector(6 downto 0) := "1001100";   -- Shift left 2 and add
	constant ALU_SH3ADD  : std_logic_vector(6 downto 0) := "1001101";   -- Shift left 3 and add
	constant ALU_SH4ADD  : std_logic_vector(6 downto 0) := "1001110";   -- Shift left 4 and add
	constant ALU_SHL     : std_logic_vector(6 downto 0) := "1001111";   -- Shift left
	constant ALU_SHR     : std_logic_vector(6 downto 0) := "1010000";   -- Shift right signed
	constant ALU_SHRU    : std_logic_vector(6 downto 0) := "1010001";   -- Shift right unsigned
	constant ALU_SUB     : std_logic_vector(6 downto 0) := "1010010";   -- Subtract
	constant ALU_SXTB    : std_logic_vector(6 downto 0) := "1010011";   -- Sign extend byte
	constant ALU_SXTH    : std_logic_vector(6 downto 0) := "1010100";   -- Sign extend half word
	constant ALU_ZXTB    : std_logic_vector(6 downto 0) := "1010101";   -- Zero extend byte
	constant ALU_ZXTH    : std_logic_vector(6 downto 0) := "1010110";   -- Zero extend half word
	constant ALU_XOR     : std_logic_vector(6 downto 0) := "1010111";   -- Bitwise XOR
	constant ALU_MOV     : std_logic_vector(6 downto 0) := "1011000";   -- Copy s1 to other location
	
	-- ALU opcodes (logical and select operations)
	--
	-- This block of operation can operate on a GR register or a BR registers as target.
	-- See syllable_layout.txt for more information
	constant ALU_CMPEQ   : std_logic_vector(6 downto 0) := "1011001";   -- Compare: equal
	constant ALU_CMPGE   : std_logic_vector(6 downto 0) := "1011010";   -- Compare: greater equal signed
	constant ALU_CMPGEU  : std_logic_vector(6 downto 0) := "1011011";   -- Compare: greater equal unsigned
	constant ALU_CMPGT   : std_logic_vector(6 downto 0) := "1011100";   -- Compare: greater signed
	constant ALU_CMPGTU  : std_logic_vector(6 downto 0) := "1011101";   -- Compare: greater unsigned
	constant ALU_CMPLE   : std_logic_vector(6 downto 0) := "1011110";   -- Compare: less than equal signed
	constant ALU_CMPLEU  : std_logic_vector(6 downto 0) := "1011111";   -- Compare: less than equal unsigned
	constant ALU_CMPLT   : std_logic_vector(6 downto 0) := "1100000";   -- Compare: less than signed
	constant ALU_CMPLTU  : std_logic_vector(6 downto 0) := "1100001";   -- Compare: less than unsigned
	constant ALU_CMPNE   : std_logic_vector(6 downto 0) := "1100010";   -- Compare: not equal
	constant ALU_NANDL   : std_logic_vector(6 downto 0) := "1100011";   -- Logical NAND
	constant ALU_NORL    : std_logic_vector(6 downto 0) := "1100100";   -- Logical NOR
	constant ALU_ORL     : std_logic_vector(6 downto 0) := "1100110";   -- Logical OR
	constant ALU_MTB     : std_logic_vector(6 downto 0) := "1100111";   -- Move GR to BR
	constant ALU_ANDL    : std_logic_vector(6 downto 0) := "1101000";   -- Logical AND
	
	-- ALU opcodes (BR usage, see doc/syllable_layout.txt)
	constant ALU_ADDCG   : std_logic_vector(6 downto 0) := "1111---";   -- Add with carry and generate carry.
	constant ALU_DIVS    : std_logic_vector(6 downto 0) := "1110---";   -- Division step with carry and generate carry
	constant ALU_SLCT    : std_logic_vector(6 downto 0) := "0111---";   -- Select s1 on true condition. (exception: opcode starts with 0)
	constant ALU_SLCTF   : std_logic_vector(6 downto 0) := "0110---";   -- Select s1 on false condition. (exception: opcode starts with 0)

	-- Multiplier opcodes
	constant MUL_MPYLL   : std_logic_vector(6 downto 0) := "0000001";   -- Multiply signed low 16 x low 16 bits
	constant MUL_MPYLLU  : std_logic_vector(6 downto 0) := "0000010";   -- Multiply unsigned low 16 x low 16 bits
	constant MUL_MPYLH   : std_logic_vector(6 downto 0) := "0000011";   -- Multiply signed low 16 (s1) x high 16 (s2) bits
	constant MUL_MPYLHU  : std_logic_vector(6 downto 0) := "0000100";   -- Multiply unsigned low 16 (s1) x high 16 (s2) bits
	constant MUL_MPYHH   : std_logic_vector(6 downto 0) := "0000101";   -- Multiply signed high 16 x high 16 bits
	constant MUL_MPYHHU  : std_logic_vector(6 downto 0) := "0000110";   -- Multiply unsigned high 16 x high 16 bits
	constant MUL_MPYL    : std_logic_vector(6 downto 0) := "0000111";   -- Multiply signed low 16 (s2) x 32 (s1) bits
	constant MUL_MPYLU   : std_logic_vector(6 downto 0) := "0001000";   -- Multiply unsigned low 16 (s2) x 32 (s1) bits
	constant MUL_MPYH    : std_logic_vector(6 downto 0) := "0001001";   -- Multiply signed high 16 (s2) x 32 (s1) bits
	constant MUL_MPYHU   : std_logic_vector(6 downto 0) := "0001010";   -- Multiply unsigned high 16 (s2) x 32 (s1) bits
	constant MUL_MPYHS   : std_logic_vector(6 downto 0) := "0001011";   -- Multiply signed high 16 (s2) x 32 (s1) bits, shift left 16 

	-- Control opcodes
	--
	-- NOTE: igoto and icall are overloaded by goto and call, as mentioned on the VEX forum at
	-- http://www.vliw.org/vex/viewtopic.php?t=52
	constant CTRL_GOTO   : std_logic_vector(6 downto 0) := "0100001";   -- Unconditional relative jump
	constant CTRL_IGOTO  : std_logic_vector(6 downto 0) := "0100010";   -- Unconditional absolute indirect jump to link register
	constant CTRL_CALL   : std_logic_vector(6 downto 0) := "0100011";   -- Unconditional relative call
	constant CTRL_ICALL  : std_logic_vector(6 downto 0) := "0100100";   -- Unconditional absolute indirect call to link register
	constant CTRL_BR     : std_logic_vector(6 downto 0) := "0100101";   -- Conditional relative branch on true condition
	constant CTRL_BRF    : std_logic_vector(6 downto 0) := "0100110";   -- Conditional relative branch on false condition
	constant CTRL_RETURN : std_logic_vector(6 downto 0) := "0100111";   -- Pop stack frame and goto link register
	constant CTRL_RFI    : std_logic_vector(6 downto 0) := "0101000";   -- Return from interrupt
	constant CTRL_XNOP   : std_logic_vector(6 downto 0) := "0101001";   -- Multicycle NOP

	-- Inter-cluster opcodes
	--
	-- NOTE: These opcodes aren't used in the current r-VEX implementation,
	--       because it has only one cluster. The opcode definitions are
	--       here for possible future use.
	--
	constant INTR_SEND   : std_logic_vector(6 downto 0) := "0101010";   -- Send s1 to the path identified by im
	constant INTR_RECV   : std_logic_vector(6 downto 0) := "0101011";   -- Assigns the value from the path identified by im to t
	
	-- Memory opcodes
	constant MEM_LDW     : std_logic_vector(6 downto 0) := "0010001";   -- Load word
	constant MEM_LDH     : std_logic_vector(6 downto 0) := "0010010";   -- Load halfword signed
	constant MEM_LDHU    : std_logic_vector(6 downto 0) := "0010011";   -- Load halfword unsigned
	constant MEM_LDB     : std_logic_vector(6 downto 0) := "0010100";   -- Load byte signed
	constant MEM_LDBU    : std_logic_vector(6 downto 0) := "0010101";   -- Load byte unsigned
	constant MEM_STW     : std_logic_vector(6 downto 0) := "0010110";   -- Store word
	constant MEM_STH     : std_logic_vector(6 downto 0) := "0010111";   -- Store halfword
	constant MEM_STB     : std_logic_vector(6 downto 0) := "0011000";   -- Store byte
	constant MEM_PFT     : std_logic_vector(6 downto 0) := "0011001";   -- Prefetch
	
	-- Syllable is a follow-up to previous syllable with other part of long immediate
	constant SYL_FOLLOW  : std_logic_vector(6 downto 0) := "0011100";
end package rVEX_pkg;

package body rVEX_pkg is
end package body rVEX_pkg;

