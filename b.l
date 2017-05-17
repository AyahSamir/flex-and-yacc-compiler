

%option nounput yylineno
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

int|INT 						{ yylval.ivalue = 0; return INT; }
float|FLOAT						{ yylval.ivalue = 1; return FLOAT; }
bool|BOOL						{ yylval.ivalue = 2; return BOOL; }
char|CHAR						{ yylval.ivalue = 3; return CHAR; }
print|PRINT 						return PRINT;
break|BREAK						return BREAK;
continue|CONTINUE					return CONTINUE;
switch|SWITCH						return SWITCH;
case|CASE 						return CASE;
if|IF 							return IF;
else|ELSE 						return ELSE;
while|WHILE						return WHILE;
for|FOR							return FOR;
do|DO 							return DO;
CONST|const						return CONST;
function|FUNCTION					return FUNCTION;

true|TRUE						{
							yylval.cvalue.b = true;
							return BOOL_TRUE;
								}

false|FALSE						{
							yylval.cvalue.b = false;
							return BOOL_FALSE;
								}

{Letter}({Letter}|{Digit})*				{
							char* id = (char*)malloc(strlen(yytext)+1);
							strcpy(id,yytext);
							yylval.sval = id;
                					return ID;
                						}

"'"{Letter}"'"							{
							yylval.cvalue.c = *(yytext+1); 
							return VAL_CHAR;
								}
								
{Digit}+						{
							yylval.cvalue.i = atoi(yytext);
							return NUM_INT;
								}
{Digit}?+"."+{Digit}+					{	
							yylval.cvalue.f = atof(yytext);
							return NUM_FLOAT;
								}
[-()<>=+*/;{}!.]					{return *yytext;}
"<="							return LE;
">="							return GE;
"=="							return EQ;	
"!="							return NE;
[ \t]+							; /*ignore white spaces*/
[\n]							yylineno++; 
"&&"							return AND;
"||"							return OR;
.							printf("error\n");
\/\*.*							;
\/\/.*							;
\/\*(.*\n)*.*\*\/					;
%%
int yywrap(){
	return 1;
}
