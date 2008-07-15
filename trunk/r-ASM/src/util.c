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

