%{
#include <cstdarg>
#include <string.h>
#include <iostream>
#include "symboltable.cpp"
#include "nodeType.h"
#include "compiler.cpp"
#define YY_DECL extern int yylex()


using namespace std;


// stuff from flex that bison needs to know about:
extern int yylex();
extern int yyparse();
extern int yylineno();
extern FILE *yyin;

/* prototypes */
nodeType *opr(int type, int oper, int nops, ...);	/* type of operands: NUMBERS:0, OTHERS:1, BOOL:2 */
nodeType *id(int type,char* name, bool dec);
nodeType *con(char t, conValue value);

void freeNode(nodeType *p);
int ex(nodeType *p);

/* SymbolTable */
symboltable sym;

void yyerror(const char *s);
char* errmsg;
%}

%union {
	conValue cvalue;	/*constants*/
	int ivalue;		/*type of constants : INT:0 , FLOAT:1 , BOOL:2 , CHAR:3 , UNDEFINED:-1 */
	char *sval;		/*identifier_name*/
	nodeType *nPtr;		/*node_pointer*/
}

%token <cvalue> NUM_INT
%token <cvalue> NUM_FLOAT
%token <cvalue> BOOL_TRUE
%token <cvalue> BOOL_FALSE
%token <cvalue> VAL_CHAR
%token <sval> ID
%token <ivalue> INT
%token <ivalue> FLOAT
%token <ivalue> BOOL
%token <ivalue> CHAR

%token BREAK 
%token CONTINUE 
%token SWITCH
%token CASE 
%token IF 
%token ELSE
%token WHILE
%token FOR
%token DO
%token FUNCTION
%token PRINT
%token CONST
%nonassoc IFX
%nonassoc ELSE


%right '='
%left AND OR
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc '!'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list stmt_case
%type <ivalue> types

%%
program:
	function			{ exit(0); }
	;

function:
	function stmt 			{ ex($2); freeNode($2);}
	| /* NULL */
	;

stmt:
	';'				{ $$ = opr(1,';', 2, NULL, NULL); }
	| PRINT expr ';'		{ $$ = opr(1,PRINT, 1, $2); }
	| types ID '=' expr ';'		{ $$ = opr(1,'=', 2 , id($1, $2, true), $4); }
	| CONST types ID '=' expr ';'	{ $$ = opr(1,'=', 2 , id($2, $3, true), $5); }
	| types ID ';'			{ $$ = id($1, $2, false); } 
	| ID '=' expr ';'		{ $$ = opr(1,'=', 2 , id(-1,$1,true), $3); }

	| WHILE '(' expr ')' stmt 	 { $$ = opr(1,WHILE, 2, $3, $5); }
	| DO '{' stmt_list '}' WHILE '(' expr ')'   { $$ = opr(2,DO,2,$3,$7); }

	| IF '(' expr ')' stmt %prec IFX { $$ = opr(1,IF, 2, $3, $5); }
	| IF '(' expr ')' stmt ELSE stmt { $$ = opr(1,IF, 3, $3, $5, $7); }

	| FOR '(' stmt  expr ';' stmt ')' '{' stmt '}' { $$ = opr(2,FOR,4,$3,$4,$6,$9); }

	| SWITCH ID stmt_case 		{ $$ = opr(1,SWITCH , 2, $2, $3); }	

	| '{' stmt_list '}'		{ $$ = $2; }
	;

stmt_case:
	 CASE expr '{' stmt '}' 	    { $$ = opr(1,CASE,2,$2,$4); }
	| CASE expr '{' stmt '}' stmt_case  { $$ = opr(1,CASE,3,$2,$4,$6); }
	;

stmt_list:	
	stmt				{ $$ = $1; }
	| stmt_list stmt		{ $$ = opr(1,';', 2, $1, $2); }
	;

expr:
	NUM_INT				{ $$ = con('i',$1); }
	| NUM_FLOAT			{ $$ = con('f',$1); }
	| BOOL_TRUE			{ $$ = con('b',$1); }
	| BOOL_FALSE			{ $$ = con('b',$1); }
	| VAL_CHAR 			{ $$ = con('c',$1); }
	| ID				{ $$ = id(-1,$1,false); }

	| '-' expr %prec UMINUS 	{ $$ = opr(0,UMINUS, 1, $2); }
	| expr '+' expr			{ $$ = opr(0,'+', 2, $1, $3);}
	| expr '-' expr			{ $$ = opr(0,'-', 2, $1, $3); }
	| expr '*' expr			{ $$ = opr(0,'*', 2, $1, $3); }
	| expr '/' expr			{ $$ = opr(0,'/', 2, $1, $3); }
	| expr '<' expr			{ $$ = opr(0,'<', 2, $1, $3); }
	| expr '>' expr			{ $$ = opr(0,'>', 2, $1, $3); }
	| expr GE expr			{ $$ = opr(0,GE, 2, $1, $3); }
	| expr LE expr			{ $$ = opr(0,LE, 2, $1, $3); }
	| expr NE expr			{ $$ = opr(0,NE, 2, $1, $3); }
	| expr EQ expr			{ $$ = opr(2,EQ, 2, $1, $3); }
	| expr OR expr			{ $$ = opr(2,OR, 2, $1, $3); }
	| expr AND expr			{ $$ = opr(2,AND, 2, $1, $3);}
	| '!' expr 			{ $$ = opr(2,'!', 1, $2);}
	| '(' expr ')'			{ $$ = $2; }
	;

