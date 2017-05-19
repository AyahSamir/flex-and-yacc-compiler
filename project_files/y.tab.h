/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NUM_INT = 258,
    NUM_FLOAT = 259,
    BOOL_TRUE = 260,
    BOOL_FALSE = 261,
    VAL_CHAR = 262,
    ID = 263,
    INT = 264,
    FLOAT = 265,
    BOOL = 266,
    CHAR = 267,
    BREAK = 268,
    CONTINUE = 269,
    SWITCH = 270,
    CASE = 271,
    CASE2 = 272,
    IF = 273,
    ELSE = 274,
    WHILE = 275,
    FOR = 276,
    DO = 277,
    FUNCTION = 278,
    PRINT = 279,
    CONST = 280,
    IFX = 281,
    AND = 282,
    OR = 283,
    GE = 284,
    LE = 285,
    EQ = 286,
    NE = 287,
    UMINUS = 288
  };
#endif
/* Tokens.  */
#define NUM_INT 258
#define NUM_FLOAT 259
#define BOOL_TRUE 260
#define BOOL_FALSE 261
#define VAL_CHAR 262
#define ID 263
#define INT 264
#define FLOAT 265
#define BOOL 266
#define CHAR 267
#define BREAK 268
#define CONTINUE 269
#define SWITCH 270
#define CASE 271
#define CASE2 272
#define IF 273
#define ELSE 274
#define WHILE 275
#define FOR 276
#define DO 277
#define FUNCTION 278
#define PRINT 279
#define CONST 280
#define IFX 281
#define AND 282
#define OR 283
#define GE 284
#define LE 285
#define EQ 286
#define NE 287
#define UMINUS 288

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 45 "b.y" /* yacc.c:1909  */

	conValue cvalue;	/*constants*/
	int ivalue;		/*type of constants : INT:0 , FLOAT:1 , BOOL:2 , CHAR:3 , UNDEFINED:-1 */
	char *sval;		/*identifier_name*/
	nodeType *nPtr;		/*node_pointer*/

#line 127 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
