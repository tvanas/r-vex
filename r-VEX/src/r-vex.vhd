--------------------------------------------------------------------------------
-- r-VEX | Top-level entity
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
-- r-VEX top-level entity which is connected to external
-- instruction and data memories.
--------------------------------------------------------------------------------
-- r-vex.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.rVEX_pkg.all;

entity rVEX is
	port ( clk        : in std_logic;  -- system clock
	       reset      : in std_logic;  -- system reset
	       instr      : in std_logic_vector(127 downto 0);                -- instruction (4 syllables) from memory
	       data_in    : in std_logic_vector((DMEM_WIDTH - 1) downto 0);   -- data read from data memory
	       run        : in std_logic;  -- '1' when to start the execution
		   
	       done       : out std_logic; -- '1' when execution is finished
	       cycles     : out std_logic_vector(31 downto 0);                -- the number of clock cycles execution took
	       address_i  : out std_logic_vector(7 downto 0);                 -- address to be read from instruction memory
	       address_dr : out std_logic_vector((DMEM_LOGDEP - 1) downto 0); -- address to be read from data memory
	       address_dw : out std_logic_vector((DMEM_LOGDEP - 1) downto 0); -- address to write to in data memory
	       write_en_d : out std_logic;                                    -- write enable for data memory
	       data_out   : out std_logic_vector((DMEM_WIDTH - 1) downto 0)); -- data to write to data memory
end entity rVEX;


