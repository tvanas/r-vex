--------------------------------------------------------------------------------
-- UART | Transmitter
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
-- Input:      clk        | System clock
--             reset      | System reset
--             ready      | r-VEX is done
--             cycles     | Number of cycles execution took
--             data_in    | Data to be transmitted from memory
--
-- Output:     address    | Address to read from data memory
--             tx         | TX signal
--------------------------------------------------------------------------------
-- uart.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.uart_pkg.all;

entity uart is
	port ( clk        : in std_logic;
	       reset      : in std_logic;
	       ready      : in std_logic;
	       cycles     : in std_logic_vector(31 downto 0);
	       data_in    : in std_logic_vector(31 downto 0);
	
	       address    : out std_logic_vector(7 downto 0);
	       tx         : out std_logic);
end entity uart;

architecture behavioural of uart is
	component clk_18432 is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       
		       clk_18432  : out std_logic);
	end component clk_18432;
	
	component uart_tx is
		port ( clk        : in std_logic;
		       reset      : in std_logic;
		       data_in    : in std_logic_vector(7 downto 0);
		       in_valid   : in std_logic;

		       tx         : out std_logic;
		       accept_in  : out std_logic);
	end component uart_tx;

	signal clk_18432_s : std_logic := '0';
	signal data_s  : std_logic_vector(7 downto 0) := x"00";
	signal in_valid_s : std_logic := '0';
	signal accept_s  : std_logic := '0';
	signal counter_s : std_logic_vector(8 downto 0) := (others => '0');
	signal ready_s : std_logic := '0';
	signal in_valid_welcome_s : std_logic := '0';
	signal in_valid_data_s : std_logic := '0';
	signal counter_welcome_s : std_logic_vector(7 downto 0) := (others => '0');
	signal switch_s : std_logic := '1';
	signal cnt_s  : std_logic_vector(7 downto 0) := x"00";
	signal hex8_s : std_logic_vector(7 downto 0) := x"00";
	signal hex7_s : std_logic_vector(7 downto 0) := x"00";
	signal hex6_s : std_logic_vector(7 downto 0) := x"00";
	signal hex5_s : std_logic_vector(7 downto 0) := x"00";
	signal hex4_s : std_logic_vector(7 downto 0) := x"00";
	signal hex3_s : std_logic_vector(7 downto 0) := x"00";
	signal hex2_s : std_logic_vector(7 downto 0) := x"00";
	signal hex1_s : std_logic_vector(7 downto 0) := x"00";

	-- Xilinx specific clock buffer attributes
	attribute buffer_type   : string;
	attribute buffer_type of clk_18432_s  : signal is "BUFG";
	attribute buffer_type of accept_s  : signal is "BUFG";
