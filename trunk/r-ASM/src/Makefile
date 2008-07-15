CC = gcc
CFLAGS = -O0 -ggdb 

SRCS = util.c syllable.c vhdl.c rasm.c
OBJS = util.o syllable.o vhdl.o rasm.o

rasm:	$(OBJS)
	$(CC) -o rasm $(CFLAGS) $(OBJS)

clean:
	rm -f *.o *.vhd *~ rasm

