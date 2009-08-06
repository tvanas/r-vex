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
 * rasm.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "syllable.h"
#include "vhdl.h"
#include "rasm.h"
#include "util.h"

/* resolves unresolved labels in second pass */
void resolve_labels(char *outfile)
{
	char *line = malloc(200);
	int label_id = 0;
	int i = 0;

	in_asm = fopen(outfile, "r+");

	while (fscanf(in_asm, "%s", line) != EOF) {
		if (strncmp(&line[16], "??", 2) == 0) {
			sscanf(&line[16], "??%d", &label_id);
		
			fseek(in_asm, -19, SEEK_CUR);
			fprintf(in_asm, "%s", itob(labels[label_id].address, 12));

			for (i = 0; i < 200; i++) {
				line[i] = '-';
			}
		}
	}

	free(line);

	fclose(in_asm);
}

/* prints label debug info when -l option is present */
void print_labels()
{
	int i;

	printf("\n%-24s| %-8s\n", "Label name", "Address");
	printf("------------------------+---------\n");
	
	for (i = 0; i < num_labels; i++) {
		 printf("%-24s| %-8.2X\n", labels[i].name, labels[i].address);
	}

	printf("\n");
}

/* prints instruction to VHDL file */
void print_instruction(int address)
{
	int i = 0;
	int j = 0;
	int k = 0;
	
	/* sort MEM, CTRL and MUL operations in the corresponding slots */
	for (i = 0; i < NUM_SLOTS; i++) {
		if (syllable_func[i] == MEM) {
			strcpy(syllable_final[MEM_SLOT], syllable_buffer[i]);
			syllable_fill[MEM_SLOT] = 1;
		}
		else if (syllable_func[i] == CTRL) {
			strcpy(syllable_final[CTRL_SLOT], syllable_buffer[i]);
			syllable_fill[CTRL_SLOT] = 1;
		}
		else if (syllable_func[i] == MUL) {
			if (syllable_fill[MUL0_SLOT] == 0) {
				strcpy(syllable_final[MUL0_SLOT], syllable_buffer[i]);
				syllable_fill[MUL0_SLOT] = 1;
			}
			else {
				strcpy(syllable_final[MUL1_SLOT], syllable_buffer[i]);
				syllable_fill[MUL1_SLOT] = 1;
			}
		}
	}

	/* sort ALU operations in the corresponding slots */
	for (i = 0; i < NUM_SLOTS; i++) {
		if (syllable_fill[i] == 0) {
			for (j = k; j < NUM_SLOTS; j++) {
				if (syllable_func[j] == ALU) {
					strcpy(syllable_final[i], syllable_buffer[j]);
					syllable_fill[i] = 1;
					k = j + 1;
					break;
				}
			}
		}
	}
	
	for (i = 0; i < NUM_SLOTS; i++) {
		if (i == 0) {
			syllable_final[i][31] = '1'; /* last syllable bit */
			fprintf(out_vhd, "\t\t\t\twhen x\"%.2X\"  => instr <= ", address);
		}
		else {
			if (i == (NUM_SLOTS - 1)) {
				syllable_final[i][32] = '1'; /* first syllable bit */
				syllable_final[i][34] = ';'; /* VHDL ; end of line character */
			}

			fprintf(out_vhd, "\t\t\t\t                        ");
		}
		
		fprintf(out_vhd, syllable_final[i]);
	}
}

