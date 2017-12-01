all:
	flex AST.l
	bison -d AST.y
	gcc lex.yy.c AST.tab.c print.c -o AST -lfl -g

clean:
	rm -rf lex.yy.c AST.tab.c AST.tab.h AST tree.txt
