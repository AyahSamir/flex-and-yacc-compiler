#include <stdio.h>	
#include "y.tab.h"

static int lbl;
extern FILE *outfile;

int ex(nodeType *p,string var) {
	int lbl1, lbl2;

	if (!p) return 0;
	switch(p->type) {
	case typeCon:
		switch(p->con.value.type) {
		case typeInt:
			fprintf(outfile,"\tpush\t%d\n", p->con.value.i); 
			break;
		case typeFlt:
			fprintf(outfile,"\tpush\t%f\n", p->con.value.f);
			break;
		case typeChar:
			fprintf(outfile,"\tpush\t%c\n", p->con.value.c); 
			break;
		case typeBool:
			fprintf(outfile,"\tpush\t%d\n", p->con.value.b); 
			break;
		}
		break;
	case typeId:
		fprintf(outfile,"\tpush\t%s\n", p->id.name);
		break;
	case typeOpr:
		switch(p->opr.oper) {
		case WHILE:
			fprintf(outfile,"L%03d:\n", lbl1 = lbl++);
			ex(p->opr.op[0],"");
			fprintf(outfile,"\tjz\tL%03d\n", lbl2 = lbl++);
			ex(p->opr.op[1],"");
			fprintf(outfile,"\tjmp\tL%03d\n", lbl1);
			fprintf(outfile,"L%03d:\n", lbl2);
			break;
		case IF:
			ex(p->opr.op[0],"");
			if (p->opr.nops > 2) {
				/* if else */
				fprintf(outfile,"\tjz\tL%03d\n", lbl1 = lbl++);
				ex(p->opr.op[1],"");
				fprintf(outfile,"\tjmp\tL%03d\n", lbl2 = lbl++);
				fprintf(outfile,"L%03d:\n", lbl1);
				ex(p->opr.op[2],"");
				fprintf(outfile,"L%03d:\n", lbl2);
			} else {
				/* if */
				fprintf(outfile,"\tjz\tL%03d\n", lbl1 = lbl++);
				ex(p->opr.op[1],"");
				fprintf(outfile,"L%03d\n",lbl2);				
			}
			break;
		case PRINT:
			ex(p->opr.op[0],"");
			fprintf(outfile,"\tprint\n");
			break;
		case '=':
			ex(p->opr.op[1],"");
			fprintf(outfile,"\tpop\t%s\n", p->opr.op[0]->id.name);
			break;
		case UMINUS:
			ex(p->opr.op[0],"");
			fprintf(outfile,"\tneg\n");
			break;
		case '!':
			ex(p->opr.op[0],"");
			fprintf(outfile,"\tnot\n"); break;
		case FOR:
			ex(p->opr.op[0],"");
			ex(p->opr.op[1],"");
			fprintf(outfile,"\tjz\tL%03d\n",lbl1=lbl++);
			fprintf(outfile,"L%03d:\n", lbl);
			ex(p->opr.op[3],"");
			ex(p->opr.op[2],""); 
			ex(p->opr.op[1],"");
			fprintf(outfile,"\tjnz\tL%03d\n",lbl );
			fprintf(outfile,"L%03d:\n",lbl1);
			break;
		case DO:
			fprintf(outfile,"L%03d:\n", lbl1 = lbl++);
			ex(p->opr.op[0],"");
			ex(p->opr.op[1],"");
			fprintf(outfile,"\tjz\tL%03d\n", lbl2 = lbl++);
			fprintf(outfile,"\tjmp\tL%03d\n", lbl1);
			fprintf(outfile,"L%03d:\n", lbl2);
			break;
		case SWITCH:
			ex(p->opr.op[2],p->opr.op[0]->id.name);
			break;
		case CASE:
			fprintf(outfile,"\tmov\t%s",var.c_str());
			fprintf(outfile, ",switch_var\n");
			fprintf(outfile,"\tmov\t%d,case_var\n",p->opr.op[0]->con.value.i);
			fprintf(outfile,"\txor\tcase_var,switch_var\n");
			fprintf(outfile,"\tjnz\tL%03d\n", lbl2 = lbl++);
			ex(p->opr.op[1],"");
			fprintf(outfile,"L%03d:\n", lbl2);
			if(p->opr.op[2] != NULL)
				ex(p->opr.op[2],var);
			break;
		case CASE2:
			fprintf(outfile,"\tmov\t%s",var.c_str());
			fprintf(outfile, ",switch_var\n");
			fprintf(outfile,"\tmov\t%d,case_var\n",p->opr.op[0]->con.value.i);
			fprintf(outfile,"\txor\tcase_var,switch_var\n");
			fprintf(outfile,"\tjnz\tL%03d\n", lbl2 = lbl++);
			ex(p->opr.op[1],"");
			fprintf(outfile,"L%03d:\n", lbl2);
			break;
		default:
			ex(p->opr.op[0],"");
			ex(p->opr.op[1],"");
			switch(p->opr.oper) {
			case '+':
			fprintf(outfile,"\tadd\n"); break;
			case '-':
			fprintf(outfile,"\tsub\n"); break;
			case '*':
			fprintf(outfile,"\tmul\n"); break;
			case '/':
			fprintf(outfile,"\tdiv\n"); break;
			case '<':
			fprintf(outfile,"\tcompLT\n"); break;
			case '>':
			fprintf(outfile,"\tcompGT\n"); break;
			case GE:
			fprintf(outfile,"\tcompGE\n"); break;
			case LE:
			fprintf(outfile,"\tcompLE\n"); break;
			case NE:
			fprintf(outfile,"\tcompNE\n"); break;
			case EQ:
			fprintf(outfile,"\tcompEQ\n"); break;
			case AND:
			fprintf(outfile,"\tand\n"); break;
			case OR:
			fprintf(outfile,"\tor\n"); break;
			}
		}
	}
	return 0;
}
