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

#define VERSION 0.1

typedef struct label_t {
	char name[50];
	int address;
} label_t;

label_t labels[128]; /* support for 128 labels */
int num_labels;

char syllable_buffer[4][100];
char syllable_final[4][100];
int syllable_func[4];
int syllable_fill[4];
int syllable_count;

FILE *in_asm, *out_vhd;

