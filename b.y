%{
#include <cstdarg>
#include <iostream>
#include "symboltable.cpp"
#include "nodeType.h"
#include "compiler.cpp"
#define YY_DECL extern int yylex()

using namespace std;

// stuff from flex that bison needs to know about:
extern int yylex();
extern int yyparse();
extern FILE *yyin;

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(char* name, string type, bool dec);
nodeType *con(int value);
nodeType *fcon(float value);
void freeNode(nodeType *p);
int ex(nodeType *p);

/* SymbolTable */
symboltable sym;

void yyerror(const char *s);
%}

%union {
	int ival;
	float fval;
	char *sval;
	nodeType *nPtr;
}

%token <ival> NUM_INT
%token <fval> NUM_FLOAT
%token <sval> ID
%token INT
%token FLOAT
%token BOOL
%token CHAR
%token VOID 
%token BREAK 
%token CONTINUE 
%token SWITCH 
%token IF 
%token ELSE
%token WHILE
%token FOR
%token DO
%token FUNCTION
%token PRINT

%nonassoc ELSE
%nonassoc IFX

%right '='
%left AND OR
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%
program:
	function		{ exit(0); }
	;

function:
	function stmt 		{ ex($2); freeNode($2);}
	| /* NULL */
	;

stmt:
	';'			{ $$ = opr(';', 2, NULL, NULL); printf("***action ;***\n");}
	| expr ';'		{ $$ = $1; printf("***action expr***\n");}
	| PRINT expr ';'	{ $$ = opr(PRINT, 1, $2); printf("***action print***\n");}

	| ID '=' expr ';'	{ $$ = opr('=', 2 , id($1,"",true), $3);printf("***action id=expr***\n");}
	| INT ID '=' expr ';'   { $$ = opr('=', 2 , id($2,"int",true), $4); printf("***action type id=expr***\n");}
	| FLOAT ID '=' expr ';' { $$ = opr('=', 2 , id($2,"float",true), $4); printf("***action type id=expr***\n");}

	| WHILE '(' expr ')' stmt { $$ = opr(WHILE, 2, $3, $5); printf("***action while***\n"); }

	| IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); printf("***action if***\n");}
	| IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $5, $7); printf("***action if else***\n");}

	| '{' stmt_list '}'	{ $$ = $2; }
	;

stmt_list:	
	stmt			{ $$ = $1; }
	| stmt_list stmt	{ $$ = opr(';', 2, $1, $2); }
	;

expr:
	NUM_INT			{ $$ = con($1); }
	| NUM_FLOAT		{ $$ = fcon($1); }
	| ID			{ $$ = id($1,"",false); printf("***action id***\n"); }
	| INT ID 	        { $$ = opr(PRINT, 1 , id($2,"int",false)); printf("***action type id=expr***\n");}
	| FLOAT ID 		{ $$ = opr(PRINT, 1 , id($2,"float",false)); printf("***action type id=expr***\n");}
	| '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
	| expr '+' expr		{ $$ = opr('+', 2, $1, $3); }
	| expr '-' expr		{ $$ = opr('-', 2, $1, $3); }
	| expr '*' expr		{ $$ = opr('*', 2, $1, $3); }
	| expr '/' expr		{ $$ = opr('/', 2, $1, $3); }
	| expr '<' expr		{ $$ = opr('<', 2, $1, $3); }
	| expr '>' expr		{ $$ = opr('>', 2, $1, $3); }
	| expr GE expr		{ $$ = opr(GE, 2, $1, $3); }
	| expr LE expr		{ $$ = opr(LE, 2, $1, $3); }
	| expr NE expr		{ $$ = opr(NE, 2, $1, $3); }
	| expr EQ expr		{ $$ = opr(EQ, 2, $1, $3); }
	| expr OR expr		{ $$ = opr(OR, 2, $1, $3); }
	| expr AND expr		{ $$ = opr(AND, 2, $1, $3); }
	| expr NOT expr		{ $$ = opr(NOT, 2, $1, $3); }
	| '(' expr ')'		{ $$ = $2; }
	;
%%

//#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
	nodeType *p;

	cout<<"I got A constant "<<value<<endl;

	/* allocate node */
	if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	
	/* copy information */
	p->type = typeConInt;
	p->con.value = value;

	return p;
}

nodeType *fcon(float value) {
	nodeType *p;

	/* allocate node */
	if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	
	/* copy information */
	p->type = typeConFlt;
	p->fcon.value = value;

	return p;
}

/*dec=true if this is a declaration, false otherwise*/
nodeType *id(char* name, string t, bool dec) {	
	nodeType *p;

	cout<<"I got id of name"<<name<<endl;

	/* allocate node */
	if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	/* copy information */
	p->type = typeId;
	p->id.name = name;
	
	if(dec && t!="")	//int x = 3;
		{ cout<<"insert"<<endl;sym.Insert(p->id.name,t,1);	}
	else if(!dec)		//x = 3;
		{cout<<"insert"<<endl;sym.Insert(p->id.name,t,0);		}
	else 			//int x;
		{cout<<"set"<<endl;sym.SetAssigned(p->id.name); }

	sym.showSymbolTable(); cout<<endl;

	return p;
}

nodeType *opr(int oper, int nops, ...) {
	va_list ap;
	nodeType *p;
	int i;
	
	/* allocate node, extending op array */
	if ((p = (nodeType *)malloc(sizeof(nodeType) +
		(nops-1) * sizeof(nodeType *))) == NULL)
	   yyerror("out of memory");
	


	/* copy information */
	p->type = typeOpr;
	p->opr.oper = oper;
	p->opr.nops = nops;
	va_start(ap, nops);
	for (i = 0; i < nops; i++){
		p->opr.op[i] = va_arg(ap, nodeType*);
		//cout<<p->opr.op[0]->type;
	}
	va_end(ap);
	return p;
}

void freeNode(nodeType *p) {
	int i;

	if (!p) return;
	if (p->type == typeOpr) {
		for (i = 0; i < p->opr.nops; i++)
		freeNode(p->opr.op[i]);
	}
	free (p);
}

int main(int, char**) {
	
	/*// open a file handle to a particular file:
	FILE *myfile = fopen("in.txt", "r");
	// make sure it is valid:
	if (!myfile) {
		cout << "I can't open file!" << endl;
		return -1;
	}
	// set flex to read from it instead of defaulting to STDIN:
	yyin = myfile;
	
	// parse through the input until there is no more:
	do {
		yyparse();
	} while (!feof(yyin));
	
	*/
	return yyparse();
	
}

void yyerror(const char *s) {
	cout << "parse error!  Message: " << s << endl;
	// might as well halt now:
	exit(-1);
}
