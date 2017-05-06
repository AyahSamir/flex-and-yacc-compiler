%{
	#include <iostream>
	#include <stdio.h>
	#include <string>
	#include "symboltable.cpp"
	#include "nodeType.h"

	using namespace std;
	#define YY_DECL extern int yylex()
	#include "y.tab.h"
	
%}
Digit           [0-9]
Letter          [a-zA-Z]

%%
int|INT 						return INT;
float|FLOAT						return FLOAT;
bool|BOOL						return BOOL;
print|PRINT 						return PRINT;
break|BREAK						return BREAK;
continue|CONTINUE					return CONTINUE;
switch|SWITCH						return SWITCH;
void|VOID						return VOID;
if|IF 							return IF;
else|ELSE 						return ELSE;
while|WHILE						return WHILE;
for|FOR							return FOR;
do|DO 							return DO;
function|FUNCTION					return FUNCTION;

{Letter}({Letter}|{Digit})*				{
							char* id = (char*)malloc(strlen(yytext)+1);
							strcpy(id,yytext);
							yylval.sval = id;
                					return ID;
                						}

{Digit}+						{
							yylval.ival = atoi(yytext);
							return NUM_INT;
								}
{Digit}?+"."+{Digit}+					{	
							yylval.fval = atof(yytext);
							return NUM_FLOAT;
								}
[-()<>=+*/;{}.]						{return *yytext;}
"<="							return LE;
">="							return GE;
"=="							return EQ;	
"!="							return NE;
[ \t]+							; /*ignore white spaces*/
[\n]							yylineno=yylineno+1;
.							printf("error\n");
\/\*.*							;
\/\/.*							;
\/\*(.*\n)*.*\*\/					;
%%
int yywrap(){
	return 1;
}
