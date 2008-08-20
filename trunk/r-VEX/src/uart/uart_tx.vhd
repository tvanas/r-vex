--------------------------------------------------------------------------------
-- UART | Transmitter unit
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
-- Input:      clk        | System clock at 1.8432 MHz
--             reset      | System reset
--             data_in    | Input data
--             in_valid   | Input data valid
--
-- Output:     tx         | TX line
--             accept_in  | '1' when transmitter accepts
--------------------------------------------------------------------------------
-- uart_tx.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity uart_tx is
	port ( clk        : in std_logic;
	       reset      : in std_logic;
	       data_in    : in std_logic_vector(7 downto 0);
	       in_valid   : in std_logic;

	       tx         : out std_logic;
	       accept_in  : out std_logic);
end entity uart_tx;


architecture behavioural of uart_tx is
	type tx_state is (reset_state, idle, start_bit, send_data, stop_bit);
	signal current_state, next_state : tx_state;
	signal data_counter : std_logic_vector(2 downto 0) := (others => '0');	
	signal ticker : std_logic_vector(3 downto 0) := (others => '0');	
begin
	-- Updates the states in the statemachine at a 115200 bps rate
	clkgen_115k2 : process(clk, reset)
	begin
		if (reset = '1') then
			ticker <= (others => '0');
			current_state <= reset_state;
			data_counter <= "000";
		elsif (clk = '1' and clk'event) then
			if (ticker = 15 or (current_state = idle and next_state = idle))  then
				ticker <= (others => '0');
				current_state <= next_state;
				if (current_state = send_data) then
					data_counter <= data_counter + 1;
				else
					data_counter <= "000";
				end if;
			else
				current_state <= current_state;    
				ticker <= ticker + 1;
			end if;
		end if;
	end process clkgen_115k2;
	
	tx_control : process (current_state, in_valid, data_counter)
	begin	 
		case current_state is
			when reset_state =>
				accept_in <= '0';
				tx <= '1';
				
				next_state <= idle;
			when idle =>
				accept_in <= '1';
				tx <= '1';
				
				if (in_valid = '1') then
					next_state <= start_bit;
				else
					next_state <= idle;
				end if;
			when start_bit =>
				accept_in <= '0';
				tx <= '0';

				next_state <= send_data;				
			when send_data =>
				accept_in <= '0';
				tx <= data_in(conv_integer(data_counter));
				
				if (data_counter = 7) then
					next_state <= stop_bit;
				else
					next_state <= send_data;
				end if;
			when stop_bit =>
				accept_in <= '0';
				tx <= '1';

				next_state <= idle;
			when others =>
				accept_in <= '0';
				tx <= '1';
				
				next_state <= reset_state;
		end case;
	end process tx_control;
end architecture behavioural;
