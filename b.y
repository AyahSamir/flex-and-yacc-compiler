%{
#include <cstdarg>
#include <vector>
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
int ex(nodeType *p,string var);
void newScope(symboltable *old);

/* SymbolTable */
vector<symboltable> sym_vec;
int symtablecount = -1;

symboltable sym;
symboltable *curr_sym = &sym;
bool newSymNeeded=false;

void yyerror(const char *s);
void senderror(const char *s , const char*x);

FILE *myfile;
FILE *outfile;

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
%token CASE2  
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

%type <nPtr> stmt expr stmt_list stmt_case b
%type <ivalue> types

%%
program:
	function			{ exit(0); }
	;

function:
	function stmt 			{ ex($2,""); freeNode($2);}
	| /* NULL */
	;

b: 
	'{'				{ newSymNeeded = true; symtablecount++;}
	;

stmt:
	';'							{ $$ = opr(1,';', 2, NULL, NULL); }
	| PRINT expr ';'					{ $$ = opr(1,PRINT, 1, $2); }
	| types ID '=' expr ';'					{ $$ = opr(1,'=', 2 , id($1, $2, true), $4); }
	| types ID ';'						{ $$ = id($1, $2, false); } 
	| ID '=' expr ';'					{ $$ = opr(1,'=', 2 , id(-1,$1,true), $3); }
	| CONST types ID '=' expr ';'				{ $$ = opr(1,'=', 2 , id($2, $3, true), $5); }
	
	| WHILE '(' expr ')' b stmt '}'			{ if(curr_sym->Prev != NULL){curr_sym = curr_sym->Prev;} $$ = opr(1,WHILE, 2, $3, $6); }
	| DO b stmt_list '}' WHILE '(' expr ')'  	{ if(curr_sym->Prev != NULL){curr_sym = curr_sym->Prev;} $$ = opr(1,DO,2,$3,$7); }
	| IF '(' expr ')' stmt %prec IFX 		{ $$ = opr(1,IF, 2, $3, $5); }
	| IF '(' expr ')' stmt ELSE stmt		{ $$ = opr(1,IF, 3, $3, $5, $7); }
	
	| FOR '(' stmt  expr ';' stmt ')' b stmt '}' 	{ if(curr_sym->Prev != NULL){curr_sym = curr_sym->Prev;} $$ = opr(1,FOR,4,$3,$4,$6,$9); }
	| SWITCH ID '{' stmt_case '}'		 	{ $$ = opr(1,SWITCH , 3,id(-1,$2,true),$2, $4); }	
	| b stmt_list '}'		 		{ if(curr_sym->Prev != NULL){curr_sym = curr_sym->Prev;}  $$ = $2; }
	| error ';'					{ }
        | error '}'					{ }
	;

stmt_case:
	 CASE expr b stmt_list '}' 	    	{if(curr_sym->Prev != NULL){curr_sym = curr_sym->Prev;} $$ = opr(1,CASE2,2,$2,$4); }
	| CASE expr b stmt_list '}' stmt_case  	{if(curr_sym->Prev != NULL){curr_sym = curr_sym->Prev;} $$ = opr(1,CASE,3,$2,$4,$6); }
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

	if(newSymNeeded){
		newScope(curr_sym);
		curr_sym = &sym_vec[sym_vec.size()-1]; 
		newSymNeeded = false;
	}

	//Search for an existing node
	SymbTableNode* node = curr_sym->Search(p->id.name);

	if(init && (idtype!=-1))	//int x = 3;
		{
		 if(node != NULL)	{senderror("redeclaration of variable :",name);}
		 else   {curr_sym->Insert(p->id.name,idtype,1);}
		}

	else if(!init)		
		{ 
		 if(idtype!=-1)		//int x;
		 {	
		 	if(node != NULL) {senderror("redeclaration of variable :",name);}
			else 	{curr_sym->Insert(p->id.name,idtype,0);}
		 }
		 else	
		 {			//x as an operand
			if(node == NULL) {
					if(curr_sym->Prev == NULL){
						{senderror("variable was not declared in this scope",name);}
					}
					else{
						symboltable *tmp = curr_sym;
						while(curr_sym->Prev != NULL){
							curr_sym = curr_sym->Prev;
							node = curr_sym->Search(p->id.name);
							if (node != NULL){
								node->used = true;
								break;
							}
						}
						if(node == NULL) {senderror("variable was not declared in this scope",name);}
						curr_sym = tmp;
					}

					
				}
			else    {node->used = true;}

			if(node->assig == false)	{senderror("variable used before initialization",name);}
		 }
		}
	else 				//x = 3;
		{
		 if(node == NULL)	{
		 	if(curr_sym->Prev == NULL){
						{senderror("variable was not declared in this scope",name);}
					}
					else{
						symboltable *tmp = curr_sym;
						while(curr_sym->Prev != NULL){
							curr_sym = curr_sym->Prev;
							node = curr_sym->Search(p->id.name);
							if (node != NULL){
								node->assig = true;
								break;
							}
						}
						if(node == NULL) {senderror("variable was not declared in this scope",name);}
						curr_sym = tmp;
					}
		 }
		 else 	{node->assig = true;}
		}
	//curr_sym->showSymbolTable(); 
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
					SymbTableNode* node = curr_sym->Search(p->opr.op[i]->id.name);
					if(node == NULL ){
						symboltable *tmp = curr_sym;
						while(curr_sym->Prev != NULL){
							curr_sym = curr_sym->Prev;
							node = curr_sym->Search(p->opr.op[i]->id.name);
							if (node != NULL)
								break;
						}
						curr_sym = tmp;
					}

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

	if(oper_type == 0 && !all_nums)		senderror("operator doesn't match this kind of operand, expected num"," ");
	if(oper != EQ && oper_type == 2 && !all_bool) 	senderror("operator doesn't match this kind of operand, expected bool"," ");

	
	if((oper=='=') || (oper==EQ)){
		if(first_type != second_type)
			senderror("operands types dont match"," ");
	}


	//if(oper == IF){
	//	if(first_type != 2)
		//	senderror("condition of IF statement should be boolean"," ");
	//}

	va_end(ap);
	
	return p;
}

void newScope(symboltable *old){
	symboltable tmp;
	tmp.Prev = old;
	old->Next = &tmp;
	sym_vec.push_back(tmp);
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
	
	// open a file handle to a particular file:
	myfile = fopen("in.txt", "r");
	outfile = fopen("out.txt", "w");

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
	
	
	fclose(myfile);
	fclose(outfile);

	//return yyparse();
	
}

void senderror(const char*s , const char* x){

	cout << "error line " << yylineno << ": " << s << " " << x <<endl;
	exit(-1);

}

void yyerror(const char *s) {
	cout << "parse error!  line " <<yylineno <<": "<< s<< endl
	// might as well halt now:
		exit(-1);
}