begin
	clk_gen : clk_18432 port map ( clk => clk,
	                               reset => reset,
				       
	                               clk_18432 => clk_18432_s);
				
	tx_0 : uart_tx port map      ( clk => clk_18432_s,
	                               reset => reset,
	                               data_in => data_s,
	                               in_valid => in_valid_s,

	                               tx => tx,
	                               accept_in => accept_s);

	update_welcome_counter : process (accept_s, ready)
	begin
		if (ready = '0') then
			counter_welcome_s <= (others => '0');
		elsif (accept_s = '1' and accept_s'event) then
			counter_welcome_s <= counter_welcome_s + 1;
		end if;
	end process update_welcome_counter;

	update_counter : process (accept_s, ready_s)
	begin
		if (ready_s = '0') then
			counter_s <= (others => '0');
		elsif (accept_s = '1' and accept_s'event) then
			counter_s <= counter_s + 1;
		end if;
	end process update_counter;

	update_dmem : process(clk, reset)
	begin
		if (reset = '1') then
			address <= (others => '0');
		elsif (clk = '1' and clk'event) then
			address <= "0000" & counter_s(8 downto 5);
		end if;
	end process update_dmem;

	input_adapt : process(clk, reset)
	begin
		if (reset = '1') then
			cnt_s <= x"00";
			hex1_s <= x"00";
			hex2_s <= x"00";
			hex3_s <= x"00";
			hex4_s <= x"00"; 
			hex5_s <= x"00";
			hex6_s <= x"00";
			hex7_s <= x"00";
			hex8_s <= x"00"; 
		elsif (clk = '1' and clk'event) then
			cnt_s <= to_hex_ascii(counter_s(8 downto 5));
			hex8_s <= to_hex_ascii(data_in(31 downto 28));
			hex7_s <= to_hex_ascii(data_in(27 downto 24));
			hex6_s <= to_hex_ascii(data_in(23 downto 20));
			hex5_s <= to_hex_ascii(data_in(19 downto 16));
			hex4_s <= to_hex_ascii(data_in(15 downto 12));
			hex3_s <= to_hex_ascii(data_in(11 downto 8));
			hex2_s <= to_hex_ascii(data_in(7 downto 4));
			hex1_s <= to_hex_ascii(data_in(3 downto 0));
		end if;
	end process input_adapt;

	update_data : process (clk, reset)
	begin
		if (reset = '1') then
			data_s <= (others => '0');
		elsif (clk = '1' and clk'event) then
			if (ready_s = '0') then
				data_s <= init_message(counter_welcome_s, cycles);
			else
				case counter_s(4 downto 0) is
					when "00000" =>
						data_s <= "00001101"; -- CR Carriage Return
					when "00001" =>
						data_s <= "00001010"; -- LF Line Feed
					when "00010" =>
						data_s <= "00110000"; -- 0
					when "00011" =>
						data_s <= "01111000"; -- x
					when "00100" =>
						data_s <= "00110000"; -- 0
					when "00101" =>
						data_s <= cnt_s;      -- Hexadecimal address value
					when "00110" =>
						data_s <= "00100000"; -- SP Space
					when "00111" =>
						data_s <= "01111100"; -- |
					when "01000" =>
						data_s <= "00100000"; -- SP Space
					when "01001" =>
						data_s <= "00110000"; -- 0
					when "01010" =>
						data_s <= "01111000"; -- x
					when "01011" =>
						data_s <= hex8_s;     -- Most significant hex digit of value
					when "01100" =>
						data_s <= hex7_s;
					when "01101" =>
						data_s <= hex6_s;
					when "01110" =>
						data_s <= hex5_s;
					when "01111" =>
						data_s <= hex4_s;
					when "10000" =>
						data_s <= hex3_s;
					when "10001" =>
						data_s <= hex2_s;
					when "10010" =>
						data_s <= hex1_s;     -- Least siginificant hex digit of value
					when others =>
						data_s <= "00000000"; -- null
				end case;
			end if;
		end if;
	end process update_data;

	update_ready : process (clk, reset)
	begin
		if (reset = '1') then
			ready_s <= '0';
		elsif (clk = '1' and clk'event) then
			if (counter_welcome_s > x"5E") then
				ready_s <= '1';
			end if;
		end if;
	end process update_ready;

	welcome_message : process (clk, ready)
	begin
		if (ready = '0') then
			in_valid_welcome_s <= '0';
		elsif (clk = '1' and clk'event) then
			if (counter_welcome_s < "11111111") then
				in_valid_welcome_s <= '1';
			else
				in_valid_welcome_s <= '0';
			end if;
		end if;
	end process welcome_message;

	send_data : process (clk, ready_s)
	begin
		if (ready_s = '0') then
			in_valid_data_s <= '0';
		elsif (clk = '1' and clk'event) then
			if (counter_s < "111111111") then
				in_valid_data_s <= '1';
			else
				in_valid_data_s <= '0';
			end if;
		end if;
	end process send_data;

	uart_switch : process (clk, reset)
	begin
		if (reset = '1') then
			switch_s <= '1';
		elsif (clk = '1' and clk'event) then
			if (counter_s > "111110011" ) then
				switch_s <= '0';
			end if;
		end if;
	end process uart_switch;

	in_valid_s <= (in_valid_welcome_s or in_valid_data_s) and switch_s;
end architecture behavioural;

