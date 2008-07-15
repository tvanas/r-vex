-----------------------------------------------------------
--         rho-VEX | Testbench Execute Stage
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- testbenches/tb_execute.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity tb_execute is
end tb_execute;

architecture test of tb_execute is
	component execute is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       opcode    : in std_logic_vector(6 downto 0);
		       operand1  : in std_logic_vector(31 downto 0);
		       operand2  : in std_logic_vector(31 downto 0);
		       operandb  : in std_logic_vector(31 downto 0);
		       start     : in std_logic;

		       result    : out std_logic_vector(31 downto 0);
		       resultb   : out std_logic_vector(31 downto 0);
		       accept_in : out std_logic;
		       out_valid : out std_logic);
	end component execute;

	signal clk_s       : std_logic := '0';
	signal reset_s     : std_logic := '0';
	signal opcode_s    : std_logic_vector(6 downto 0) := (others => '0');
	signal operand1_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal operandb_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal result_s    : std_logic_vector(31 downto 0) := (others => '0');
	signal resultb_s   : std_logic_vector(31 downto 0) := (others => '0');
	signal start_s     : std_logic := '0';
	signal accept_in_s : std_logic := '0';
	signal out_valid_s : std_logic := '0';

begin
	execute0 : execute port map (clk_s, reset_s, opcode_s, operand1_s, operand2_s, operandb_s, start_s,
	                             result_s, resultb_s, accept_in_s, out_valid_s);

	clk_s <= not clk_s after 10 ns;

	reset_s <= '1' after 10 ns,
	           '0' after 40 ns;
	
	testbench : process
	begin
		wait for 60 ns;
		opcode_s   <= "1000001"; -- ALU operation ADD
		operand1_s <= x"00000004";
		operand2_s <= x"00000005";
		wait for 20 ns;
		start_s    <= '1';
		wait for 80 ns;
		start_s    <= '0';
		wait for 60 ns;
		opcode_s   <= "0000001"; -- MUL operation low x low
		operand1_s <= x"00000004";
		operand2_s <= x"00000005";
		wait for 20 ns;
		start_s    <= '1';
	end process testbench;
end architecture test;

