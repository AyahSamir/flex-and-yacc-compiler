typedef enum { typeCon, typeId, typeOpr } nodeEnum;
typedef enum { typeInt, typeFlt, typeBool, typeChar} varEnum;

struct conValue{
  	 varEnum type;  	//needed in compiler.cpp
	 union {
		int i;
	   	float f;
		bool b;
	   	char c; 	
	 };  
}; 

/* constants */
typedef struct {
	conValue value;			/* value of constant */
	char* contype;
} conNodeType;

/* identifiers */
typedef struct {
	char* name;			/* name of identifier */
} idNodeType;

/* operators */
typedef struct {
	int op_type;			/* type of operands: NUMBERS:0, BOOLEANS:1, OTHER:2 */
	int oper;			/* operator */
	int nops;			/* number of operands */
	struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
	nodeEnum type;			/* type of node */
	
	union {
		conNodeType con;	/* constants */	
		idNodeType id;		/* identifiers */
		oprNodeType opr;	/* operators */
	};
} nodeType;

