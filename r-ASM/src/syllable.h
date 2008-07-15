/* r-ASM | syllable and opcode definitions
 *
 * See syllable_layout.txt for more information about the r-VEX syllable
 * layout scheme.
 *
 * Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
 *
 * Computer Engineering Laboratory
 * Delft University of Technology
 * Delft, The Netherlands
 * 
 * http://r-vex.googlecode.com
 * 
 * r-ASM is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * syllable.h
 */

/* number of GR registers */
#define NUM_GR 64

/* 
 * syllable types 
 */
#define RTYPE      1
#define ISTYPE     2
#define ILTYPE     3
#define BRANCH     4
#define RTYPE_BS   5
#define MEMTYPE    6

/*
 * functional type
 */
#define ALU        1
#define MUL        2
#define CTRL       3
#define MEM        4

/* 
 * immediate switch types 
 */
#define NO_IMM     0
#define BRANCH_IMM 1
#define SHORT_IMM  2
#define LONG_IMM   3

/* 
 * opcodes 
 */

/* special operations */
#define NOP  0x00000000
#define STOP    53 

/* ALU opcodes */
#define ADD     65
#define AND     67
#define ANDC    68
#define MAX     69
#define MAXU    70
#define MIN     71
#define MINU    72
#define OR      73
#define ORC     74
#define SH1ADD  75
#define SH2ADD  76
#define SH3ADD  77
#define SH4ADD  78
#define SHL     79
#define SHR     80
#define SHRU    81
#define SUB     82
#define SXTB    83
#define SXTH    84
#define ZXTB    85
#define ZXTH    86
#define XOR     87
#define MOV     88

#define CMPEQ   89
#define CMPGE   90
#define CMPGEU  91
#define CMPGT   92
#define CMPGTU  93
#define CMPLE   94
#define CMPLEU  95
#define CMPLT   96
#define CMPLTU  97
#define CMPNE   98
#define NANDL   99
#define NORL   100
#define ORL    102
#define MTB    103
#define ANDL   104

#define ADDCG  120
#define DIVS   112
#define SLCT    56
#define SLCTF   48

/* MUL opcodes */
#define MPYLL    1
#define MPYLLU   2
#define MPYLH    3
#define MPYLHU   4
#define MPYHH    5
#define MPYHHU   6
#define MPYL     7
#define MPYLU    8
#define MPYH     9
#define MPYHU   10
#define MPYHS   11

/* Control opcodes */
#define GOTO    33
#define IGOTO   34
#define CALL    35
#define ICALL   36
#define BR      37
#define BRF     38
#define RETURN  39
#define RFI     40
#define XNOP    41

#define SEND    42
#define RECV    43

/* Memory opcodes */
#define LDW     17
#define LDH     18
#define LDHU    19
#define LDB     20
#define LDBU    21
#define STW     22
#define STH     23
#define STB     24
#define PFT     25

#define SYL_FOLLOW 28

int determine_func(int opcode);

