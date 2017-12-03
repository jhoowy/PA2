all:
	flex DFA.l
	bison -d DFA.y
	gcc lex.yy.c DFA.tab.c print.c -o DFA -lfl -g

clean:
	rm -rf lex.yy.c DFA.tab.c DFA.tab.h DFA liveness.out CFG.out
