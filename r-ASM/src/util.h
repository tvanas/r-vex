/* r-ASM | The r-VEX assembler/instruction memory generator
 *
 * Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
 *
 * util.h
 */

char* itob(unsigned num, int bits);
void delete_spaces(char *string);
int fetchline(FILE *in, char *line);

