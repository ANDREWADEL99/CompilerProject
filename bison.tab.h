
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
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


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     RPAREN = 258,
     LPAREN = 259,
     RBRACE = 260,
     LBRACE = 261,
     COLON = 262,
     COMMA = 263,
     IDENTIFIER = 264,
     NUM_INTEGER = 265,
     NUM_FLOATING = 266,
     CHAR_VALUE = 267,
     BOOL = 268,
     TYPE_CONSTANT = 269,
     TYPE_INTEGER = 270,
     TYPE_FLOAT = 271,
     TYPE_CHARACTER = 272,
     TYPE_BOOL = 273,
     VOID = 274,
     RETURN = 275,
     WHILE = 276,
     FOR = 277,
     DO = 278,
     BREAK = 279,
     IF = 280,
     SWITCH = 281,
     CASE = 282,
     DEFAULT = 283,
     IFX = 284,
     ELSE = 285,
     OP_NOT = 286,
     ASSIGN = 287,
     OP_OR = 288,
     OP_AND = 289,
     OP_LT = 290,
     OP_GT = 291,
     OP_NOTEQ = 292,
     OP_EQ = 293,
     OP_LTE = 294,
     OP_GTE = 295,
     MINUS = 296,
     PLUS = 297,
     DIVIDE = 298,
     MULTIPLY = 299,
     UMINUS = 300
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 12 "Bison.y"

    int INTEGER;
    float FLOAT;
    char CHARACTER;
    bool BOOLEAN;
    char* STRING;



/* Line 1676 of yacc.c  */
#line 107 "Bison.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


