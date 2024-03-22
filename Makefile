PARSER = parser
SCANNER = scanner
POLY = poly
BIN = exec
CC = gcc

all:
	bison -d $(PARSER).y
	flex $(SCANNER).l
	$(CC) -c lex.yy.c -o lex.yy.o
	$(CC) -c $(PARSER).tab.c -o $(PARSER).tab.o
	$(CC) -c $(POLY).c -o $(POLY).o -lm
	$(CC) -o $(BIN) lex.yy.o $(PARSER).tab.o $(POLY).o -lm

install:
	@sudo apt install flex -y
	@sudo apt install bison -y

uninstall:
	@sudo apt remove flex -y
	@sudo apt remove bison -y

clean:
	rm -fv $(BIN) $(POLY).o $(PARSER).tab.h $(PARSER).tab.c lex.yy.c lex.yy.o $(PARSER).tab.o lex.backup $(PARSER).dot $(PARSER).output *~ 

