--------------------------------------------------------------------------------
-- r-VEX | Package with ALU functions
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
-- All operations that can be performed by the ALU
--------------------------------------------------------------------------------
-- alu_operations.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;

package alu_operations is
	-- Integer arithmetic operations
	function f_ADD    ( s1, s2 : std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	procedure f_ADDCG ( s1, s2 : in std_logic_vector(31 downto 0);
	                    ci : in std_logic;
	                    signal t  : out std_logic_vector(31 downto 0);
	                    signal co : out std_logic);

	function f_AND    ( s1, s2 : std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_ANDC   ( s1, s2 : std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	procedure f_DIVS  ( s1, s2 : in std_logic_vector(31 downto 0);
	                    ci : in std_logic;
	                    signal t  : out std_logic_vector(31 downto 0);
	                    signal co : out std_logic);
	
	function f_MAX    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_MAXU   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_MIN    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_MINU   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_OR     ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_ORC    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SH1ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SH2ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_SH3ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_SH4ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SHL    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SHR    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_SHRU   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SUB    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SXTB   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_SXTH   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_ZXTB   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_ZXTH   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_XOR    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

						
	-- Logical and select operations
	function f_CMPEQ  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPGE  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPGEU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPGT  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPGTU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPLE  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPLEU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPLT  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPLTU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_CMPNE  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;

	function f_NANDL  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_NORL   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_ORL    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
	
	function f_SLCT   ( s1, s2 : in std_logic_vector(31 downto 0);
	                    b : in std_logic)
	                    return std_logic_vector;
	
	function f_SLCTF  ( s1, s2 : in std_logic_vector(31 downto 0);
	                    b : in std_logic)
	                    return std_logic_vector;

	function f_ANDL   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector;
end package alu_operations;


package body alu_operations is
	-- Integer arithmetic operations
	function f_ADD    ( s1, s2 : std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (s1 + s2);
	end function f_ADD;
	
	procedure f_ADDCG ( s1, s2 : in std_logic_vector(31 downto 0);
			    ci : in std_logic;
			    signal t  : out std_logic_vector(31 downto 0);
			    signal co : out std_logic) is
		variable s1_tmp : std_logic_vector(32 downto 0) := (others => '0'); 
		variable s2_tmp : std_logic_vector(32 downto 0) := (others => '0'); 
		variable ci_tmp : std_logic_vector(32 downto 0) := (others => '0'); 
		variable t_tmp : std_logic_vector(32 downto 0);	
	begin
		s1_tmp(31 downto 0) := s1;
		s2_tmp(31 downto 0) := s2;
		ci_tmp(0) := ci;
		t_tmp := s1_tmp + s2_tmp + ci_tmp;
		co <= t_tmp(32);
		t <= t_tmp(31 downto 0);
	end procedure f_ADDCG;

	function f_AND    ( s1, s2 : std_logic_vector(31 downto 0))
	                    return std_logic_vector is
		variable t : std_logic_vector(31 downto 0);
	begin
		t := s1 and s2;
		return t;
	end function f_AND;

	function f_ANDC   ( s1, s2 : std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return ((not s1) and s2);
	end function f_ANDC;
	
	procedure f_DIVS  ( s1, s2 : in std_logic_vector(31 downto 0);
	                    ci : in std_logic;
	                    signal t  : out std_logic_vector(31 downto 0);
	                    signal co : out std_logic) is
		variable s1_tmp : std_logic_vector(31 downto 0) := (others => '0'); 
		variable s2_tmp : std_logic_vector(31 downto 0) := (others => '0'); 
		variable t_tmp : std_logic_vector(31 downto 0) := (others => '0'); 
		variable ci_tmp : std_logic_vector(31 downto 0) := (others => '0'); 
		variable tmp    : std_logic_vector(31 downto 0);
	begin
		s1_tmp := s1;
		s2_tmp := s2;
		ci_tmp(0) := ci;
		
		tmp := SHL(s1_tmp(30 downto 0), "1") + ci_tmp;
		
		if (s1_tmp(31) = '1') then
			t_tmp := tmp + s2_tmp;
		else
			t_tmp := tmp - s2_tmp;
		end if;
		
		co <= s1_tmp(31);		
		t <= t_tmp;
	end procedure f_DIVS;

	function f_MAX    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 >= s2) then
			return s1;
		else
			return s2;
		end if;
	end function f_MAX;
	
	function f_MAXU   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (unsigned(s1) >= unsigned(s2)) then
			return s1;
		else
			return s2;
		end if;
	end function f_MAXU;

	function f_MIN    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 <= s2) then
			return s1;
		else
			return s2;
		end if;
	end function f_MIN;

	function f_MINU   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (unsigned(s1) <= unsigned(s2)) then
			return s1;
		else
			return s2;
		end if;
	end function f_MINU;

	function f_OR     ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (s1 or s2);
	end function f_OR;
	
	function f_ORC    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return ((not s1) or s2);
	end function f_ORC;

	function f_SH1ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (SHL (s1, "1") + s2);
	end function f_SH1ADD;
	
	function f_SH2ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (SHL (s1, "10") + s2);
	end function f_SH2ADD;
	
	function f_SH3ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (SHL (s1, "11") + s2);
	end function f_SH3ADD;
	
	function f_SH4ADD ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (SHL (s1, "100") + s2);
	end function f_SH4ADD;

	function f_SHL    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return SHL (s1, s2);
	end function f_SHL;
	
	function f_SHR    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return SHR (s1, s2);
	end function f_SHR;

	function f_SHRU   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return ieee.std_logic_unsigned.SHR (s1, s2);
	end function f_SHRU;
	
	function f_SUB    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (s1 - s2);
	end function f_SUB;

	function f_SXTB   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return std_logic_vector(SHR (SHL (s1, "11000"), "11000"));
	end function f_SXTB;

	function f_SXTH   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return std_logic_vector(SHR (SHL (s1, "10000"), "10000"));
	end function f_SXTH;
	
	function f_ZXTB   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (s1 and x"000000FF");
	end function f_ZXTB;

	function f_ZXTH   ( s1 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (s1 and x"0000FFFF");
	end function f_ZXTH;
	
	function f_XOR    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		return (s1 xor s2);
	end function f_XOR;

	
	-- Logical and select operations
	function f_CMPEQ  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 = s2) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPEQ;

	function f_CMPGE  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 >= s2) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPGE;
	
	function f_CMPGEU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (unsigned(s1) >= unsigned(s2)) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPGEU;

	function f_CMPGT  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 > s2) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPGT;
	
	function f_CMPGTU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (unsigned(s1) > unsigned(s2)) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPGTU;
	
	function f_CMPLE  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 <= s2) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPLE;
	
	function f_CMPLEU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (unsigned(s1) <= unsigned(s2)) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPLEU;

	function f_CMPLT  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 < s2) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPLT;

	function f_CMPLTU ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (unsigned(s1) < unsigned(s2)) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_CMPLTU;

	function f_CMPNE  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if (s1 = s2) then
			return x"00000000";
		else
			return x"00000001";
		end if;
	end function f_CMPNE;

	function f_NANDL  ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if ((s1 = x"0") or (s2 = x"0")) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_NANDL;
	
	function f_NORL   ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if ((s1 = x"0") and (s2 = x"0")) then
			return x"00000001";
		else
			return x"00000000";
		end if;
	end function f_NORL;
	
	function f_ORL    ( s1, s2 : in std_logic_vector(31 downto 0))
	                    return std_logic_vector is
	begin
		if ((s1 = x"0") and (s2 = x"0")) then
			return x"00000000";
		else
			return x"00000001";
		end if;
	end function f_ORL;	
	
	function f_SLCT   ( s1, s2 : in std_logic_vector(31 downto 0);
	                    b : in std_logic)
			    return std_logic_vector is
	begin
		if (b = '1') then
			return std_logic_vector(unsigned(s1));
		else
			return std_logic_vector(unsigned(s2));
		end if;
	end function f_SLCT;
		
	function f_SLCTF  ( s1, s2 : in std_logic_vector(31 downto 0);
	                    b : in std_logic)
	                    return std_logic_vector is
	begin
		if (b = '0') then
			return std_logic_vector(unsigned(s1));
		else
			return std_logic_vector(unsigned(s2));
		end if;
	end function f_SLCTF;
	
	function f_ANDL  ( s1, s2 : in std_logic_vector(31 downto 0))
	                   return std_logic_vector is
	begin
		if ((s1 = x"0") or (s2 = x"0")) then
			return x"00000000";
		else
			return x"00000001";
		end if;
	end function f_ANDL;
end package body alu_operations;

