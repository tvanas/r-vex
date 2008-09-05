-----------------------------------------------------------
--               rho-VEX | Testbench MUL
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- testbenches/tb_mul.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.opcodes.all;

entity tb_mul is
end tb_mul;

architecture test of tb_mul is
	component mul is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       mulop     : in std_logic_vector(6 downto 0);
		       src1      : in std_logic_vector(31 downto 0);
		       src2      : in std_logic_vector(31 downto 0);
		       in_valid  : in std_logic;

		       result    : out std_logic_vector(31 downto 0);
		       overflow  : out std_logic;
		       out_valid : out std_logic);	
	end component mul;

	signal clk_s       : std_logic := '0';
	signal reset_s     : std_logic := '0';
	signal mulop_s     : std_logic_vector(6 downto 0)  := (others => '0');
	signal src1_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal src2_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal in_valid_s  : std_logic := '0';
	signal result_s    : std_logic_vector(31 downto 0) := (others => '0');
	signal overflow_s  : std_logic := '0';
	signal out_valid_s : std_logic := '0';

	constant testval_1 : std_logic_vector(31 downto 0) := x"00000003";
	constant testval_2 : std_logic_vector(31 downto 0) := x"00000002";
	constant testval_3 : std_logic_vector(31 downto 0) := x"000000FF";
	constant testval_4 : std_logic_vector(31 downto 0) := x"8432FFFF";
	constant testval_5 : std_logic_vector(31 downto 0) := x"11111111";
begin
	mul0 : mul port map (clk_s, reset_s, mulop_s, src1_s, src2_s, in_valid_s,
	                     result_s, overflow_s, out_valid_s);

	clk_s <= not clk_s after 10 ns;

	reset_s <= '1' after 10 ns,
	           '0' after 40 ns;
	
	testbench : process
	begin
		wait for 60 ns;

		for i in 1 to 15 loop
			mulop_s <= std_logic_vector(to_unsigned(i, 7));
			src1_s <= testval_1;
			src2_s <= testval_1;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_1;
			src2_s <= testval_2;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_1;
			src2_s <= testval_3;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_2;
			src2_s <= testval_1;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_3;
			src2_s <= testval_4;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_4;
			src2_s <= testval_4;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_5;
			src2_s <= testval_5;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_1;
			src2_s <= testval_5;
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
		end loop;	
	end process testbench;
end architecture test;

