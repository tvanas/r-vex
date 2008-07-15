-----------------------------------------------------------
-- r-VEX | Instruction fetch unit
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- fetch.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fetch is
	port ( clk        : in std_logic; -- system clock
	       reset      : in std_logic; -- system reset
	       instr      : in std_logic_vector(127 downto 0); -- instruction (4 syllables)
	       next_syl   : in std_logic; -- '1' when syllable is decoded
	       start      : in std_logic; -- '1' when to start execution of r-VEX
	       stop       : in std_logic; -- '1' when STOP syllable is decoded
	       pc         : in std_logic_vector(7 downto 0);   -- current program counter
	       
	       syllable_0 : out std_logic_vector(31 downto 0); -- syllable 0
	       syllable_1 : out std_logic_vector(31 downto 0); -- syllable 1
	       syllable_2 : out std_logic_vector(31 downto 0); -- syllable 2
	       syllable_3 : out std_logic_vector(31 downto 0); -- syllabel 3
	       stop_out   : out std_logic;                     -- '1' when execution has stopped
	       cycles     : out std_logic_vector(31 downto 0); -- number of clock cycles the execution took
	       address    : out std_logic_vector(7 downto 0);  -- address in instruction memory to be read
	       out_valid  : out std_logic);                    -- '1' when syllables are valid
end entity fetch;

architecture behavioural of fetch is
	type fetch_states is (reset_state, waiting, send_syllable);
	signal current_state, next_state: fetch_states;

	signal running_s   : std_logic := '0';
	signal cycles_i    : std_logic_vector(31 downto 0) := x"00000000";
	signal stop_i      : std_logic := '0';
	signal out_valid_i : std_logic := '0';
begin	
	out_valid <= out_valid_i;
	stop_out <= stop_i;
	cycles <= cycles_i;

	-- Counts running cycles
	cycle_counter : process(clk, reset)
	begin 
		if (reset = '1') then
			cycles_i <= (others => '0');
		elsif (clk = '1' and clk'event) then
			if (running_s = '1' and stop_i = '0') then
				cycles_i <= cycles_i + 1;
			else
				cycles_i <= cycles_i;
			end if;
		end if;
	end process cycle_counter;

	-- Checks for stop signal
	-- TODO: move this to writeback stage
	stop_check : process(stop, reset) is
	begin
		if (reset = '1') then
			stop_i <= '0';
		elsif (stop = '1' and stop'event) then
			stop_i <= '1';
		end if;
	end process stop_check;

	-- Synchronizes fetch states
	synchronize : process (clk, reset)
	begin
		if (reset = '1') then
			current_state <= reset_state;
		elsif (clk = '1' and clk'event) then
			current_state <= next_state;
		end if;
	end process synchronize;
	
	-- Output
	fetch_out : process(current_state, pc, instr) is
	begin
		syllable_0 <= (others => 'X');
		syllable_1 <= (others => 'X');
		address <= (others => 'X');

		case current_state is
			when reset_state =>
				syllable_0 <= (others => '0');
				syllable_1 <= (others => '0');
				syllable_2 <= (others => '0');
				syllable_3 <= (others => '0');
				address <= (others => '0');
				out_valid_i <= '0';
				running_s <= '0';
			when waiting =>
				syllable_0 <= instr(31 downto 0);
				syllable_1 <= instr(63 downto 32);
				syllable_2 <= instr(95 downto 64);
				syllable_3 <= instr(127 downto 96);
				address <= pc;
				out_valid_i <= '0';
				running_s <= '1';
			when send_syllable =>
				syllable_0 <= instr(31 downto 0);
				syllable_1 <= instr(63 downto 32);
				syllable_2 <= instr(95 downto 64);
				syllable_3 <= instr(127 downto 96);
				address <= pc;
				out_valid_i <= '1';
				running_s <= '1';
		end case;
	end process fetch_out;
	
	-- Controls syllable fetch stage
	fetch_control: process(clk, current_state, start, stop_i, next_syl)
	begin		
		case current_state is
			when reset_state =>
				if (start = '1' and stop_i = '0') then
					next_state <= waiting;
				else
					next_state <= reset_state;
				end if;
			when waiting =>
				if (next_syl = '1' and stop_i = '0') then
					next_state <= send_syllable;
				else
					next_state <= waiting;
				end if;
			when send_syllable =>
				if (next_syl = '0' and stop_i = '0') then
					next_state <= waiting;
				else
					next_state <= send_syllable;
				end if;
		end case;
	end process fetch_control;
end architecture behavioural;

