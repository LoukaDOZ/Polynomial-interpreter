PARSER = parser
SCANNER = scanner
POLY = poly
BIN = prog
CC = gcc

all: $(PARSER).y $(SCANNER).l
	bison -d -g -v $(PARSER).y
	flex -dTv $(SCANNER).l
	$(CC) -Wall -c lex.yy.c -o lex.yy.o
	$(CC) -Wall -c $(PARSER).tab.c -o $(PARSER).tab.o
	$(CC) -Wall -c $(POLY).c -o $(POLY).o
	$(CC) -o $(BIN) lex.yy.o $(PARSER).tab.o $(POLY).o -lm

clean:
	rm -fv $(BIN) $(PARSER).tab.h $(PARSER).tab.c lex.yy.c lex.yy.o $(PARSER).tab.o lex.backup $(PARSER).dot $(PARSER).output *~ 

