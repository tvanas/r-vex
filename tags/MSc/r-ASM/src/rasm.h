/* r-ASM | The r-VEX assembler/instruction memory generator
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
 * rasm.h
 */

#ifndef __RASM_H__
#define __RASM_H__

#include "syllable.h"

#define MAX_LABELS 128  /* maximum numbers of labels */

typedef struct label_t {
	char name[64];
	unsigned address;
} label_t;

label_t labels[MAX_LABELS];
int num_labels;

char syllable_buffer[NUM_SLOTS][100];
char syllable_final[NUM_SLOTS][100];
int syllable_func[NUM_SLOTS];
int syllable_fill[NUM_SLOTS];
int syllable_count;

FILE *in_asm, *out_vhd;

#endif /* __RASM_H__ */
