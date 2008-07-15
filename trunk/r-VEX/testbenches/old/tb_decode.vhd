-----------------------------------------------------------
--       rho-VEX | Testbench Syllable Decode Stage
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- testbenches/tb_decode.vhd
-----------------------------------------------------------
-- Testsbench for decode + execute + GR + BR (read/write)
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

entity tb_decode is
end tb_decode;

architecture test of tb_decode is
	component syl_decode is
		port ( clk       : in std_logic;
		       reset     : in std_logic;
		       syllable  : in std_logic_vector(31 downto 0);
		       src1      : in std_logic_vector(31 downto 0);
		       src2      : in std_logic_vector(31 downto 0);
		       srcb      : in std_logic_vector(31 downto 0);
		       src1_ok   : in std_logic;
		       src2_ok   : in std_logic;
		       srcb_ok   : in std_logic;
		       exe_in    : in std_logic;
		       exe_ok    : in std_logic;
		       start     : in std_logic;

		       opcode    : out std_logic_vector(6 downto 0);
		       src1_reg  : out std_logic_vector(5 downto 0);
		       src2_reg  : out std_logic_vector(5 downto 0);
		       srcb_reg  : out std_logic_vector(2 downto 0);
		       write_g   : out std_logic;
		       write_b   : out std_logic;
		       src1_en   : out std_logic;
		       src2_en   : out std_logic;
		       srcb_en   : out std_logic;
		       operand1  : out std_logic_vector(31 downto 0);
		       operand2  : out std_logic_vector(31 downto 0);
		       operandb  : out std_logic_vector(31 downto 0);
		       dest_reg  : out std_logic_vector(5 downto 0);
		       destb_reg : out std_logic_vector(2 downto 0);
		       ops_ready : out std_logic;
		       accept_in : out std_logic);
	end component syl_decode;

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

	component registers_br is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       read_en    : in std_logic;
		       write_en   : in std_logic;
		       address_r  : in std_logic_vector(2 downto 0);
		       address_w  : in std_logic_vector(2 downto 0);
		       data_in    : in std_logic_vector(31 downto 0);

		       out_valid  : out std_logic;
		       data_out   : out std_logic_vector(31 downto 0));
	end component registers_br;
	
	component writeback is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       write_en   : in std_logic;
		       address_gi : in std_logic_vector(5 downto 0);
		       address_bi : in std_logic_vector(2 downto 0);
		       data_gi    : in std_logic_vector(31 downto 0);
		       data_bi    : in std_logic_vector(31 downto 0);
		       write_g    : in std_logic;
		       write_b    : in std_logic;

		       written    : out std_logic;
		       write_g_en : out std_logic;
		       write_b_en : out std_logic;
		       address_go : out std_logic_vector(5 downto 0);
		       address_bo : out std_logic_vector(2 downto 0);
		       data_go    : out std_logic_vector(31 downto 0);
		       data_bo    : out std_logic_vector(31 downto 0);
		       accept_in  : out std_logic);
	end component writeback;
		
	signal clk_s       : std_logic := '0';
	signal reset_s     : std_logic := '0';
	signal opcode_s    : std_logic_vector(6 downto 0) := (others => '0');
	signal operand1_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal operand2_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal operandb_s  : std_logic_vector(31 downto 0) := (others => '0');
	signal result_s    : std_logic_vector(31 downto 0) := (others => '0');
	signal resultb_s   : std_logic_vector(31 downto 0) := (others => '0');
	signal start_dec_s : std_logic := '0';
	signal accept_in_dec_s : std_logic := '0';
	signal ops_ready_s : std_logic := '0';
	
	signal write_en_s  : std_logic := '0';
	signal address_w_s : std_logic_vector(5 downto 0) := (others => '0');
	signal data_in_s   : std_logic_vector(31 downto 0) := (others => '0');
	signal write_enb_s  : std_logic := '0';
	signal address_wb_s : std_logic_vector(2 downto 0) := (others => '0');
	signal data_inb_s   : std_logic_vector(31 downto 0) := (others => '0');
	
	signal syllable_s   : std_logic_vector(31 downto 0) := (others => '0');
	signal src1_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal src2_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal srcb_s       : std_logic_vector(31 downto 0) := (others => '0');
	signal src1_ok_s    : std_logic := '0';
	signal src2_ok_s    : std_logic := '0';
	signal srcb_ok_s    : std_logic := '0';
	signal src1_en_s    : std_logic := '0';
	signal src2_en_s    : std_logic := '0';
	signal srcb_en_s    : std_logic := '0';
	
	signal write_g_s    : std_logic := '0';
	signal write_b_s    : std_logic := '0';
	signal destb_reg_s  : std_logic_vector(2 downto 0) := (others => '0');
	signal dest_reg_s   : std_logic_vector(5 downto 0) := (others => '0');
	signal src1_reg_s   : std_logic_vector(5 downto 0) := (others => '0');
	signal src2_reg_s   : std_logic_vector(5 downto 0) := (others => '0');
	signal srcb_reg_s   : std_logic_vector(2 downto 0) := (others => '0');

	signal accept_in_ex_s : std_logic := '0';
	signal out_valid_s  : std_logic := '0';
	signal wbwritten_s : std_logic := '0';
	signal wbaccept_s  : std_logic := '0';	
begin
	syl_decode0 : syl_decode port map (clk_s, reset_s, syllable_s, src1_s, src2_s, srcb_s, src1_ok_s, src2_ok_s, srcb_ok_s, accept_in_ex_s, out_valid_s, start_dec_s,
	                                   opcode_s, src1_reg_s, src2_reg_s, srcb_reg_s, write_g_s, write_b_s, src1_en_s, src2_en_s, srcb_en_s, operand1_s, operand2_s,
					   operandb_s, dest_reg_s, destb_reg_s, ops_ready_s, accept_in_dec_s); 
					   
	execute0 : execute port map (clk_s, reset_s, opcode_s, operand1_s, operand2_s, operandb_s, ops_ready_s,
	                             result_s, resultb_s, accept_in_ex_s, out_valid_s);
	
	registers_gr0 : registers_gr port map (clk_s, reset_s, src1_en_s, src2_en_s, write_en_s, src1_reg_s, src2_reg_s, address_w_s, data_in_s,
	                                       src1_ok_s, src2_ok_s, src1_s, src2_s);

	registers_br0 : registers_br port map (clk_s, reset_s, srcb_en_s, write_enb_s, srcb_reg_s, address_wb_s, data_inb_s,
	                                       srcb_ok_s, srcb_s);

	writeback0 : writeback port map (clk_s, reset_s, out_valid_s, dest_reg_s, destb_reg_s, result_s, resultb_s, write_g_s, write_b_s,
	                                 wbwritten_s, write_en_s, write_enb_s, address_w_s, address_wb_s, data_in_s, data_inb_s, wbaccept_s);
					 
	clk_s <= not clk_s after 10 ns;

	reset_s <= '1' after 10 ns,
	           '0' after 40 ns;
	
	testbench : process
	begin
		wait for 60 ns;
		syllable_s   <= "10000010011111100000100001000011"; -- ALU operation ADD, store in GR 63
		wait for 20 ns;
		start_dec_s    <= '1';
		wait for 20 ns;
		start_dec_s    <= '0';
		wait for 200 ns;
		syllable_s   <= "00000010011111000000100001000011"; -- MUL operation low x low, store in GR 62
		start_dec_s    <= '1';
		wait for 20 ns;
		start_dec_s    <= '0';
		wait for 1000 ns;
	end process testbench;
end architecture test;

