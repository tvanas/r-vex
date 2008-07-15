-----------------------------------------------------------
-- r-VEX | Clock divider
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- Used because to meet timing constraints
-----------------------------------------------------------
-- clk_div.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
	port ( clk : in std_logic;       -- system clock

	       clk_out : out std_logic); -- output clock (0.5 * clk freq)
end clk_div;


architecture behavioral of clk_div is
	signal clk_s   : std_logic := '0';
begin
	clk_out <= clk_s;

	clock_divider : process(clk)
	begin
		if (clk = '1' and clk'event) then
			clk_s <= not clk_s;
		end if;
	end process;
end behavioral;

