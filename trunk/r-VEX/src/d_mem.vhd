-----------------------------------------------------------
-- r-VEX | Data memory
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- Implementation uses BRAM
-----------------------------------------------------------
-- d_mem.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

entity d_mem is
	port ( clk        : in std_logic; -- system clock
	       write_en   : in std_logic; -- write enable
	       address_r1 : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);  -- address to read from (r-VEX)
	       address_r2 : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);  -- address to read from (UART)
	       address_w  : in std_logic_vector((DMEM_LOGDEP - 1) downto 0);  -- address to write to
	       data_in    : in std_logic_vector((DMEM_WIDTH - 1) downto 0);   -- data to write
	       
	       data_out1  : out std_logic_vector((DMEM_WIDTH - 1) downto 0);  -- data to be read (r-VEX)
	       data_out2  : out std_logic_vector((DMEM_WIDTH - 1) downto 0)); -- data to be read (UART)
end entity d_mem;


architecture behavioural of d_mem is
	type mem_t is array (0 to (DMEM_DEPTH - 1)) of std_logic_vector((DMEM_WIDTH - 1) downto 0);
	signal d_memory : mem_t := (others => (others => '0'));
begin
	mem_handler : process(clk)
	begin
		if (clk = '1' and clk'event) then
			if (write_en = '1') then				
				d_memory(conv_integer(address_w)) <= data_in;
			end if;	
		
			data_out1 <= d_memory(conv_integer(address_r1));
			data_out2 <= d_memory(conv_integer(address_r2));
		end if;
	end process mem_handler;
end architecture behavioural;