architecture behavioural of rVEX is
	-- Program counter
	component program_counter is
		port ( reset             : in std_logic;
		       update_pc         : in std_logic;
		       pc_goto           : in std_logic_vector((ADDR_WIDTH - 1) downto 0);

		       pc                : out std_logic_vector((ADDR_WIDTH - 1) downto 0));
	end component program_counter;

	-- General purpose regiser file
	component registers_gr is
		port ( clk               : in std_logic;
			   write_en_0     : in std_logic;
			   write_en_1     : in std_logic;
			   write_en_2     : in std_logic;
			   write_en_3     : in std_logic;
			   address_r1_0   : in std_logic_vector(5 downto 0);
			   address_r2_0   : in std_logic_vector(5 downto 0);
			   address_r1_1   : in std_logic_vector(5 downto 0);
			   address_r2_1   : in std_logic_vector(5 downto 0);
			   address_r1_2   : in std_logic_vector(5 downto 0);
			   address_r2_2   : in std_logic_vector(5 downto 0);
			   address_r1_3   : in std_logic_vector(5 downto 0);
			   address_r2_3   : in std_logic_vector(5 downto 0);
			   address_w_0    : in std_logic_vector(5 downto 0);
			   address_w_1    : in std_logic_vector(5 downto 0);
		           address_w_2    : in std_logic_vector(5 downto 0);
			   address_w_3    : in std_logic_vector(5 downto 0);
			   data_in_0      : in std_logic_vector(31 downto 0);
			   data_in_1      : in std_logic_vector(31 downto 0);
			   data_in_2      : in std_logic_vector(31 downto 0);
			   data_in_3      : in std_logic_vector(31 downto 0);

			   data_out1_0    : out std_logic_vector(31 downto 0);
			   data_out1_1    : out std_logic_vector(31 downto 0);
			   data_out1_2    : out std_logic_vector(31 downto 0);
			   data_out1_3    : out std_logic_vector(31 downto 0);
			   data_out2_0    : out std_logic_vector(31 downto 0);
			   data_out2_1    : out std_logic_vector(31 downto 0);
			   data_out2_2    : out std_logic_vector(31 downto 0);
			   data_out2_3    : out std_logic_vector(31 downto 0));
	end component registers_gr;

	-- Branch register file
	component registers_br is
		port ( clk               : in std_logic;
			   write_en_0     : in std_logic;
			   write_en_1     : in std_logic;
			   write_en_2     : in std_logic;
			   write_en_3     : in std_logic;
			   address_r_0    : in std_logic_vector(2 downto 0);
			   address_r_1    : in std_logic_vector(2 downto 0);
			   address_r_2    : in std_logic_vector(2 downto 0);
			   address_r_3    : in std_logic_vector(2 downto 0);
			   address_w_0    : in std_logic_vector(2 downto 0);
			   address_w_1    : in std_logic_vector(2 downto 0);
			   address_w_2    : in std_logic_vector(2 downto 0);
			   address_w_3    : in std_logic_vector(2 downto 0);
			   data_in_0      : in std_logic;
			   data_in_1      : in std_logic;
			   data_in_2      : in std_logic;
			   data_in_3      : in std_logic;
				   
			   data_out_0     : out std_logic;
			   data_out_1     : out std_logic;
			   data_out_2     : out std_logic;
			   data_out_3     : out std_logic);
	end component registers_br;
	
	-- Instruction fetch
	component fetch is
		port ( clk               : in std_logic;
		       reset             : in std_logic;
		       instr             : in std_logic_vector(127 downto 0);
		       next_instr        : in std_logic;
		       start             : in std_logic;
		       stop              : in std_logic;
		       pc                : in std_logic_vector(7 downto 0);
		       
		       syllable_0        : out std_logic_vector(31 downto 0);
		       syllable_1        : out std_logic_vector(31 downto 0);
		       syllable_2        : out std_logic_vector(31 downto 0);
		       syllable_3        : out std_logic_vector(31 downto 0);
		       stop_out          : out std_logic;
		       cycles            : out std_logic_vector(31 downto 0);
		       address           : out std_logic_vector(7 downto 0);
		       out_valid         : out std_logic);
	end component fetch;

	-- Instruction/syllable decode
	component decode is
		port ( clk               : in std_logic;
		       reset             : in std_logic;
		       new_decode        : in std_logic;
		       fetch_ok          : in std_logic;
		       start             : in std_logic;

		       syllable_0        : in std_logic_vector(31 downto 0);
		       data_r1_0         : in std_logic_vector(31 downto 0);
		       data_r2_0         : in std_logic_vector(31 downto 0);
		       data_rb_0         : in std_logic;

		       syllable_1        : in std_logic_vector(31 downto 0);
		       data_r1_1         : in std_logic_vector(31 downto 0);
		       data_r2_1         : in std_logic_vector(31 downto 0);
		       data_rb_1         : in std_logic;

		       syllable_2        : in std_logic_vector(31 downto 0);
		       data_r1_2         : in std_logic_vector(31 downto 0);
		       data_r2_2         : in std_logic_vector(31 downto 0);
		       data_rb_2         : in std_logic;

		       syllable_3        : in std_logic_vector(31 downto 0);
		       data_r1_3         : in std_logic_vector(31 downto 0);
		       data_r2_3         : in std_logic_vector(31 downto 0);
		       data_rb_3         : in std_logic;

		       opcode_0          : out std_logic_vector(6 downto 0);
		       address_r1_0      : out std_logic_vector(5 downto 0);
		       address_r2_0      : out std_logic_vector(5 downto 0);
		       address_rb_0      : out std_logic_vector(2 downto 0);
		       operand1_0        : out std_logic_vector(31 downto 0);
		       operand2_0        : out std_logic_vector(31 downto 0);
		       operandb_0        : out std_logic;
		       branch_dest_0     : out std_logic;
		       address_dest_0    : out std_logic_vector(5 downto 0);
		       address_destb_0   : out std_logic_vector(2 downto 0);
		       target_0          : out std_logic_vector(2 downto 0);

		       opcode_1          : out std_logic_vector(6 downto 0);
		       address_r1_1      : out std_logic_vector(5 downto 0);
		       address_r2_1      : out std_logic_vector(5 downto 0);
		       address_rb_1      : out std_logic_vector(2 downto 0);
		       operand1_1        : out std_logic_vector(31 downto 0);
		       operand2_1        : out std_logic_vector(31 downto 0);
		       operandb_1        : out std_logic;
		       branch_dest_1     : out std_logic;
		       address_dest_1    : out std_logic_vector(5 downto 0);
		       address_destb_1   : out std_logic_vector(2 downto 0);
		       target_1          : out std_logic_vector(2 downto 0);

		       opcode_2          : out std_logic_vector(6 downto 0);
		       address_r1_2      : out std_logic_vector(5 downto 0);
		       address_r2_2      : out std_logic_vector(5 downto 0);
		       address_rb_2      : out std_logic_vector(2 downto 0);
		       operand1_2        : out std_logic_vector(31 downto 0);
		       operand2_2        : out std_logic_vector(31 downto 0);
		       operandb_2        : out std_logic;
		       branch_dest_2     : out std_logic;
		       address_dest_2    : out std_logic_vector(5 downto 0);
		       address_destb_2   : out std_logic_vector(2 downto 0);
		       target_2          : out std_logic_vector(2 downto 0);

		       opcode_3          : out std_logic_vector(6 downto 0);
		       address_r1_3      : out std_logic_vector(5 downto 0);
		       address_r2_3      : out std_logic_vector(5 downto 0);
		       address_rb_3      : out std_logic_vector(2 downto 0);
		       operand1_3        : out std_logic_vector(31 downto 0);
		       operand2_3        : out std_logic_vector(31 downto 0);
		       operandb_3        : out std_logic;
		       branch_dest_3     : out std_logic;
		       address_dest_3    : out std_logic_vector(5 downto 0);
		       address_destb_3   : out std_logic_vector(2 downto 0);
		       target_3          : out std_logic_vector(2 downto 0);

		       address_dr_3      : out std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       address_off_3     : out std_logic_vector(1 downto 0);
		       offset            : out std_logic_vector((BROFF_WIDTH - 1) downto 0);
		       ops_ready         : out std_logic;
		       accept_in         : out std_logic;
		       done              : out std_logic);
	end component decode;

	-- Execute unit
	component execute is
		port ( clk               : in std_logic;
		       reset             : in std_logic;
		       in_valid          : in std_logic;

		       opcode_0          : in std_logic_vector(6 downto 0);
		       operand1_0        : in std_logic_vector(31 downto 0);
		       operand2_0        : in std_logic_vector(31 downto 0);
		       operandb_0        : in std_logic;
		       branch_dest_0     : in std_logic;

		       opcode_1          : in std_logic_vector(6 downto 0);
		       operand1_1        : in std_logic_vector(31 downto 0);
		       operand2_1        : in std_logic_vector(31 downto 0);
		       operandb_1        : in std_logic;
		       branch_dest_1     : in std_logic;

		       opcode_2          : in std_logic_vector(6 downto 0);
		       operand1_2        : in std_logic_vector(31 downto 0);
		       operand2_2        : in std_logic_vector(31 downto 0);
		       operandb_2        : in std_logic;
		       branch_dest_2     : in std_logic;

		       opcode_3          : in std_logic_vector(6 downto 0);
		       operand1_3        : in std_logic_vector(31 downto 0);
		       operand2_3        : in std_logic_vector(31 downto 0);
		       operandb_3        : in std_logic;
		       branch_dest_3     : in std_logic;

		       result_0          : out std_logic_vector(31 downto 0);
		       resultb_0         : out std_logic;

		       result_1          : out std_logic_vector(31 downto 0);
		       resultb_1         : out std_logic;

		       result_2          : out std_logic_vector(31 downto 0);
		       resultb_2         : out std_logic;

		       result_3          : out std_logic_vector(31 downto 0);
		       resultb_3         : out std_logic;

		       out_valid         : out std_logic);
	end component execute;
	
	-- Branch control unit
	component ctrl is
		port ( clk               : in std_logic;
		       reset             : in std_logic;
		       opcode            : in std_logic_vector(6 downto 0);
		       pc                : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
		       lr                : in std_logic_vector(31 downto 0);
		       sp                : in std_logic_vector(31 downto 0);
		       offset            : in std_logic_vector((BROFF_WIDTH - 1) downto 0);
		       br                : in std_logic;
		       in_valid          : in std_logic;

		       pc_goto           : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
		       result            : out std_logic_vector(31 downto 0);
		       out_valid         : out std_logic);
	end component ctrl;

	-- Memory unit
	component mem is
		port ( clk               : in std_logic;
		       reset             : in std_logic;
		       opcode            : in std_logic_vector(6 downto 0);
		       data_reg          : in std_logic_vector(31 downto 0);
		       pos_off           : in std_logic_vector(1 downto 0);
		       data_ld           : in std_logic_vector((DMEM_WIDTH - 1) downto 0);
		       in_valid          : in std_logic;

		       data_st           : out std_logic_vector((DMEM_WIDTH - 1) downto 0);
		       data_2reg         : out std_logic_vector(31 downto 0);
		       out_valid         : out std_logic);
	end component mem;
	
	-- Writeback unit
	component writeback is
		port ( clk               : in std_logic;
		       reset             : in std_logic;
		       write_en          : in std_logic;

		       address_gr_in_0   : in std_logic_vector(5 downto 0);
		       address_br_in_0   : in std_logic_vector(2 downto 0);
		       data_gr_in_0      : in std_logic_vector(31 downto 0);
		       data_br_in_0      : in std_logic;
		       data_ctrl_in_0    : in std_logic_vector(31 downto 0);
		       pc                : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
		       pc_goto           : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
		       target_0          : in std_logic_vector(2 downto 0);

		       address_gr_in_1   : in std_logic_vector(5 downto 0);
		       address_br_in_1   : in std_logic_vector(2 downto 0);
		       data_gr_in_1      : in std_logic_vector(31 downto 0);
		       data_br_in_1      : in std_logic;
		       target_1          : in std_logic_vector(2 downto 0);

		       address_gr_in_2   : in std_logic_vector(5 downto 0);
		       address_br_in_2   : in std_logic_vector(2 downto 0);
		       data_gr_in_2      : in std_logic_vector(31 downto 0);
		       data_br_in_2      : in std_logic;
		       target_2          : in std_logic_vector(2 downto 0);

		       address_gr_in_3   : in std_logic_vector(5 downto 0);
		       address_br_in_3   : in std_logic_vector(2 downto 0);
		       address_mem_in_3  : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       data_gr_in_3      : in std_logic_vector(31 downto 0);
		       data_br_in_3      : in std_logic;
		       data_mem_in_3     : in std_logic_vector((DMEM_WIDTH - 1) downto 0);
		       data_grm_in_3     : in std_logic_vector(31 downto 0);
		       target_3          : in std_logic_vector(2 downto 0);

		       written           : out std_logic;

		       write_en_gr_0     : out std_logic;
		       write_en_br_0     : out std_logic;
		       address_gr_out_0  : out std_logic_vector(5 downto 0);
		       address_br_out_0  : out std_logic_vector(2 downto 0);
		       data_gr_out_0     : out std_logic_vector(31 downto 0);
		       data_br_out_0     : out std_logic;
		       data_pc           : out std_logic_vector((ADDR_WIDTH - 1) downto 0);

		       write_en_gr_1     : out std_logic;
		       write_en_br_1     : out std_logic;
		       address_gr_out_1  : out std_logic_vector(5 downto 0);
		       address_br_out_1  : out std_logic_vector(2 downto 0);
		       data_gr_out_1     : out std_logic_vector(31 downto 0);
		       data_br_out_1     : out std_logic;

		       write_en_gr_2     : out std_logic;
		       write_en_br_2     : out std_logic;
		       address_gr_out_2  : out std_logic_vector(5 downto 0);
		       address_br_out_2  : out std_logic_vector(2 downto 0);
		       data_gr_out_2     : out std_logic_vector(31 downto 0);
		       data_br_out_2     : out std_logic;

		       write_en_gr_3     : out std_logic;
		       write_en_br_3     : out std_logic;
		       write_en_mem_3    : out std_logic;
		       address_gr_out_3  : out std_logic_vector(5 downto 0);
		       address_br_out_3  : out std_logic_vector(2 downto 0);
		       address_mem_out_3 : out std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       data_gr_out_3     : out std_logic_vector(31 downto 0);
		       data_br_out_3     : out std_logic;
		       data_mem_out_3    : out std_logic_vector((DMEM_WIDTH - 1) downto 0));
	end component writeback;		

	signal syllable_0_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal syllable_1_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal syllable_2_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal syllable_3_s       : std_logic_vector(31 downto 0) := (others => '0');
	
	signal write_en_0_s       : std_logic := '0';
	signal write_en_1_s       : std_logic := '0';
	signal write_en_2_s       : std_logic := '0';
	signal write_en_3_s       : std_logic := '0';

	signal write_enb_0_s      : std_logic := '0';
	signal write_enb_1_s      : std_logic := '0';
	signal write_enb_2_s      : std_logic := '0';
	signal write_enb_3_s      : std_logic := '0';

	signal address_r1_0_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r2_0_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r1_1_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r2_1_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r1_2_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r2_2_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r1_3_s     : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r2_3_s     : std_logic_vector(5 downto 0) := (others => '0');
	
	signal address_rb_0_s     : std_logic_vector(2 downto 0) := (others => '0');
	signal address_rb_1_s     : std_logic_vector(2 downto 0) := (others => '0');
	signal address_rb_2_s     : std_logic_vector(2 downto 0) := (others => '0');
	signal address_rb_3_s     : std_logic_vector(2 downto 0) := (others => '0');

	signal address_w_0_s      : std_logic_vector(5 downto 0) := (others => '0');
	signal address_w_1_s      : std_logic_vector(5 downto 0) := (others => '0');
	signal address_w_2_s      : std_logic_vector(5 downto 0) := (others => '0');
	signal address_w_3_s      : std_logic_vector(5 downto 0) := (others => '0');

	signal address_wb_0_s     : std_logic_vector(2 downto 0) := (others => '0');
	signal address_wb_1_s     : std_logic_vector(2 downto 0) := (others => '0');
	signal address_wb_2_s     : std_logic_vector(2 downto 0) := (others => '0');
	signal address_wb_3_s     : std_logic_vector(2 downto 0) := (others => '0');

	signal data_in_0_s        : std_logic_vector(31 downto 0) := (others => '0');
	signal data_in_1_s        : std_logic_vector(31 downto 0) := (others => '0');
	signal data_in_2_s        : std_logic_vector(31 downto 0) := (others => '0');
	signal data_in_3_s        : std_logic_vector(31 downto 0) := (others => '0');
	
	signal data_inb_0_s       : std_logic := '0';
	signal data_inb_1_s       : std_logic := '0';
	signal data_inb_2_s       : std_logic := '0';
	signal data_inb_3_s       : std_logic := '0';

	signal data_out1_0_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out2_0_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out1_1_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out2_1_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out1_2_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out2_2_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out1_3_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out2_3_s      : std_logic_vector(31 downto 0) := (others => '0');
	
	signal data_outb_0_s      : std_logic := '0';
	signal data_outb_1_s      : std_logic := '0';
	signal data_outb_2_s      : std_logic := '0';
	signal data_outb_3_s      : std_logic := '0';
	
	signal target_0_s         : std_logic_vector(2 downto 0) := (others => '0');
	signal target_1_s         : std_logic_vector(2 downto 0) := (others => '0');	
	signal target_2_s         : std_logic_vector(2 downto 0) := (others => '0');
	signal target_3_s         : std_logic_vector(2 downto 0) := (others => '0');

	signal address_destb_0_s  : std_logic_vector(2 downto 0) := (others => '0');
	signal address_destb_1_s  : std_logic_vector(2 downto 0) := (others => '0');
	signal address_destb_2_s  : std_logic_vector(2 downto 0) := (others => '0');
	signal address_destb_3_s  : std_logic_vector(2 downto 0) := (others => '0');

	signal address_dest_0_s   : std_logic_vector(5 downto 0) := (others => '0');
	signal address_dest_1_s   : std_logic_vector(5 downto 0) := (others => '0');
	signal address_dest_2_s   : std_logic_vector(5 downto 0) := (others => '0');
	signal address_dest_3_s   : std_logic_vector(5 downto 0) := (others => '0');
	
	signal opcode_0_s         : std_logic_vector(6 downto 0) := (others => '0');
	signal opcode_1_s         : std_logic_vector(6 downto 0) := (others => '0');
	signal opcode_2_s         : std_logic_vector(6 downto 0) := (others => '0');
	signal opcode_3_s         : std_logic_vector(6 downto 0) := (others => '0');

	signal operand1_0_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_0_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand1_1_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_1_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand1_2_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_2_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand1_3_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_3_s       : std_logic_vector(31 downto 0) := (others => '0');

	signal operandb_0_s       : std_logic := '0';
	signal operandb_1_s       : std_logic := '0';
	signal operandb_2_s       : std_logic := '0';
	signal operandb_3_s       : std_logic := '0';

	signal de_branch_dest_0_s : std_logic := '0';
	signal de_branch_dest_1_s : std_logic := '0';
	signal de_branch_dest_2_s : std_logic := '0';
	signal de_branch_dest_3_s : std_logic := '0';

	signal result_0_s         : std_logic_vector(31 downto 0) := (others => '0');
	signal result_1_s         : std_logic_vector(31 downto 0) := (others => '0');
	signal result_2_s         : std_logic_vector(31 downto 0) := (others => '0');
	signal result_3_s         : std_logic_vector(31 downto 0) := (others => '0');

	signal resultb_0_s        : std_logic := '0'; 
	signal resultb_1_s        : std_logic := '0';
	signal resultb_2_s        : std_logic := '0';
	signal resultb_3_s        : std_logic := '0';

	signal ops_ready_s        : std_logic := '0';
	signal out_valid_ex_s     : std_logic := '0';
	signal out_valid_ctrl_s   : std_logic := '0';
	signal out_valid_mem_s    : std_logic := '0';
	signal wb_en_s            : std_logic := '0';
	
	signal pos_off_s          : std_logic_vector(1 downto 0) := (others => '0');
	signal fetch_ok_s         : std_logic := '0';
	signal start_dec_s        : std_logic := '0';
	signal accept_in_dec_s    : std_logic := '0';

	signal pc_s               : std_logic_vector(7 downto 0) := (others => '0');
	signal done_s             : std_logic := '0';

	signal m2w_data_s         : std_logic_vector((DMEM_WIDTH - 1) downto 0) := (others => '0');
	signal m2w_2reg_s         : std_logic_vector(31 downto 0) := (others => '0');
	signal address_dr_i       : std_logic_vector((DMEM_LOGDEP - 1) downto 0) := (others => '0');
	signal pc_goto_s          : std_logic_vector((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal data_ctrl_s        : std_logic_vector(31 downto 0) := (others => '0');
	signal offset_s           : std_logic_vector((BROFF_WIDTH - 1) downto 0) := (others => '0');
	signal data_pc_s          : std_logic_vector((ADDR_WIDTH - 1) downto 0) := (others => '0');

	-- Xilinx specific clock buffer attributes
	attribute buffer_type : string;
	attribute buffer_type of accept_in_dec_s : signal is "BUFG";
	attribute buffer_type of done_s          : signal is "BUFG";
begin
	pc0        : program_counter port map (reset => reset,
	                                       update_pc => accept_in_dec_s,
	                                       pc_goto => data_pc_s,
	
	                                       pc => pc_s);
										  
	regs_gr       : registers_gr port map (clk => clk,
	                                       write_en_0 => write_en_0_s,
	                                       write_en_1 => write_en_1_s,
	                                       write_en_2 => write_en_2_s,
	                                       write_en_3 => write_en_3_s,
	                                       address_r1_0 => address_r1_0_s,
	                                       address_r2_0 => address_r2_0_s,
	                                       address_r1_1 => address_r1_1_s,
	                                       address_r2_1 => address_r2_1_s,
	                                       address_r1_2 => address_r1_2_s,
	                                       address_r2_2 => address_r2_2_s,
	                                       address_r1_3 => address_r1_3_s,
	                                       address_r2_3 => address_r2_3_s,
	                                       address_w_0 => address_w_0_s,
	                                       address_w_1 => address_w_1_s,
	                                       address_w_2 => address_w_2_s,
	                                       address_w_3 => address_w_3_s,
	                                       data_in_0 => data_in_0_s,
	                                       data_in_1 => data_in_1_s,
	                                       data_in_2 => data_in_2_s,
	                                       data_in_3 => data_in_3_s,
					       
	                                       data_out1_0 => data_out1_0_s,
	                                       data_out2_0 => data_out2_0_s,
	                                       data_out1_1 => data_out1_1_s,
	                                       data_out2_1 => data_out2_1_s,
	                                       data_out1_2 => data_out1_2_s,
	                                       data_out2_2 => data_out2_2_s,
	                                       data_out1_3 => data_out1_3_s,
	                                       data_out2_3 => data_out2_3_s);

	regs_br       : registers_br port map (clk => clk,
	                                       write_en_0 => write_enb_0_s,
	                                       write_en_1 => write_enb_1_s,
	                                       write_en_2 => write_enb_2_s,
	                                       write_en_3 => write_enb_3_s,
	                                       address_r_0 => address_rb_0_s,
	                                       address_r_1 => address_rb_1_s,
	                                       address_r_2 => address_rb_2_s,
	                                       address_r_3 => address_rb_3_s,
	                                       address_w_0 => address_wb_0_s,
	                                       address_w_1 => address_wb_1_s,
	                                       address_w_2 => address_wb_2_s,
	                                       address_w_3 => address_wb_3_s,
	                                       data_in_0 => data_inb_0_s,
	                                       data_in_1 => data_inb_1_s,
	                                       data_in_2 => data_inb_2_s,
	                                       data_in_3 => data_inb_3_s,
					       
	                                       data_out_0 => data_outb_0_s,
	                                       data_out_1 => data_outb_1_s,
	                                       data_out_2 => data_outb_2_s,
	                                       data_out_3 => data_outb_3_s);
	
	fetch_stage   : fetch        port map (clk => clk,
	                                       reset => reset,
	                                       instr => instr,
	                                       next_instr => accept_in_dec_s,
	                                       start => run,
	                                       stop => done_s,
	                                       pc => pc_s,
										   
	                                       syllable_0 => syllable_0_s,
	                                       syllable_1 => syllable_1_s,
	                                       syllable_2 => syllable_2_s,
	                                       syllable_3 => syllable_3_s,
	                                       stop_out => done,
	                                       cycles => cycles,
	                                       address => address_i,
	                                       out_valid => fetch_ok_s);

	decode_stage  : decode       port map (clk => clk,
	                                       reset => reset,
	                                       new_decode => wb_en_s,
	                                       fetch_ok => fetch_ok_s,
	                                       start => start_dec_s,

	                                       syllable_0 => syllable_0_s,
	                                       data_r1_0 => data_out1_0_s,
	                                       data_r2_0 => data_out2_0_s,
	                                       data_rb_0 => data_outb_0_s,

	                                       syllable_1 => syllable_1_s,
	                                       data_r1_1 => data_out1_1_s,
	                                       data_r2_1 => data_out2_1_s,
	                                       data_rb_1 => data_outb_1_s,

	                                       syllable_2 => syllable_2_s,
	                                       data_r1_2 => data_out1_2_s,
	                                       data_r2_2 => data_out2_2_s,
	                                       data_rb_2 => data_outb_2_s,

	                                       syllable_3 => syllable_3_s,
	                                       data_r1_3 => data_out1_3_s,
	                                       data_r2_3 => data_out2_3_s,
	                                       data_rb_3 => data_outb_3_s,

	                                       opcode_0 => opcode_0_s,
	                                       address_r1_0 => address_r1_0_s,
	                                       address_r2_0 => address_r2_0_s,
	                                       address_rb_0 => address_rb_0_s,
	                                       operand1_0 => operand1_0_s,
	                                       operand2_0 => operand2_0_s,
	                                       operandb_0 => operandb_0_s,
	                                       branch_dest_0 => de_branch_dest_0_s,
	                                       address_dest_0 => address_dest_0_s,
	                                       address_destb_0 => address_destb_0_s,
	                                       target_0 => target_0_s,

	                                       opcode_1 => opcode_1_s,
	                                       address_r1_1 => address_r1_1_s,
	                                       address_r2_1 => address_r2_1_s,
	                                       address_rb_1 => address_rb_1_s,
	                                       operand1_1 => operand1_1_s,
	                                       operand2_1 => operand2_1_s,
	                                       operandb_1 => operandb_1_s,
	                                       branch_dest_1 => de_branch_dest_1_s,
	                                       address_dest_1 => address_dest_1_s,
	                                       address_destb_1 => address_destb_1_s,
	                                       target_1 => target_1_s,

	                                       opcode_2 => opcode_2_s,
	                                       address_r1_2 => address_r1_2_s,
	                                       address_r2_2 => address_r2_2_s,
	                                       address_rb_2 => address_rb_2_s,
	                                       operand1_2 => operand1_2_s,
	                                       operand2_2 => operand2_2_s,
	                                       operandb_2 => operandb_2_s,
	                                       branch_dest_2 => de_branch_dest_2_s,
	                                       address_dest_2 => address_dest_2_s,
	                                       address_destb_2 => address_destb_2_s,
	                                       target_2 => target_2_s,

	                                       opcode_3 => opcode_3_s,
	                                       address_r1_3 => address_r1_3_s,
	                                       address_r2_3 => address_r2_3_s,
	                                       address_rb_3 => address_rb_3_s,
	                                       operand1_3 => operand1_3_s,
	                                       operand2_3 => operand2_3_s,
	                                       operandb_3 => operandb_3_s,
	                                       branch_dest_3 => de_branch_dest_3_s,
	                                       address_dest_3 => address_dest_3_s,
	                                       address_destb_3 => address_destb_3_s,
	                                       target_3 => target_3_s,

	                                       address_dr_3 => address_dr_i,
	                                       address_off_3 => pos_off_s,
	                                       offset => offset_s,
	                                       ops_ready => ops_ready_s,
	                                       accept_in => accept_in_dec_s,
	                                       done => done_s);		   

	execute_stage : execute      port map (clk => clk,
	                                       reset => reset,
	                                       in_valid => ops_ready_s,

	                                       opcode_0 => opcode_0_s,
	                                       operand1_0 => operand1_0_s,
	                                       operand2_0 => operand2_0_s,
	                                       operandb_0 => operandb_0_s,
	                                       branch_dest_0 => de_branch_dest_0_s,

	                                       opcode_1 => opcode_1_s,
	                                       operand1_1 => operand1_1_s,
	                                       operand2_1 => operand2_1_s,
	                                       operandb_1 => operandb_1_s,
	                                       branch_dest_1 => de_branch_dest_1_s,

	                                       opcode_2 => opcode_2_s,
	                                       operand1_2 => operand1_2_s,
	                                       operand2_2 => operand2_2_s,
	                                       operandb_2 => operandb_2_s,
	                                       branch_dest_2 => de_branch_dest_2_s,

	                                       opcode_3 => opcode_3_s,
	                                       operand1_3 => operand1_3_s,
	                                       operand2_3 => operand2_3_s,
	                                       operandb_3 => operandb_3_s,
	                                       branch_dest_3 => de_branch_dest_3_s,

	                                       result_0 => result_0_s,
	                                       resultb_0 => resultb_0_s,

	                                       result_1 => result_1_s,
	                                       resultb_1 => resultb_1_s,

	                                       result_2 => result_2_s,
	                                       resultb_2 => resultb_2_s,

	                                       result_3 => result_3_s,
	                                       resultb_3 => resultb_3_s,

	                                       out_valid => out_valid_ex_s);
	
	ctrl0         : ctrl         port map (clk => clk,
	                                       reset => reset,
	                                       opcode => opcode_0_s,
	                                       pc => pc_s,
	                                       lr => operand2_0_s,
	                                       sp => operand1_0_s,
	                                       offset => offset_s,
	                                       br => operandb_0_s,
	                                       in_valid => ops_ready_s,

	                                       pc_goto => pc_goto_s,
	                                       result => data_ctrl_s,
	                                       out_valid => out_valid_ctrl_s); 

	mem3          : mem          port map (clk => clk,
	                                       reset => reset,
	                                       opcode => opcode_3_s,
	                                       data_reg => operand2_3_s,
	                                       pos_off => pos_off_s,
	                                       data_ld => data_in,
	                                       in_valid => ops_ready_s,

	                                       data_st => m2w_data_s,
	                                       data_2reg => m2w_2reg_s,
	                                       out_valid => out_valid_mem_s);
	
	writeback_stage : writeback  port map (clk => clk,
	                                       reset => reset,
	                                       write_en => wb_en_s,

	                                       address_gr_in_0 => address_dest_0_s,
	                                       address_br_in_0 => address_destb_0_s,
	                                       data_gr_in_0 => result_0_s,
	                                       data_br_in_0 => resultb_0_s,
	                                       data_ctrl_in_0 => data_ctrl_s,
	                                       pc => pc_s, 
	                                       pc_goto => pc_goto_s,
	                                       target_0 => target_0_s,

	                                       address_gr_in_1 => address_dest_1_s,
	                                       address_br_in_1 => address_destb_1_s,
	                                       data_gr_in_1 => result_1_s,
	                                       data_br_in_1 => resultb_1_s,
	                                       target_1 => target_1_s,

	                                       address_gr_in_2 => address_dest_2_s,
	                                       address_br_in_2 => address_destb_2_s,
	                                       data_gr_in_2 => result_2_s,
	                                       data_br_in_2 => resultb_2_s,
	                                       target_2 => target_2_s,

	                                       address_gr_in_3 => address_dest_3_s,
	                                       address_br_in_3 => address_destb_3_s,
	                                       address_mem_in_3 => address_dr_i,
	                                       data_gr_in_3 => result_3_s,
	                                       data_br_in_3 => resultb_3_s,
	                                       data_mem_in_3 => m2w_data_s,
	                                       data_grm_in_3 => m2w_2reg_s,
	                                       target_3 => target_3_s,
										   
	                                       written => start_dec_s,

	                                       write_en_gr_0 => write_en_0_s,
	                                       write_en_br_0 => write_enb_0_s,
	                                       address_gr_out_0 => address_w_0_s,
	                                       address_br_out_0 => address_wb_0_s,
	                                       data_gr_out_0 => data_in_0_s,
	                                       data_br_out_0 => data_inb_0_s,
	                                       data_pc => data_pc_s,

	                                       write_en_gr_1 => write_en_1_s,
	                                       write_en_br_1 => write_enb_1_s,
	                                       address_gr_out_1 => address_w_1_s,
	                                       address_br_out_1 => address_wb_1_s,
	                                       data_gr_out_1 => data_in_1_s,
	                                       data_br_out_1 => data_inb_1_s,

	                                       write_en_gr_2 => write_en_2_s,
	                                       write_en_br_2 => write_enb_2_s,
	                                       address_gr_out_2 => address_w_2_s,
	                                       address_br_out_2 => address_wb_2_s,
	                                       data_gr_out_2 => data_in_2_s,
	                                       data_br_out_2 => data_inb_2_s,

	                                       write_en_gr_3 => write_en_3_s,
	                                       write_en_br_3 => write_enb_3_s,
	                                       write_en_mem_3 => write_en_d,
	                                       address_gr_out_3 => address_w_3_s,
	                                       address_br_out_3 => address_wb_3_s,
	                                       address_mem_out_3 => address_dw,
	                                       data_gr_out_3 => data_in_3_s,
	                                       data_br_out_3 => data_inb_3_s,
	                                       data_mem_out_3 => data_out);

	address_dr <= address_dr_i;

	-- driver signal for the new_decode input for the decoder
	wb_en_s <= out_valid_ex_s or out_valid_ctrl_s or out_valid_mem_s;
end architecture behavioural;

