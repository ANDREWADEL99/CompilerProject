/*              Declaration and Includers               */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    int yylex(void);
    void yyerror(char *s);
%}

%union {
    int INTEGER;
    float FLOAT;
    char CHARACTER;
    bool BOOLEAN;
    char* STRING;
};
%token RPAREN LPAREN RBRACE LBRACE COLON COMMA
%token <STRING>      IDENTIFIER
%token <INTEGER>     NUM_INTEGER 
%token <FLOAT>       NUM_FLOATING
%token <CHARACTER>   CHAR_VALUE
%token <BOOLEAN>     BOOL
%token TYPE_CONSTANT TYPE_INTEGER TYPE_FLOAT TYPE_CHARACTER TYPE_BOOL VOID RETURN

%token WHILE FOR DO BREAK IF SWITCH CASE DEFAULT
%nonassoc IFX
%nonassoc ELSE

%right ASSIGN OP_NOT
%left OP_AND OP_OR
%left OP_GTE OP_LTE OP_EQ OP_NOTEQ OP_GT OP_LT 
%left PLUS MINUS 
%left MULTIPLY DIVIDE
%nonassoc UMINUS

%%

/*              Grammer Rules               */

/* first rule */
program:    program statement  {printf("program:    program statement\n\n");} |   program function   {printf("program:    program function\n\n");} |;

statement:      variable_declaration ';' {printf("statement:    variable_declaration ';'\n\n");}
            |   constant_declaration ';' {printf("statement:    constant_declaration ';'\n\n");}
            |   expression ';'           {printf("statement:    expression ';'\n\n");}
            |   loop                     {printf("statement:    loop \n\n");}
            |   condition                {printf("statement:    condition \n\n");}
            |   function_return ';'      {printf("statement:    function_return \n\n");}
            |   assignment_statments ';' {printf("statement:    assignment_statments \n\n");}
            |   LBRACE statements  statement RBRACE
            |   ';'
            ;
			
statements: | statements statement; 

loop:   FOR LPAREN variable_declaration ';' expression ';' assignment_statments RPAREN statement {printf("loop:    FOR \n\n");}
    |   FOR LPAREN assignment_statments ';' expression ';' assignment_statments RPAREN statement {printf("loop:    FOR without declaration \n\n");}
    |   WHILE LPAREN expression RPAREN statement      {printf("loop:    WHILE \n\n");}
    |   DO  statement WHILE LPAREN expression RPAREN  {printf("loop:    DO \n\n");}
    |   BREAK ';' ;

condition:      IF LPAREN expression RPAREN statement %prec IFX
            |   IF LPAREN expression RPAREN statement ELSE statement
            |   SWITCH LPAREN expression RPAREN LBRACE case_list DEFAULT COLON statement RBRACE;

case_list:    |  case_list CASE expression COLON statement |case_list CASE expression COLON statement BREAK';' ;

expression:     LPAREN expression RPAREN
            |   data_value
            |   IDENTIFIER
            |   Mathematical_expression
            |   comparison_operation
            |   Logical_expression
            |   function_call
            |   MINUS expression %prec UMINUS
            ;

data_type :     TYPE_INTEGER |   TYPE_FLOAT |   TYPE_BOOL |   TYPE_CHARACTER;

data_value:     NUM_INTEGER |   NUM_FLOATING |   CHAR_VALUE |   BOOL ;

Mathematical_expression:   expression PLUS expression |   expression MINUS expression |   expression MULTIPLY expression|   expression DIVIDE expression ;

comparison_operation:   expression OP_LT expression |   expression OP_GT expression
                    |   expression OP_LTE expression|   expression OP_GTE expression
                    |   expression OP_EQ expression |   expression OP_NOTEQ expression;

Logical_expression:  expression OP_AND expression  |   expression OP_OR expression|   OP_NOT expression;


variable_declaration:   data_type IDENTIFIER |   data_type IDENTIFIER ASSIGN expression  ;

constant_declaration:   TYPE_CONSTANT data_type IDENTIFIER ASSIGN expression

assignment_statments:   IDENTIFIER ASSIGN expression ;

function:   data_type IDENTIFIER  LPAREN parameters RPAREN statement |   VOID IDENTIFIER  LPAREN parameters RPAREN statement;

function_call:  IDENTIFIER LPAREN arguments RPAREN ;

parameters:       variable_declaration  |  parameters COMMA variable_declaration | ;

arguments:     expression     |   arguments COMMA expression     |     ;

function_return:    RETURN    |   RETURN  expression 
            
%%
/*              Programs             */

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}
int main(void) {
    yyparse();
    return 0;
}