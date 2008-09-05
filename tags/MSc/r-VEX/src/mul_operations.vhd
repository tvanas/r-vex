--------------------------------------------------------------------------------
-- r-VEX | Package with multiplier procedures
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
-- All operations that can be performed by the multiplier
--------------------------------------------------------------------------------
-- mul_operations.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

package mul_operations is
	procedure f_MPYLL  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));

	procedure f_MPYLLU ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));

	procedure f_MPYLH  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYLHU ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYHH  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYHHU ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYL   ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYLU  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYH   ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYHU  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_MPYHS  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0));
end package mul_operations;


package body mul_operations is
	procedure f_MPYLL  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
			     signal result : out std_logic_vector(31 downto 0)) is
	begin
		overflow <= '0';
		result <= std_logic_vector((signed(s1(15 downto 0)) * signed(s2(15 downto 0))));
	end procedure f_MPYLL;
	
	procedure f_MPYLLU ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
	begin
		overflow <= '0';
		result <= std_logic_vector((unsigned(s1(15 downto 0)) * unsigned(s2(15 downto 0))));
	end procedure f_MPYLLU;
	
	procedure f_MPYLH  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
	begin
		overflow <= '0';
		result <= std_logic_vector((signed(s1(15 downto 0)) * signed(s2(31 downto 16))));
	end procedure f_MPYLH;
	
	procedure f_MPYLHU ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
	begin
		overflow <= '0';
		result <= std_logic_vector((unsigned(s1(15 downto 0)) * unsigned(s2(31 downto 16))));
	end procedure f_MPYLHU;
	
	procedure f_MPYHH  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
	begin
		overflow <= '0';
		result <= std_logic_vector((signed(s1(31 downto 16)) * signed(s2(31 downto 16))));
	end procedure f_MPYHH;
	
	procedure f_MPYHHU ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
	begin
		overflow <= '0';
		result <= std_logic_vector((signed(s1(31 downto 16)) * signed(s2(31 downto 16))));
	end procedure f_MPYHHU;
	
	procedure f_MPYL   ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable tmp : std_logic_vector(47 downto 0) := (others => '0'); 
	begin
		tmp := std_logic_vector((signed(s1(31 downto 0)) * signed(s2(15 downto 0))));

		if (tmp(47 downto 32) > 0) then
			overflow <= '1';
			if (tmp(47) = '1') then     -- negative result
				result <= x"80000000";
			else                        -- positive result
				result <= x"7FFFFFFF";
			end if;
		else
			overflow <= '0';
			result <= tmp(31 downto 0);
		end if;
	end procedure f_MPYL;
	
	procedure f_MPYLU  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable tmp : std_logic_vector(47 downto 0) := (others => '0'); 
	begin
		tmp := std_logic_vector((unsigned(s1(31 downto 0)) * unsigned(s2(15 downto 0))));

		if (tmp(47 downto 32) > 0) then
			overflow <= '1';
			result <= x"FFFFFFFF";
		else
			overflow <= '0';
			result <= tmp(31 downto 0);
		end if;
	end procedure f_MPYLU;
	
	procedure f_MPYH   ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable tmp : std_logic_vector(47 downto 0) := (others => '0'); 
	begin
		tmp := std_logic_vector((signed(s1(31 downto 0)) * signed(s2(31 downto 16))));

		if (tmp(47 downto 32) > 0) then
			overflow <= '1';
			if (tmp(47) = '1') then     -- negative result
				result <= x"80000000";
			else                        -- positive result
				result <= x"7FFFFFFF";
			end if;
		else
			overflow <= '0';
			result <= tmp(31 downto 0);
		end if;		
	end procedure f_MPYH;
	
	procedure f_MPYHU  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable tmp : std_logic_vector(47 downto 0) := (others => '0'); 
	begin
		tmp := std_logic_vector((unsigned(s1(31 downto 0)) * unsigned(s2(31 downto 16))));

		if (tmp(47 downto 32) > 0) then
			overflow <= '1';
			result <= x"FFFFFFFF";
		else
			overflow <= '0';
			result <= tmp(31 downto 0);
		end if;		
	end procedure f_MPYHU;
	
	procedure f_MPYHS  ( s1, s2 : in std_logic_vector(31 downto 0);
	                     signal overflow : out std_logic;
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable tmp  : std_logic_vector(47 downto 0) := (others => '0'); 
		variable tmp2 : std_logic_vector(47 downto 0) := (others => '0'); 
	begin
		tmp := (std_logic_vector((signed(s1(31 downto 0)) * signed(s2(31 downto 16)))));
		
		if (tmp(47 downto 32) > 0) then
			overflow <= '1';
			result <= x"FFFFFFFF";
		else
			overflow <= '0';
			tmp2 := (SHL (tmp, "10000"));
			result <= tmp2(31 downto 0);
		end if;		
	end procedure f_MPYHS;
end package body mul_operations;

