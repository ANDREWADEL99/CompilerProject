%option yylineno
digit  [0-9]

%{
#include <stdlib.h>
#include <string>
#include <string.h>
#include <iostream>
#include <fstream>
#include <stdio.h>
#include "bison.tab.h"
#include <cstring>

extern FILE *yyin;
extern FILE *yyout;
void yyerror(char *);
void appendErrorToFile3(std::string line);
int scopeNumber = 0;
%}

%%
"int"           return INT;     
"string"        return STR;     
"bool"          return BOOL;    

"switch"        return SWITCH;  
"case"          return CASE;    
"default"       return DEFAULT; 
"const"         return CONST;   
"break"         return BREAK;   

"=="            return EQ;      
"!="            return NE;      
"or"            return OR;      
"and"           return AND;     
"not"           return NOT;     
"for"           return FOR;     
"do"            return DO;      
"while"         return WHILE;   

"if"            return IF; //If Condition Keyword
"else"          return ELSE; //Else Keyword in if conditions
"func"          return FUNCTION; //Keyword usef before declaring any function identifier
"true"          {       
                    yylval.stringValue = strdup("1");                                                        
                    return TRUEBOOL;
                } 
"false"         {       
                    yylval.stringValue = strdup("0");                                                        
                     return FALSEBOOL;
                } 


[a-zA-Z][_a-zA-Z0-9]*                                                          {   
                                                                                yylval.stringValue = strdup(yytext);
                                                                                return VARIDENTIFIER;
                                                                            } 
                                                                    
[_a-zA-Z][_a-zA-Z0-9]*                                                         {    
                                                                                yylval.stringValue = strdup(yytext);
                                                                                return FUNCIDENTIFIER;
                                                                            } 
                                                                                             
{digit}+                                                                    {
                                                                                yylval.stringValue = strdup(yytext);
                                                                                return INTEGER;
                                                                            }
\"[^"\n]*["\n]                                                              {   
                                                                                yylval.stringValue = strdup(yytext);
                                                                                return STRING;
                
                                                                            }
[{]         {   
                scopeNumber++;
                return *yytext;
            } //Open Scope

[}]         {   
                scopeNumber--;
                return *yytext;
            }            

[-()<>=+*/;^:%."",]     {
                        return *yytext;
                    } 

[ \t\n]+        ;       /* ignore whitespace */
.             {
                    std::string notError = "Unknown Error";
                    int n = notError.length();
                    char char_array[n+1];
                    strcpy(char_array, notError.c_str());
                    yyerror(char_array);
            } //White Space

"//".*                  	;       /*comment*/
%%
int yywrap(void) {
    return 1;
}
void appendErrorToFile3(std::string line)
{
    std::ofstream file;
    file.open ("./error.txt", std::ios::out | std::ios::app );
    file << line << std::endl;
}
void yyerror(char const*s) {
    std::string temp=s;
    temp+=" at line: "+std::to_string(yylineno);
    appendErrorToFile3(temp);
    fprintf(stdout, "%s\n", s);
}

