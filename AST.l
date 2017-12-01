%{
#include <stdlib.h>
#include <string.h>

#include "AST.tab.h"
%}

intnum [0-9]+
floatnum [0-9]+.[0-9]+
special [\*\/\-\+]
space [ \t\r\n]
id [A-Za-z_][A-Za-z0-9_]*

%%

"class" {return CLS;}
"private" {return PRIVATE;}
"public" {return PUBLIC;}
"int" {return INT;}
"float" {return FLOAT;}
"main" {return MAIN;}
"return" {return RETURN;}
"while" {return WHILE;}
"do" {return DO;}
"for" {return FOR;}
"if" {return IF;}
"else" {return ELSE;}
"<" {return LT;}
">" {return GT;}
"<=" {return LE;}
">=" {return GE;}
"==" {return EQ;}
"!=" {return NE;}
"::" {return SCOPE;}
"=" {return *yytext;}
":" {return *yytext;} 
"." {return *yytext;}
"," {return *yytext;}
";" {return *yytext;}
"(" {return *yytext;}
")" {return *yytext;}
"{" {return *yytext;}
"}" {return *yytext;}
"[" {return *yytext;}
"]" {return *yytext;}

{space} ;

{intnum} {
	yylval.intnum = atoi(yytext);
	return INTNUM;
}

{floatnum} {
	yylval.floatnum = atof(yytext);
	return FLOATNUM;
}

{special} {return yytext[0];}

{id} {
	yylval.str = strndup(yytext, yyleng);
	return ID;
}
