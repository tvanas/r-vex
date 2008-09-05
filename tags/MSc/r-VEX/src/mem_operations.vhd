--------------------------------------------------------------------------------
-- r-VEX | Package with memory functions and procedures
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
-- All operations that can be performed by the memory unit
--------------------------------------------------------------------------------
-- mem_operations.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

package mem_operations is
	function f_LDW     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0))
	                     return std_logic_vector;
	
	function f_LDH     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector;
	
	function f_LDHU    ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector;
	
	function f_LDB     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector;
	
	function f_LDBU    ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector;
	
	function f_STW     ( reg_val : std_logic_vector(31 downto 0))
	                     return std_logic_vector;
	
	function f_STH     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     reg_val : std_logic_vector(31 downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector;
	
	function f_STB     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     reg_val : std_logic_vector(31 downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector;
end package mem_operations;


package body mem_operations is
	function f_LDW     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0))
	                     return std_logic_vector is
	begin
		return mem_val;
	end function f_LDW;
	
	function f_LDH     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector is
	begin
		case pos is
			when "00" =>
				return (x"0000" & mem_val(31 downto 16));
			when "01" =>
				return (x"0000" & mem_val(23 downto 8));
			when "10" =>
				return (x"0000" & mem_val(15 downto 0));
			when others => -- not allowed
				return x"FFFFFFFF";
		end case;
	end function f_LDH;
	
	-- currently the same as LDHU, FIX this when data memory is more important
	function f_LDHU    ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector is
	begin
		case pos is
			when "00" =>
				return (x"0000" & mem_val(31 downto 16));
			when "01" =>
				return (x"0000" & mem_val(23 downto 8));
			when "10" =>
				return (x"0000" & mem_val(15 downto 0));
			when others => -- not allowed
				return x"FFFFFFFF";
		end case;
	end function f_LDHU;
	
	function f_LDB     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector is
	begin
		case pos is
			when "00" =>
				return (x"000000" & mem_val(31 downto 24));
			when "01" =>
				return (x"000000" & mem_val(23 downto 16));
			when "10" =>
				return (x"000000" & mem_val(15 downto 8));
			when others =>
				return (x"000000" & mem_val(7 downto 0));
		end case;
	end function f_LDB;
	
	-- currently the same as LDB, FIX this more important
	function f_LDBU    ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector is
	begin
		case pos is
			when "00" =>
				return (x"000000" & mem_val(31 downto 24));
			when "01" =>
				return (x"000000" & mem_val(23 downto 16));
			when "10" =>
				return (x"000000" & mem_val(15 downto 8));
			when others =>
				return (x"000000" & mem_val(7 downto 0));
		end case;
	end function f_LDBU;
	
	function f_STW     ( reg_val : std_logic_vector(31 downto 0))
	                     return std_logic_vector is
	begin
		return reg_val;
	end function f_STW;
	
	function f_STH     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     reg_val : std_logic_vector(31 downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector is
	begin
		case pos is
			when "00" =>
				return (reg_val(15 downto 0) & mem_val(15 downto 0));
			when "01" =>
				return (mem_val(31 downto 24) & reg_val(15 downto 0) & mem_val(7 downto 0));
			when "10" =>
				return (mem_val(31 downto 16) & reg_val(15 downto 0));
			when others => -- not allowed
				return x"FFFFFFFF";
		end case;
	end function f_STH;
	
	function f_STB     ( mem_val : std_logic_vector((DMEM_WIDTH - 1) downto 0);
	                     reg_val : std_logic_vector(31 downto 0);
	                     pos : std_logic_vector(1 downto 0))
	                     return std_logic_vector is
	begin
		case pos is
			when "00" =>
				return (reg_val(7 downto 0) & mem_val(23 downto 0));
			when "01" =>
				return (mem_val(31 downto 24) & reg_val(7 downto 0) & mem_val(15 downto 0));
			when "10" =>
				return (mem_val(31 downto 16) & reg_val(7 downto 0) & mem_val(7 downto 0));
			when others =>
				return (mem_val(31 downto 8) & reg_val(7 downto 0));
		end case;
	end function f_STB;
end package body mem_operations;

