-----------------------------------------------------------
--               rho-VEX | GR register file
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- testbenches/tb_registers_gr.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity tb_registers_gr is
end tb_registers_gr;

architecture test of tb_registers_gr is
	component registers_gr is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       read_en1   : in std_logic;
		       read_en2   : in std_logic;
		       write_en   : in std_logic;
		       address_r1 : in std_logic_vector(5 downto 0);
		       address_r2 : in std_logic_vector(5 downto 0);
		       address_w  : in std_logic_vector(5 downto 0);
		       data_in    : in std_logic_vector(31 downto 0);
		       
		       out_valid1 : out std_logic;
		       out_valid2 : out std_logic;
		       data_out1  : out std_logic_vector(31 downto 0);		     
		       data_out2  : out std_logic_vector(31 downto 0));		     
	end component registers_gr;

	signal clk_s        : std_logic := '0';
	signal reset_s      : std_logic := '0';
	signal read_en1_s   : std_logic := '0';
	signal read_en2_s   : std_logic := '0';
	signal write_en_s   : std_logic := '0';
	signal address_r1_s : std_logic_vector(5 downto 0) := (others => '0');
	signal address_r2_s : std_logic_vector(5 downto 0) := (others => '0');
	signal address_w_s  : std_logic_vector(5 downto 0) := (others => '0');
	signal data_in_s    : std_logic_vector(31 downto 0) := (others => '0');
	signal out_valid1_s : std_logic := '0';
	signal out_valid2_s : std_logic := '0';
	signal data_out1_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal data_out2_s  : std_logic_vector(31 downto 0) := (others => '0');
begin
	regs0 : registers_gr port map (clk_s, reset_s, read_en1_s, read_en2_s, write_en_s, address_r1_s, address_r2_s, address_w_s, data_in_s,
	                               out_valid1_s, out_valid2_s, data_out1_s, data_out2_s);

	clk_s <= not clk_s after 10 ns;

	reset_s <= '1' after 10 ns,
	           '0' after 40 ns;
	
	testbench : process
	begin
		wait for 60 ns;

		for i in 0 to 63 loop
			address_w_s <= std_logic_vector(to_unsigned(i, 6));
			data_in_s <= std_logic_vector(to_unsigned(i, 32));
			write_en_s <= '1';
			wait for 20 ns;
			write_en_s <= '0';
			wait for 20 ns;
		end loop;
		
		for i in 0 to 63 loop
			address_r1_s <= std_logic_vector(to_unsigned(i, 6));
			read_en1_s <= '1';
			wait for 20 ns;
			read_en1_s <= '0';
			wait for 20 ns;
		end loop;
		
		-- simultaneous read and write test
		address_w_s <= std_logic_vector(to_unsigned(1, 6));
		address_r1_s <= std_logic_vector(to_unsigned(2, 6));
		data_in_s <= std_logic_vector(to_unsigned(123, 32));
		write_en_s <= '1';
		read_en1_s <= '1';
	end process testbench;
end architecture test;

