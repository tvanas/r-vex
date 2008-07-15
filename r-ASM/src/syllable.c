/* r-ASM | The r-VEX assembler/instruction memory generator
 *
 * Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
 *
 * syllable.c
 */

#include "syllable.h"

int determine_func(int opcode) {
	if (((opcode >= ADD) && (opcode <= ADDCG)) || (opcode == SLCT) || (opcode == SLCTF) || (opcode == NOP)) {
		return ALU;
	}
	else if ((opcode >= MPYLL) && (opcode <= MPYHS)) {
		return MUL;
	}
	else if ((opcode >= GOTO) && (opcode <= RECV)) {
		return CTRL;
	}
	else if ((opcode >= LDW) && (opcode <= PFT)) {
		return MEM;
	}
}

