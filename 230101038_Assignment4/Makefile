# Makefile for Assignment 4 - nanoC Parser
# Roll: 230101038

CC      = gcc
FLEX    = flex
YACC    = yacc

ROLL    = 230101038
LEX_SRC = a4_$(ROLL).l
PAR_SRC = a4_$(ROLL).y
TEST    = a4_$(ROLL)_test.nc

all: parser

parser: lex.yy.c y.tab.c y.tab.h
	$(CC) lex.yy.c y.tab.c -o a.out -lfl 2>/dev/null || $(CC) lex.yy.c y.tab.c -o a.out

y.tab.c y.tab.h: $(PAR_SRC)
	$(YACC) -d $(PAR_SRC)

lex.yy.c: $(LEX_SRC) y.tab.h
	$(FLEX) $(LEX_SRC)

run: parser
	./a.out < $(TEST)

clean:
	rm -f lex.yy.c y.tab.c y.tab.h a.out

.PHONY: all parser run clean
