--------------------------------------------------------------------------------
-- r-VEX | Package with control functions and procedures
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
-- All operations that can be performed by the control unit
--------------------------------------------------------------------------------
-- ctrl_operations.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

library work;
use work.rVEX_pkg.all;

package ctrl_operations is
	function f_GOTO    ( offset : std_logic_vector((BROFF_WIDTH - 1) downto 0))
	                     return std_logic_vector;
	
	function f_IGOTO   ( lr : std_logic_vector(31 downto 0))
	                     return std_logic_vector;
	
	procedure f_CALL   ( offset : in std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     pc : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal pc_goto : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal result : out std_logic_vector(31 downto 0));
	
	procedure f_ICALL  ( lr : in std_logic_vector(31 downto 0);
	                     pc : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal pc_goto : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal result : out std_logic_vector(31 downto 0));
	
	function f_BR      ( offset : std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     pc : std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     br : std_logic)
	                     return std_logic_vector;
	
	function f_BRF     ( offset : std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     pc : std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     br : std_logic)
	                     return std_logic_vector;
	
	procedure f_RETURN ( offset : in std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     lr : in std_logic_vector(31 downto 0);
	                     sp : in std_logic_vector(31 downto 0);
	                     signal pc_goto : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal result : out std_logic_vector(31 downto 0));
end package ctrl_operations;


package body ctrl_operations is
	function f_GOTO    ( offset : std_logic_vector((BROFF_WIDTH - 1) downto 0))
	                     return std_logic_vector is
	begin
		return offset((ADDR_WIDTH - 1) downto 0);
	end function f_GOTO;
	
	function f_IGOTO   ( lr : std_logic_vector(31 downto 0))
	                     return std_logic_vector is
	begin
		return lr((ADDR_WIDTH - 1) downto 0);
	end function f_IGOTO;
	
	procedure f_CALL   ( offset : in std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     pc : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal pc_goto : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable pc_tmp : std_logic_vector(31 downto 0) := (others => '0');
	begin
		pc_tmp((ADDR_WIDTH - 1) downto 0) := pc;

		pc_goto <= offset((ADDR_WIDTH - 1) downto 0);
		result <= pc_tmp + 1;
	end procedure f_CALL;


	procedure f_ICALL  ( lr : in std_logic_vector(31 downto 0);
	                     pc : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal pc_goto : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal result : out std_logic_vector(31 downto 0)) is
		variable pc_tmp : std_logic_vector(31 downto 0) := (others => '0');
	begin
		pc_tmp((ADDR_WIDTH - 1) downto 0) := pc;
		
		pc_goto <= lr((ADDR_WIDTH - 1) downto 0);
		result <= pc_tmp + 1;
	end procedure f_ICALL;
	
	function f_BR      ( offset : std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     pc : std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     br : std_logic)
	                     return std_logic_vector is
	begin
		if (br = '1') then
			return offset((ADDR_WIDTH - 1) downto 0);
		else
			return (pc + 1);
		end if;
	end function f_BR;

	function f_BRF     ( offset : std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     pc : std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     br : std_logic)
	                     return std_logic_vector is
	begin
		if (br = '0') then
			return offset((ADDR_WIDTH - 1) downto 0);
		else
			return (pc + 1);
		end if;
	end function f_BRF;
	
	procedure f_RETURN ( offset : in std_logic_vector((BROFF_WIDTH - 1) downto 0);
	                     lr : in std_logic_vector(31 downto 0);
	                     sp : in std_logic_vector(31 downto 0);
	                     signal pc_goto : out std_logic_vector((ADDR_WIDTH - 1) downto 0);
	                     signal result : out std_logic_vector(31 downto 0)) is
	begin
		pc_goto <= lr((ADDR_WIDTH - 1) downto 0);
		result <= sp + offset;
	end procedure f_RETURN;
end package body ctrl_operations;

