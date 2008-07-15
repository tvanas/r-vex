/* r-ASM | The r-VEX assembler/instruction memory generator
 *
 * Copyright (c) 2008, Thijs van As <t.vanas@gmail.com>
 *
 * util.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* integer to binary conversion) */
char* itob(unsigned num, int bits)
{
    char *result;
    int i = 0;

    result = malloc(bits+1);

    for (i = 0; i < bits; i++) {
        if ((1 << (bits - 1 - i)) & num) {
            result[i] = '1';
        }
        else {
            result[i] = '0';
        }
    }

    result[i] = '\0';
    return result;
}

/* removes spaces from string */
void delete_spaces(char *string)
{
	char *t = string;

	while (*string != '\0') {
		if (*string != ' ' && *string != '\t') {
			*t++ = *string;
		}
		
		string++;
	}
	
	*t = '\0';
}

/* fetches a line from file, strips comments and spaces */
int fetchline(FILE *in, char *line)
{
	int i;
	char c;

	i = 0;
	
	while ((c = getc(in)) != EOF && c != '#' && c != '\n') {
		line[i++] = c;
	}

	line[i] = '\0';

	delete_spaces(line);

	return i;
}

