#This is a simple C++ compiler using lex and yacc plus GUI for running it using TkInter

#bugs fixed so far :
- yylineno bug fixed .
- unused variables for switch
- using some var names like x, xx can not be handled by hash function [not a bug actually , err msg inhibited]

# bugs not fixed yet

- constants are treated like variables in symbol table


# features added so far :
- debug mode for showing symbol table separately from compilation mode
