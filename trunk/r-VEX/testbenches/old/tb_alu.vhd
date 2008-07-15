-----------------------------------------------------------
--               rho-VEX | Testbench ALU
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- testbenches/tb_alu.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.opcodes.all;

entity tb_alu is
end tb_alu;

architecture test of tb_alu is
	component alu is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       aluop     : in std_logic_vector(6 downto 0);
		       src1      : in std_logic_vector(31 downto 0);
		       src2      : in std_logic_vector(31 downto 0);
		       cin       : in std_logic;
		       in_valid  : in std_logic;

		       result    : out std_logic_vector(31 downto 0);
		       cout      : out std_logic;
		       out_valid : out std_logic);	
	end component alu;

	signal clk_s       : std_logic := '0';
	signal reset_s     : std_logic := '0';
	signal aluop_s     : std_logic_vector(6 downto 0)  := (others => '0');
	signal src1_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal src2_s      : std_logic_vector(31 downto 0) := (others => '0');
	signal cin_s       : std_logic := '0';
	signal in_valid_s  : std_logic := '0';
	signal result_s    : std_logic_vector(31 downto 0) := (others => '0');
	signal cout_s      : std_logic := '0';
	signal out_valid_s : std_logic := '0';

	constant testval_1 : std_logic_vector(31 downto 0) := x"FFFFFFFF";
	constant testval_2 : std_logic_vector(31 downto 0) := x"00000000";
	constant testval_3 : std_logic_vector(31 downto 0) := x"00000001";
	constant testval_4 : std_logic_vector(31 downto 0) := x"80000000";
	constant testval_5 : std_logic_vector(31 downto 0) := x"11111111";
begin
	alu0 : alu port map (clk_s, reset_s, aluop_s, src1_s, src2_s, cin_s, in_valid_s,
	                     result_s, cout_s, out_valid_s);

	clk_s <= not clk_s after 10 ns;

	reset_s <= '1' after 10 ns,
	           '0' after 40 ns;
	
	testbench : process
	begin
		wait for 60 ns;

		for i in 1 to 50 loop
			aluop_s <= ("1000000" + std_logic_vector(to_unsigned(i, 7)));
			src1_s <= testval_1;
			src2_s <= testval_1;
			cin_s <= '0';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_1;
			src2_s <= testval_2;
			cin_s <= '0';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_1;
			src2_s <= testval_3;
			cin_s <= '0';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_2;
			src2_s <= testval_1;
			cin_s <= '0';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_3;
			src2_s <= testval_4;
			cin_s <= '1';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_4;
			src2_s <= testval_4;
			cin_s <= '1';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_5;
			src2_s <= testval_5;
			cin_s <= '1';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
			src1_s <= testval_1;
			src2_s <= testval_5;
			cin_s <= '1';
			in_valid_s <= '1';
			wait for 20 ns;
			in_valid_s <= '0';
			wait for 20 ns;
		end loop;	
	end process testbench;
end architecture test;