/* returns number of unresolved labels */
int assemble()
{
	char operation[64];
	char operands[256];
	char label[128];
	char syl_word[33];
	char tmp[12];
	
	unsigned address = 0;
	unsigned bd, bs, rd, rs1, rs2, imm, br_imm = 0;
	unsigned syllable = NOP;
	unsigned syl_type = 0;
	unsigned comment_detected = 0;
	unsigned label_detected = 0;
	unsigned stop_detected = 0;
	
	int opcode = NOP;
	int new_instr = 0;
	int labels_unresolved = 0;
	int current_unresolved = 0;

	int i;

	num_labels = 0;
	syllable_count = 0;

	for (i = 0; i < NUM_SLOTS; i++) {
		strcpy(syllable_buffer[i], "\"00000000000000000000000000000000\"& -- nop\n");
		syllable_func[i] = ALU;
		syllable_fill[i] = 0;
	}
	
	/* fetch first word of line (this is the operation) */
	while (fscanf(in_asm, "%s", operation) != EOF) {
		/* get cluster number (char 48 is '0' and char 57 is '9') */
		if ((operation[0] == 'c') && (operation[1] >= 48) && (operation[1] <= 57)) {
			/* 
			 * r-VEX and r-ASM don't support multi-cluster configurations (yet)
			 *
			 * No syllable space is reserved for cluster numbers, maybe we want to
			 * save instructions for different clusters in different memory sements?
			 *
			 * For now, just skip do not use this information (it will always be c0)
			 */
			
			continue;
		}
		
		/* fetch the rest of the line (operands), strip comments and spaces */	
		fetchline(in_asm, operands);

		bd = bs = rd = rs1 = rs2 = imm = br_imm = 0;
		syl_type = RTYPE;
		syllable = NOP;
		current_unresolved = 0;
		stop_detected = 0;

		/* 
		 * handle syllables 
		 */
		opcode = operation_to_opcode(operation);
	
		if (opcode != -1) {
			 if (opcode == STOP) {
				  stop_detected = 1;
			 }
		}
		else if (strcmp(operation, ";;") == 0) {
			new_instr = 1;
			syllable_count = 4;
			opcode = NOP;
		}
		else if (operation[0] == '#') {
			/* comment */
			comment_detected = 1;
		}
		else { 
			/* label */
			for (i = 0; i < num_labels; i++) {
				if (strcmp(labels[i].name, operation) == 0) {
					labels[i].address = address;
					label_detected = 1;
				}
			}
		
			if (label_detected == 0) {
				strcpy(labels[num_labels].name, operation);
				labels[num_labels].address = address;
				num_labels++;
				label_detected = 1;
			}
		}

		if (syllable_count != 4) {
			syllable_func[syllable_count] = determine_func(opcode);
		}

		/*
		 * determine syllable type
		 */
		if ((new_instr != 1) && (comment_detected != 1) && (label_detected != 1) && (stop_detected != 1)) {
			if (sscanf(operands, "$r0.%d=$r0.%d,$r0.%d", &rd, &rs1, &rs2) == 3) {
				/* regular ALU and MUL operations */
				sprintf(operands, "$r0.%d = $r0.%d, $r0.%d", rd, rs1, rs2);
				
				if (opcode == SUB) {
					/* SUB */
					i = rs2;
					rs2 = rs1;
					rs1 = i;
				}
			
				bd = 0;
				bs = 0;
				
				syl_type = RTYPE;
			}
			else if (sscanf(operands, "$r0.%d=$r0.%d,%d", &rd, &rs1, &imm) == 3) {
				/* regular ALU and MUL operations operating on immediate operands */
				bd = 0;
				bs = 0;
				
				if (imm < 1024) {
					syl_type = ISTYPE;
				}
				else {
					syl_type = ILTYPE;
				}

				sprintf(operands, "$r0.%d = $r0.%d, %d", rd, rs1, imm);
			}
			else if (sscanf(operands, "$r0.%d=%d,$r0.%d", &rd, &imm, &rs1) == 3) {
				/* SUB (operands reversed) operating on immediate operands */
				bd = 0;
				bs = 0;
				rs2 = 0;
				
				if (imm < 1024) {
					syl_type = ISTYPE;
				}
				else {
					syl_type = ILTYPE;
				}

				sprintf(operands, "$r0.%d = %d, $r0.%d", rd, imm, rs1);
			}
			else if (sscanf(operands, "$r0.%d=$b0.%d,$r0.%d,$r0.%d", &rd, &bs, &rs1, &rs2) == 4) {
				/* SLCT & SLCTF operations */
				bd = 0;
				syl_type = RTYPE_BS;
				sprintf(operands, "$r0.%d = $b0.%d, $r0.%d, $r0.%d", rd, bs, rs1, rs2);
			}
			else if (sscanf(operands, "$r0.%d,$b0.%d=$b0.%d,$r0.%d,$r0.%d", &rd, &bd, &bs, &rs1, &rs2) == 5) {
				/* ADDCG & DIVS operations */
				syl_type = RTYPE_BS;
				sprintf(operands, "$r0.%d, $b0.%d = $b0.%d, $r0.%d, $r0.%d", rd, bd, bs, rs1, rs2);
			}
			else if (sscanf(operands, "$r0.%d=$r0.%d", &rd, &rs1) == 2) {
				/* MOV, SXTB, SXTH, ZXTB, ZXTH */
				rs2 = 0;
				bd = 0;
				bs = 0;
				syl_type = RTYPE;
				sprintf(operands, "$r0.%d = $r0.%d", rd, rs1);
			}
			else if (sscanf(operands, "$r0.%d=%d", &rd, &imm) == 2) {
				/* MOV, SXTB, SXTH, ZXTB, ZXTH operating on immediate operand */
				rs2 = 0;
				rs1 = 0;
				bd = 0;
				bs = 0;

				if (imm < 1024) {
					syl_type = ISTYPE;
				}
				else {
					syl_type = ILTYPE;
				}
			
				sprintf(operands, "$r0.%d = %d", rd, imm);
			}
			else if (sscanf(operands, "$b0.%d=$r0.%d,$r0.%d", &bd, &rs1, &rs2) == 3) {
				/* ALU op with BR as dest */
				rd = 0;
				bs = 0;
				syl_type = RTYPE;
				sprintf(operands, "$b0.%d = $r0.%d, $r0.%d", bd, rs1, rs2);
			}
			else if (sscanf(operands, "$b0.%d=$r0.%d,%d", &bd, &rs1, &imm) == 3) {
				/* ALU op with BR as dest operating on immediate operand */
				rd = 0;
				rs2 = 0;
				bs = 0;

				if (imm < 1024) {
					syl_type = ISTYPE;
				}
				else {
					syl_type = ILTYPE;
				}

				sprintf(operands, "$b0.%d = $r0.%d, %d", bd, rs1, imm);
			}
			else if (sscanf(operands, "$b0.%d,%s", &bd, label) == 2) {
				/* BR and BRF */
				sprintf(operands, "$b0.%d, %s", bd, label);
				sprintf(label, "%s:", label);
				labels_unresolved++;
				current_unresolved = 1;

				for (i = 0; i < num_labels; i++) {
					if (strcmp(labels[i].name, label) == 0) {
						br_imm = labels[i].address;
						labels_unresolved--;
						current_unresolved = 0;
					}
				}
				
				if (current_unresolved == 1) {
					strcpy(labels[num_labels].name, label);
					num_labels++;
				}

				rd = 0;
				bs = 0;
				rs1 = 0;
				rs2 = 0;
				syl_type = BRANCH;
			}
			else if (sscanf(operands, "$r0.%d=0x%x[$r0.%d]", &rd, &imm, &rs1) == 3) {
				/* Load */
				rs2 = 0;
				bd = 0;
				bs = 0;
				syl_type = MEMTYPE;
				sprintf(operands, "$r0.%d=0x%x[$r0.%d]", rd, imm, rs1);
			}
			else if (sscanf(operands, "0x%x[$r0.%d]=$r0.%d", &imm, &rs1, &rd) == 3) {
				/* Store */
				rs2 = 0;
				bd = 0;
				bs = 0;
				syl_type = MEMTYPE;
				sprintf(operands, "0x%d[$r0.%d] = $r0.%d", imm, rs1, rd);
			}
			else if (opcode == NOP) {
				/* NOP */
				rd = 0;
				bd = 0;
				bs = 0;
				rs1 = 0;
				rs2 = 0;
				syl_type = RTYPE;
			}
			else if (sscanf(operands, "$r0.1=$r0.1,%d,$l0.0", &br_imm) == 1) {
				/* RETURN and RFI */
				sprintf(operands, "$r0.1 = $r0.1, %d, $l0.0", br_imm); /* TODO: support hexadecimal offset */
				rd = NUM_GR - 1;
				bd = 0;
				bs = 0;
				rs1 = 0;
				rs2 = 0;
				syl_type = BRANCH;
			}
			else if (sscanf(operands, "$l0.%d", &rd) == 1) {
				/* IGOTO / GOTO overload */
				rd = NUM_GR - 1;
				bd = 0;
				bs = 0;
				rs1 = 0;
				rs2 = 0;
				syl_type = RTYPE;
			}
			else if (sscanf(operands, "$l0.%d=%d", &rd, &rs1) == 2) {
				/* ICALL / CALL overload */
				sprintf(operands, "$l%d = %d", rd, rs1);
				rd = NUM_GR - 1;
				bd = 0;
				bs = 0;
				rs2 = 0;
				syl_type = RTYPE;
			}
			else if (sscanf(operands, "$l0.%d=%s", &rd, label) == 2) {
				/* CALL */
				sprintf(operands, "$l0.%d = %s", rd, label);
				sprintf(label, "%s:", label);
				labels_unresolved++;
				current_unresolved = 1;

				for (i = 0; i < num_labels; i++) {
					if (strcmp(labels[i].name, label) == 0) {
						br_imm = labels[i].address;
						labels_unresolved--;
						current_unresolved = 0;
					}
				}

				if (current_unresolved == 1) {
					strcpy(labels[num_labels].name, label);
					num_labels++;
				}
	
				rd = NUM_GR - 1;
				bs = 0;
				rs1 = 0;
				rs2 = 0;
				syl_type = BRANCH;
			}
			/* this should be the last check! %s matches a lot... */
			else if (sscanf(operands, "%s", label) == 1) {
				/* GOTO */
				sprintf(label, "%s:", label);
				labels_unresolved++;
				current_unresolved = 1;

				for (i = 0; i < num_labels; i++) {
					if (strcmp(labels[i].name, label) == 0) {
						br_imm = labels[i].address;
						labels_unresolved--;
						current_unresolved = 0;
					}
				}

				if (current_unresolved == 1) {
					strcpy(labels[num_labels].name, label);
					num_labels++;
				}

				rd = 0;
				bs = 0;
				rs1 = 0;
				rs2 = 0;
				syl_type = BRANCH;
			}
			else {
				fprintf(stderr, "\nrasm: unexpected input at\n\toperation: %s\n\toperands:  %s\n\nERROR: assembling failed\n\n", operation, operands);
				exit(EXIT_FAILURE);
			}
		}
		
		/* 
		 * generate syllables
		 */
		
		syllable = (opcode << 25);
		
		switch(syl_type) {
			case RTYPE:
				syllable |= NO_IMM << 23;
				syllable |= rd << 17;
				syllable |= rs1 << 11;
				syllable |= rs2 << 5;
				syllable |= bd << 2;
				break;
			case ISTYPE:
				syllable |= SHORT_IMM << 23;
				syllable |= rd << 17;
				syllable |= rs1 << 11;
				syllable |= imm << 2;
				break;
			case ILTYPE:
				syllable |= LONG_IMM << 23;
				syllable |= rd << 17;
				syllable |= rs1 << 11;
				syllable |= (imm >> 22) << 1; /* 10 MSB of immediate value; TODO: add new syllable for LSB */
				break;
			case BRANCH:
				syllable |= BRANCH_IMM << 23;
				syllable |= rd << 17;
				syllable |= rs1 << 11;
				syllable |= br_imm << 5;
				syllable |= bd << 2;
				break;
			case RTYPE_BS:
				syllable |= bs << 25;
				syllable |= NO_IMM << 23;
				syllable |= rd << 17;
				syllable |= rs1 << 11;
				syllable |= rs2 << 5;
				syllable |= bd << 2;
				break;
			case MEMTYPE:
				syllable |= NO_IMM << 23;
				syllable |= rd << 17;
				syllable |= rs1 << 11;
				syllable |= imm << 2;
				break;
			default:
				fprintf(stderr, "\nrasm: unknown syllable type discovered: %d\n\nERROR: assembling failed\n\n", syl_type);
				exit(EXIT_FAILURE);
				break;
		}

			
		if ((label_detected != 1) && (comment_detected != 1)) {
			if (syllable_count == 4) {
				print_instruction(address);
	
				for (i = 0; i < 4; i++) {
					strcpy(syllable_buffer[i], "\"00000000000000000000000000000000\"& -- nop\n");
					syllable_func[i] = ALU;
					syllable_fill[i] = 0;
				}

				syllable_count = 0;
				new_instr = 0;
				address++;
			}
			else {
				strcpy(syl_word, itob(syllable, 32));
				
				if (current_unresolved == 1) {
					sprintf(tmp, "??%d", (num_labels - 1));

					for (i = 0; i < 12; i++) {
						if ((tmp[i] < '0') || (tmp[i] > '9')) {
							tmp[i] = '?';
						}
					}

					memcpy(&syl_word[15], tmp, 12);
				}

				sprintf(syllable_buffer[syllable_count], "\"%s\"& -- %s %s\n", syl_word, operation, operands);
				
				syllable_count++;
			}
		}
		else if (label_detected == 1) {
			fprintf(out_vhd, "\t\t\t\t                                                            -- %s\n", labels[num_labels - 1].name);
		}

		label_detected = 0;
		comment_detected = 0;
	}

	return labels_unresolved;
}

