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

void print_labels()
{
	int i = 0;

	printf("\n%-24s| %-8s\n", "Label name", "Address");
	printf("------------------------+---------\n");
	
	for (i = 0; i < num_labels; i++) {
		 printf("%-24s| %-8.2X\n", labels[i].name, labels[i].address);
	}

	printf("\n");
}

void print_instruction(int address)
{
	int i = 0;
	int j = 0;
	int k = 0;
	
	char eol = ';';
	char one = '1';

	/* TODO:
	 * Currently supports 4-issue VLIW with the following issue-configuration:
	 *
	 *   0 : ALU / CTRL
	 *   1 : ALU / MUL
	 *   2 : ALU / MUL
	 *   3 : ALU / MEM
	 * 
	 * This is the default r-VEX cluster configuration. This should become more dynamic.	
   	 */

	/* sort MEM, CTRL and MUL operations in the corresponding slots */
	for (i = 0; i < 4; i++) {
		if (syllable_func[i] == MEM) {
			strcpy(syllable_final[0], syllable_buffer[i]);
			syllable_fill[0] = 1;
		}
		else if (syllable_func[i] == CTRL) {
			strcpy(syllable_final[3], syllable_buffer[i]);
			syllable_fill[3] = 1;
		}
		else if (syllable_func[i] == MUL) {
			if (syllable_fill[1] == 0) {
				strcpy(syllable_final[1], syllable_buffer[i]);
				syllable_fill[1] = 1;
			}
			else {
				strcpy(syllable_final[2], syllable_buffer[i]);
				syllable_fill[2] = 1;
			}
		}
	}

	/* sort ALU operations in the corresponding slots */
	for (i = 0; i < 4; i++) {
		if (syllable_fill[i] == 0) {
			for (j = k; j < 4; j++) {
				if (syllable_func[j] == ALU) {
					strcpy(syllable_final[i], syllable_buffer[j]);
					syllable_fill[i] = 1;
					k = j + 1;
					break;
				}
			}
		}
	}
	
	for (i = 0; i < 4; i++) {
		if (i == 0) {
			memcpy(&syllable_final[i][32], &one, 1);     /* first syllable bit */
			fprintf(out_vhd, "\t\t\t\twhen x\"%.2X\"  => instr <= ", address);
		}
		else {
			if (i == 3) {
				memcpy(&syllable_final[i][31], &one, 1); /* last syllable bit */
				memcpy(&syllable_final[i][34], &eol, 1); /* VHDL ; end of line character */
			}

			fprintf(out_vhd, "\t\t\t\t                        ");
		}
		
		fprintf(out_vhd, syllable_final[i]);
	}
}

