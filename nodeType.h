typedef enum { typeConInt, typeConFlt, typeId, typeOpr } nodeEnum;

/* constants */
typedef struct {
	int value;			/* value of constant */
} conIntNodeType;

typedef struct {
	float value;			/* value of constant */
} conFltNodeType;

/* identifiers */
typedef struct {
	char* name;			/* name of identifier */
} idNodeType;

/* operators */
typedef struct {
	int oper;			/* operator */
	int nops;			/* number of operands */
	struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
	nodeEnum type;			/* type of node */
	
	union {
		conIntNodeType con;	/* constants */	
		conFltNodeType fcon;	/* constants_floats */	
		idNodeType id;		/* identifiers */
		oprNodeType opr;	/* operators */
	};
} nodeType;