types:
	INT				{ $$ = $1; }					 
	| FLOAT 			{ $$ = $1; }
	| BOOL 				{ $$ = $1; }
	| CHAR				{ $$ = $1; }
	;
	
%%

//#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(char t, conValue v) {
	nodeType *p;

	/* allocate node */
	if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	
	/* copy information */
	p->type = typeCon;
	
	if(t == 'i')
		{p->con.value.i = v.i; 	p->con.value.type = typeInt;  }
	else if(t == 'f')
		{p->con.value.f = v.f; 	p->con.value.type = typeFlt;  }
	else if(t == 'c')
		{p->con.value.c = v.c;  p->con.value.type = typeChar;  }
	else if(t == 'b')
		{p->con.value.b = v.b;  p->con.value.type = typeBool;  }

	return p;
}


nodeType *id(int idtype, char* name, bool init) {	
	nodeType *p;

	/* allocate node */
	if ((p = (nodeType *)malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");
	
	/* copy information */
	p->type = typeId;
	p->id.name = name;	

	//Search for an existing node
	SymbTableNode* node = sym.Search(p->id.name);

	if(init && (idtype!=-1))	//int x = 3;
		{
		 if(node != NULL)	{ errmsg = strcat("redeclaration of variable :",name); yyerror(errmsg);}
		 else   {sym.Insert(p->id.name,idtype,1);}
		}

	else if(!init)		
		{ 
		 if(idtype!=-1)		//int x;
		 {	
		 	if(node != NULL) {yyerror("redeclaration of variable");}
			else 	{sym.Insert(p->id.name,idtype,0);}
		 }
		 else	
		 {			//x as an operand
			if(node == NULL) {yyerror("was not declared in this scope");}
			else    {node->used = true;}

			if(node->assig == false)	{yyerror("variable used before initialization");}
		 }
		}
	else 				//x = 3;
		{
		 if(node == NULL)	{yyerror("was not declared in this scope");}
		 else 	{node->assig = true;}
		}

	//sym.showSymbolTable(); 
	cout<<endl;
	//sym.showUnsedVars();
	

	return p;
}

nodeType *opr(int oper_type, int oper, int nops ...) {
	va_list ap;
	nodeType *p;
	int i;

	/* allocate node, extending op array */
	if ((p = (nodeType *)malloc(sizeof(nodeType) +
		(nops-1) * sizeof(nodeType *))) == NULL)
	   yyerror("out of memory");
	
	//variables used in operations and operands matching
	bool all_nums = true;
	bool all_bool = true;

	//variables used in assignment matching
	int first_type=0;
	int second_type=0;
	string first_name;

	/* copy information */
	p->type = typeOpr;
	p->opr.op_type = oper_type;
	p->opr.oper = oper;
	p->opr.nops = nops;

	va_start(ap, nops);
	for (i = 0; i < nops; i++){

		p->opr.op[i] = va_arg(ap, nodeType*);
		
		/* OPERATIONS AND OPERAND MATCHING */
		if(oper_type == 0 || oper_type == 2 || oper == '=' || oper == IF) {		//check for arith,logical,assig operations
			switch(p->opr.op[i]->type){
			case typeCon:{			
					switch(p->opr.op[i]->con.value.type) {

					case typeInt:
						all_bool = false;
						break;
					case typeFlt:
						all_bool = false;
						break;
					case typeChar:
						all_nums = false;
						all_bool = false;
						break;
					case typeBool:
						all_nums = false;
						break;
					}

					//save operand type
					if(!i) 	first_type = p->opr.op[i]->con.value.type;	
					else 	second_type = p->opr.op[i]->con.value.type;

					break;
				}//case

			case typeId:{
					//Search for an existing node
					SymbTableNode* node = sym.Search(p->opr.op[i]->id.name);
					if(node->type == 2) //bool
						all_nums = false;
					else if (node->type == 3){ //char
						all_nums = false; 	
						all_bool = false;
					}
					else
						all_bool = false;
					
					//save operand type
					if(!i) 	{ first_type = node->type;	first_name = node->name; }	
					else 	second_type = node->type;
					break; 
				}

			case typeOpr:{
					if(p->opr.op[i]->opr.op_type == 0) //num operands 
						{all_bool = false;}
					else if(p->opr.op[i]->opr.op_type == 2) //bool operands	
						{all_nums = false;}
					else    {all_nums = false; all_bool = false;}
					
					//save operand type
					if(!i) 	first_type = p->opr.op[i]->opr.op_type;	
					else 	second_type = p->opr.op[i]->opr.op_type;

					break;
				}//end case

			}//end switch
		}//end if
		
	}//end for
	
	//cout<<"oper_type "<<oper_type<<" all_nums"<<all_nums<<" all_bool "<<all_bool<<endl;
	//cout<<"first type "<<first_type<<" second_type "<<second_type<<endl;

	/* SEMANTIC CHECKS */

	if(oper_type == 0 && !all_nums)		yyerror("operator doesn't match this kind of operand, expected num");
	if(oper != EQ && oper_type == 2 && !all_bool) 	yyerror("operator doesn't match this kind of operand, expected bool");

	
	if((oper=='=') || (oper==EQ)){
		if(first_type != second_type)
			yyerror("operands types dont match");
		cout<<first_name;
	}


	if(oper == IF){
		if(first_type != 2)
			yyerror("condition of IF statement should be boolean");
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

/*type = 1 for errors , 0 for warnings */
void yyerror(const char *s) {
	cout << "parse error!  line" << yylineno << ":" << s << endl;
	// might as well halt now:
	//	exit(-1);
}