/* returns number of unresolved labels */
int assemble()
{
	char *operation = malloc(10);
	char *operands = malloc(100);
	char *label = malloc(100);
	char eol = '&';
	char syl_word[33];
	char tmp[12];
	
	unsigned address = 0;
	unsigned bd, bs, rd, rs1, rs2, imm, br_imm;
	unsigned syllable;
	unsigned syl_type;
	unsigned opcode;

	int new_instr = 0;
	int label_detected = 0;
	int labels_unresolved = 0;
	int current_unresolved = 0;
	int stop_detected = 0;

	int i;

	num_labels = 0;
	syllable_count = 0;

	for (i = 0; i < 4; i++) {
		strcpy(syllable_buffer[i], "\"00000000000000000000000000000000\"& -- nop\n");
		syllable_func[i] = ALU;
		syllable_fill[i] = 0;
	}
	
	/* fetch first word of line (this is the operation) */
	while (fscanf(in_asm, "%s", operation) != EOF) {
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

		if (strcmp(operation, ";;") == 0) {
			new_instr = 1;
			syllable_count = 4;
		}
		else if (strcmp(operation, "add") == 0) {
			opcode = ADD;
		}
		else if (strcmp(operation, "and") == 0) {
			opcode = AND;
		} 
		else if (strcmp(operation, "andc") == 0) {
			opcode = ANDC;
		} 
		else if (strcmp(operation, "max") == 0) {
			opcode = MAX;
		} 
		else if (strcmp(operation, "maxu") == 0) {
			opcode = MAXU;
		} 
		else if (strcmp(operation, "min") == 0) {
			opcode = MIN;
		} 
		else if (strcmp(operation, "minu") == 0) {
			opcode = MINU;
		} 
		else if (strcmp(operation, "or") == 0) {
			opcode = OR;
		} 
		else if (strcmp(operation, "orc") == 0) {
			opcode = ORC;
		} 
		else if (strcmp(operation, "sh1add") == 0) {
			opcode = SH1ADD;
		} 
		else if (strcmp(operation, "sh2add") == 0) {
			opcode = SH2ADD;
		} 
		else if (strcmp(operation, "sh3add") == 0) {
			opcode = SH3ADD;
		} 
		else if (strcmp(operation, "sh4add") == 0) {
			opcode = SH4ADD;
		} 
		else if (strcmp(operation, "shl") == 0) {
			opcode = SHL;
		} 
		else if (strcmp(operation, "shr") == 0) {
			opcode = SHR;
		} 
		else if (strcmp(operation, "shru") == 0) {
			opcode = SHRU;
		} 
		else if (strcmp(operation, "sub") == 0) {
			opcode = SUB;
		} 
		else if (strcmp(operation, "sxtb") == 0) {
			opcode = SXTB;
		} 
		else if (strcmp(operation, "sxth") == 0) {
			opcode = SXTH;
		} 
		else if (strcmp(operation, "zxtb") == 0) {
			opcode = ZXTB;
		} 
		else if (strcmp(operation, "zxth") == 0) {
			opcode = ZXTH;
		} 
		else if (strcmp(operation, "xor") == 0) {
			opcode = XOR;
		} 
		else if (strcmp(operation, "mov") == 0) {
			opcode = MOV;
		} 
		else if (strcmp(operation, "cmpeq") == 0) {
			opcode = CMPEQ;
		} 
		else if (strcmp(operation, "cmpge") == 0) {
			opcode = CMPGE;
		} 
		else if (strcmp(operation, "cmpgeu") == 0) {
			opcode = CMPGEU;
		} 
		else if (strcmp(operation, "cmpgt") == 0) {
			opcode = CMPGT;
		} 
		else if (strcmp(operation, "cmpgtu") == 0) {
			opcode = CMPGTU;
		} 
		else if (strcmp(operation, "cmple") == 0) {
			opcode = CMPLE;
		} 
		else if (strcmp(operation, "cmpleu") == 0) {
			opcode = CMPLEU;
		} 
		else if (strcmp(operation, "cmplt") == 0) {
			opcode = CMPLT;
		} 
		else if (strcmp(operation, "cmpltu") == 0) {
			opcode = CMPLTU;
		} 
		else if (strcmp(operation, "cmpne") == 0) {
			opcode = CMPNE;
		} 
		else if (strcmp(operation, "nandl") == 0) {
			opcode = NANDL;
		} 
		else if (strcmp(operation, "norl") == 0) {
			opcode = NORL;
		} 
		else if (strcmp(operation, "orl") == 0) {
			opcode = ORL;
		} 
		else if (strcmp(operation, "mtb") == 0) {
			opcode = MTB;
		} 
		else if (strcmp(operation, "andl") == 0) {
			opcode = ANDL;
		} 
		else if (strcmp(operation, "addcg") == 0) {
			opcode = ADDCG;
		} 
		else if (strcmp(operation, "divs") == 0) {
			opcode = DIVS;
		} 
		else if (strcmp(operation, "slct") == 0) {
			opcode = SLCT;
		} 
		else if (strcmp(operation, "slctf") == 0) {
			opcode = SLCTF;
		} 
		else if (strcmp(operation, "mpyll") == 0) {
			opcode = MPYLL;
		} 
		else if (strcmp(operation, "mpyllu") == 0) {
			opcode = MPYLLU;
		} 
		else if (strcmp(operation, "mpylh") == 0) {
			opcode = MPYLH;
		} 
		else if (strcmp(operation, "mpylhu") == 0) {
			opcode = MPYLHU;
		} 
		else if (strcmp(operation, "mpyhh") == 0) {
			opcode = MPYHH;
		}
		else if (strcmp(operation, "mpyhhu") == 0) {
			opcode = MPYHHU;
		} 
		else if (strcmp(operation, "mpyl") == 0) {
			opcode = MPYL;
		} 
		else if (strcmp(operation, "mpylu") == 0) {
			opcode = MPYLU;
		} 
		else if (strcmp(operation, "mpyh") == 0) {
			opcode = MPYH;
		} 
		else if (strcmp(operation, "mpyhu") == 0) {
			opcode = MPYHU;
		} 
		else if (strcmp(operation, "mpyhs") == 0) {
			opcode = MPYHS;
		} 
		else if (strcmp(operation, "goto") == 0) {
			opcode = GOTO;
		} 
		else if (strcmp(operation, "igoto") == 0) {
			opcode = IGOTO;
		} 
		else if (strcmp(operation, "call") == 0) {
			opcode = CALL;
		} 
		else if (strcmp(operation, "icall") == 0) {
			opcode = ICALL;
		} 
		else if (strcmp(operation, "br") == 0) {
			opcode = BR;
		} 
		else if (strcmp(operation, "brf") == 0) {
			opcode = BRF;
		} 
		else if (strcmp(operation, "return") == 0) {
			opcode = RETURN;
		} 
		else if (strcmp(operation, "rfi") == 0) {
			opcode = RFI;
		}
		else if (strcmp(operation, "xnop") == 0) {
			opcode = XNOP;
		} 
		else if (strcmp(operation, "send") == 0) {
			opcode = SEND;
		} 
		else if (strcmp(operation, "recv") == 0) {
			opcode = RECV;
		} 
		else if (strcmp(operation, "ldw") == 0) {
			opcode = LDW;
		} 
		else if (strcmp(operation, "ldh") == 0) {
			opcode = LDH;
		} 
		else if (strcmp(operation, "ldhu") == 0) {
			opcode = LDHU;
		} 
		else if (strcmp(operation, "ldb") == 0) {
			opcode = LDB;
		} 
		else if (strcmp(operation, "ldbu") == 0) {
			opcode = LDBU;
		} 
		else if (strcmp(operation, "stw") == 0) {
			opcode = STW;
		} 
		else if (strcmp(operation, "sth") == 0) {
			opcode = STH;
		} 
		else if (strcmp(operation, "stb") == 0) {
			opcode = STB;
		} 
		else if (strcmp(operation, "pft") == 0) {
			opcode = PFT;
		} 
		else if (strcmp(operation, "nop") == 0) {
			opcode = NOP;
		}
		else if (strcmp(operation, "stop") == 0) {
			opcode = STOP;
			stop_detected = 1;
		}
		else { /* label */
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

		syllable_func[syllable_count] = determine_func(opcode);

		/*
		 * determine syllable type
		 */
		if ((new_instr != 1) && (label_detected != 1) && (stop_detected != 1)) {
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

			
		if (label_detected != 1) {
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
		else {
			fprintf(out_vhd, "\t\t\t\t                                                            -- %s\n", labels[num_labels - 1].name);
		}

		label_detected = 0;
	}

	return labels_unresolved;

	free(operation);
	free(operands);
	free(label);
}

void print_usage()
{
	printf("r-ASM %.1f -- The r-VEX assembler/instruction ROM generator\n\n", VERSION);
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
	char flags[64];
	int i;
	
	strcpy(outfile, "i_mem.vhd");
	strcpy(flags, argv[0]);
	
	if (argc == 1) {
		 print_usage();
		 exit(0);
	}

	while ((opt = getopt(argc, argv, "o:lh")) != -1) {
		switch (opt) {
			case 'o':
				sscanf(optarg, "%s", outfile);
				break;
			case 'l':
				label_output = 1;
				break;
			case 'h':
				print_usage();
				break;
			default:
				exit(EXIT_FAILURE);
				break;
		}
	}	

	in_asm = fopen(argv[argc - 1], "r");

	if (!in_asm) {
		fprintf(stderr, "ERROR: Could not open input file\n");
		exit(EXIT_FAILURE);
	}
	
	out_vhd = fopen(outfile, "w+");

	if (!out_vhd) {
		fprintf(stderr, "ERROR: Could not open output file\n");
		exit(EXIT_FAILURE);
	}
	
	for (i = 1; i < argc; i++) {
		sprintf(flags, "%s %s", flags, argv[i]);
	}
	
	vhdl_header(argv[argc - 1], flags, outfile);

	do_resolve = assemble();

	vhdl_footer();

	fclose(in_asm);
	fclose(out_vhd);
	
	if (label_output == 1) {
		printf("\nUnresolved labels after first pass: %d\n", do_resolve);
	
		print_labels();
	}
	
	if (do_resolve) {
		resolve_labels(outfile);
	}

	return 0;
}

