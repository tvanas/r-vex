/* r-ASM | The r-VEX assembler/instruction memory generator
 *
 * Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
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