/* prints help */
void print_usage()
{
	printf("r-ASM -- The r-VEX assembler/instruction ROM generator\n\n");
	printf("Usage: rasm [options] file\n");
	printf("Options:\n");
	printf("  %-12s%-30s\n", "-o <file>", "Place the output into <file> (default is i_mem.vhd)");
	printf("  %-12s%-30s\n", "-l", "Enable resolved label output");
	printf("  %-12s%-30s\n", "-h", "Display this information");
}

int main(int argc, char **argv)
{
	int do_resolve = 0;
	int opt;
	int label_output = 0;
	char outfile[32];
	char flags[72];
	int i;
	
	strcpy(flags, argv[0]);
	strcpy(outfile, "i_mem.vhd");
	
	if (argc == 1) {     /* no commandline arguments given */
		 print_usage();
		 exit(0);
	}

	while ((opt = getopt(argc, argv, "o:lh")) != -1) {
		switch (opt) {
			case 'o':  /* alternative output file */
				strncpy(outfile, optarg, 31);
				break;
			case 'l':  /* print label debug output */
				label_output = 1;
				break;
			case 'h':  /* print help */
				print_usage();
				break;
			default:   /* catch other arguments */
				exit(EXIT_FAILURE);
				break;
		}
	}	

	in_asm = fopen(argv[argc - 1], "r");

	if (!in_asm) {
		fprintf(stderr, "ERROR: Could not open input file\n");
		exit(EXIT_FAILURE);
	}
	
	out_vhd = fopen(outfile, "w");

	if (!out_vhd) {
		fprintf(stderr, "ERROR: Could not open output file\n");
		exit(EXIT_FAILURE);
	}
	
	for (i = 1; i < argc; i++) {
		strcat(flags, " ");
		strcat(flags, argv[i]);
	}
	
	/* print VHDL header to output file */
	vhdl_header(argv[argc - 1], flags, outfile);

	do_resolve = assemble();

	/* print VHDL footer to output file */
	vhdl_footer();

	fclose(in_asm);
	fclose(out_vhd);

	/* -l flag output */
	if (label_output == 1) {
		printf("\nUnresolved labels after first pass: %d\n", do_resolve);
	
		print_labels();
	}
	
	/* go for a second pass when there were unresolved labels */
	if (do_resolve) {
		resolve_labels(outfile);
	}

	return 0;
}

