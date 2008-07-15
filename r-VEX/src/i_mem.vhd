-----------------------------------------------------------
-- r-VEX | Instruction ROM
-----------------------------------------------------------
--
-- Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
--
-----------------------------------------------------------
-- i_mem.vhd
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity i_mem is
	port ( reset   : in std_logic;                        -- system reset
	       address : in std_logic_vector(7 downto 0);     -- address of instruction to be read

	       instr   : out std_logic_vector(127 downto 0)); -- instruction (4 syllables)
end entity i_mem;


architecture behavioural of i_mem is
begin
	memory : process(address, reset)
	begin
		if (reset = '1') then
			instr <= x"00000000000000000000000000000000";
		else
			case address is
				-- VLIW test
				when x"00"  => instr <= "10110000000000100000000000000011" & -- syllable 3: mov $r1, $r0
				                        "10110000000001000000000000000011" & -- syllable 2: mov $r2, $r0
				                        "10110000000001100000000000000011" & -- syllable 1: mov $r3, $r0
				                        "10110000000010000000000000000011";  -- syllable 0: mov $r4, $r0
				when x"01"  => instr <= "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "10000011000110000000000000111111" & -- $r12 = 15
				                        "11001110000000000000000000000111";  -- mtb $b1, $r0
				when x"02"  => instr <= "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "10110010000000000000100110000111" & -- cmpeq $b1, $r1, $r12 ($b1 = ($r1 == $r12))
				                        "01001010100000000000000011000111";  -- br $b1, x"06" (if $b1 goto x"06")
				when x"03"  => instr <= "10000011000010000010000000010011" & -- $r4 = $r4 + 4 
				                        "10000011000001100001100000001111" & -- $r3 = $r3 + 3
				                        "10000011000001000001000000001011" & -- $r2 = $r2 + 2
				                        "10000011000000100000100000000111";  -- $r1 = $r1 + 1
				when x"04"  => instr <= "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "01000010100000000000000001000011";  -- goto x"02"
				when x"05"  => instr <= "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "10000011000111100000000000000111";  -- $r15 = 1
				when x"06"  => instr <= "00000000000000000000000000000000" & -- NOP
				                        "00000100000001100000100001000011" & -- $r3  = $r1 * $r2
				                        "00000101000010000000100001000011" & -- $r4  = $r1 * 16
				                        "00000000000000000000000000000000";  -- NOP
				when x"07"  => instr <= "00101100000000100111100000000011" & -- stw [0]$r15 = $r1
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000";  -- NOP
				when x"08"  => instr <= "00101100000001000111100000010011" & -- stw [4]$r15 = $r2
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000";  -- NOP
				when x"09"  => instr <= "00101100000001100111100000100011" & -- stw [8]$r15 = $r1
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000";  -- NOP
				when x"0A"  => instr <= "00101100000010000111100000110011" & -- stw [12]$r15 = $r2
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000";  -- NOP
				when others => instr <= "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00000000000000000000000000000000" & -- NOP
				                        "00111110000000000000000000000000";  -- STOP
			end case;
		end if;
	end process memory;
end architecture behavioural;
