/* r-ASM | The r-VEX assembler/instruction memory generator
 *
 * Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
 *
 * Computer Engineering Laboratory
 * Faculty of Electrical Engineering, Mathematics and Computer Science
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
 * syllable.c
 */

#define INCLUDE_TABLE
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

static int operation_compare(const void *a, const void *b)
{
	 const char *key = a;
	 const struct operation_t *operation = b;

	 return strcmp(key, operation->operation);
}

int operation_to_opcode(const char *operation)
{
	 struct operation_t *op;

	 op = (struct operation_t *)bsearch(operation, operation_table,
	                                    sizeof(operation_table) / sizeof(struct operation_t), sizeof(struct operation_t),
	                                    operation_compare);

	 if (!op) {
		  return -1;
	 }

	 return op->opcode;
}

