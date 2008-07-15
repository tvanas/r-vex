-----------------------------------------------------------
-- r-VEX | Stand-alone system
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- system.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity system is
	port ( clk       : in std_logic;   -- system clock
	       reset     : in std_logic;   -- system reset
	       
	       tx        : out std_logic); -- tx signal for UART
end entity system;


architecture behavioural of system is
	-- r-VEX processor core
	component rVEX is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       instr      : in std_logic_vector(127 downto 0);
		       data_in    : in std_logic_vector((DMEM_WIDTH - 1) downto 0);
		       run        : in std_logic;

		       done       : out std_logic;
		       cycles     : out std_logic_vector(31 downto 0);
		       address_i  : out std_logic_vector(7 downto 0);
		       address_dr : out std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       address_dw : out std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       write_en_d : out std_logic;
		       data_out   : out std_logic_vector((DMEM_WIDTH - 1) downto 0));
	end component rVEX;
	
	-- Instruction memory
	component i_mem is
		port ( reset     : in std_logic;
		       address   : in std_logic_vector(7 downto 0);

		       instr     : out std_logic_vector(127 downto 0));
	end component i_mem;

	-- Data memory
	component d_mem is
		port ( clk        : in std_logic;
		       write_en   : in std_logic;
		       address_r1 : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       address_r2 : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       address_w  : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);
		       data_in    : in std_logic_vector((DMEM_WIDTH - 1) downto 0);
	       
		       data_out1  : out std_logic_vector((DMEM_WIDTH - 1) downto 0);
		       data_out2  : out std_logic_vector((DMEM_WIDTH - 1) downto 0));
	end component d_mem;

	-- Debug UART
	component uart is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       ready      : in std_logic;
		       cycles     : in std_logic_vector(31 downto 0);
		       data_in    : in std_logic_vector(31 downto 0);

		       address    : out std_logic_vector(7 downto 0);
		       tx         : out std_logic);
	end component uart;

	-- clock divider to generate clock of 0.5 * clk frequency
	-- to meet timing constraints
	component clk_div is
		port ( clk        : in std_logic;
		       clk_out    : out std_logic);
	end component clk_div;
	
	signal clk_half         : std_logic := '0';
	signal clk_uart_s       : std_logic := '0';
	signal run_s            : std_logic := '0';
	signal reset_s          : std_logic := '0';
	signal address_i_s      : std_logic_vector(7 downto 0) := (others => '0');
	signal address_dr_s     : std_logic_vector((DMEM_LOGDEP - 1) downto 0) := (others => '0');
	signal address_dw_s     : std_logic_vector((DMEM_LOGDEP - 1) downto 0) := (others => '0');
	signal write_en_d_s     : std_logic := '0';
	signal m2rvex_data_s    : std_logic_vector((DMEM_WIDTH - 1) downto 0) := (others => '0');
	signal rvex2m_data_s    : std_logic_vector((DMEM_WIDTH - 1) downto 0) := (others => '0');
	signal instr_s          : std_logic_vector(127 downto 0) := (others => '0');
	signal done_s           : std_logic := '0';
	signal cycles_s         : std_logic_vector(31 downto 0) := (others => '0');
	signal address_uart_s   : std_logic_vector((DMEM_LOGDEP - 1) downto 0) := (others => '0');
	signal data_uart_s      : std_logic_vector(31 downto 0);
	signal start_counter_s  : std_logic_vector(1 downto 0) := (others => '0');
begin
	clk05 : clk_div port map (clk => clk,
	                          clk_out => clk_half);

	rVEX0  : rVEX port map   (clk => clk_half,
	                          reset => reset_s,
	                          instr => instr_s,
	                          data_in => m2rvex_data_s,
	                          run => run_s,

	                          done => done_s,
	                          cycles => cycles_s,
	                          address_i => address_i_s,
	                          address_dr => address_dr_s,
	                          address_dw => address_dw_s,
	                          write_en_d => write_en_d_s,
	                          data_out => rvex2m_data_s);

	i_mem0 : i_mem port map  (reset => reset_s,
	                          address => address_i_s,

	                          instr => instr_s);

	d_mem0 : d_mem port map  (clk => clk_half,
	                          write_en => write_en_d_s,
	                          address_r1 => address_dr_s,
	                          address_r2 => address_uart_s,
	                          address_w => address_dw_s,
	                          data_in => rvex2m_data_s,
	
	                          data_out1 => m2rvex_data_s,
	                          data_out2 => data_uart_s);

	uart0 : uart port map    (clk => clk_uart_s,
	                          reset => reset_s,
	                          ready => done_s,
	                          cycles => cycles_s,
	                          data_in => data_uart_s,

	                          address => address_uart_s,
	                          tx => tx);

	
	update_counter : process (clk, reset_s)
	begin
		if (reset_s	= '1') then
			start_counter_s <= (others => '0');
		elsif (clk = '1' and clk'event) then
			start_counter_s <= start_counter_s + 1;
		end if;
	end process update_counter;

	igniter : process (clk, reset_s)
	begin
		if (reset_s = '1') then
			run_s <= '0';
		elsif (clk = '1' and clk'event) then
			if (start_counter_s > "10") then
				run_s <= '1';
			end if;
		end if;
	end process igniter;

	-- buttons on Virtex-II Pro board are active high, on Spartan-3E board active low
	reset_s <= reset xor ACTIVE_LOW;
	
	-- clk is 100 MHz on Virtex-II Pro board, 50 MHz on Spartan-3E board.
	-- UART needs a 50 MHz clock, so clk_half is fed on Virtex-II Pro board,
	-- whilst clk is fed on Spartan-3E board.
	clk_uart_s <= clk_half when (ACTIVE_LOW = '1') else clk;
end architecture behavioural;

