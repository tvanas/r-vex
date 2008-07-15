-----------------------------------------------------------
-- r-VEX | Multiplier
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- mul.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.rVEX_pkg.all;
use work.mul_operations.all;

entity mul is
	port ( clk       : in std_logic;   -- system clock
	       reset     : in std_logic;   -- system reset
	       mulop     : in std_logic_vector(6 downto 0);   -- operation
	       src1      : in std_logic_vector(31 downto 0);  -- operand 1
	       src2      : in std_logic_vector(31 downto 0);  -- operand 2

	       result    : out std_logic_vector(31 downto 0); -- result of operation
	       overflow  : out std_logic;  -- '1' when overflow
	       out_valid : out std_logic); -- '1' when output is valid
end entity mul;


architecture behavioural of mul is
	signal result_i   : std_logic_vector(31 downto 0) := (others => '0');
	signal overflow_i : std_logic := '0';
begin
	result <= result_i;
	overflow <= overflow_i;

	-- Controls MUL operations
	mul_control : process(clk, reset)
	begin
		if (reset = '1') then
			out_valid <= '0';
			result_i <= (others => '0');
			overflow_i <= '0';
		elsif (clk = '1' and clk'event) then
			out_valid <= '1'; -- this will be overriden when a non-existent opcode is issued
		
			case mulop is
				when MUL_MPYLL =>
					f_MPYLL (src1, src2, overflow_i, result_i);
				when MUL_MPYLLU =>
					f_MPYLLU (src1, src2, overflow_i, result_i);
				when MUL_MPYLH =>
					f_MPYLH (src1, src2, overflow_i, result_i);
				when MUL_MPYLHU =>
					f_MPYLHU (src1, src2, overflow_i, result_i);
				when MUL_MPYHH =>
					f_MPYHH (src1, src2, overflow_i, result_i);
				when MUL_MPYHHU =>
					f_MPYHHU (src1, src2, overflow_i, result_i);
				when MUL_MPYL =>
					f_MPYL (src1, src2, overflow_i, result_i);
				when MUL_MPYLU =>
					f_MPYLU (src1, src2, overflow_i, result_i);
				when MUL_MPYH =>
					f_MPYH (src1, src2, overflow_i, result_i);
				when MUL_MPYHU =>
					f_MPYH (src1, src2, overflow_i, result_i);
				when MUL_MPYHS =>
					f_MPYH (src1, src2, overflow_i, result_i);
				when NOP =>
					overflow_i <= '0';
					result_i <= (others => '0');
				when others =>
					out_valid <= '0';
			end case;
		end if;
	end process mul_control;
end architecture behavioural;

