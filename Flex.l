%{
    #include <stdlib.h>
    #include <stdbool.h>
    #include "bison.tab.h"
    void yyerror(char *);
%}


%% 
"if"         { return IF;       } 
"else"       { return ELSE;     } 
"for"        { return FOR;      } 
"do"		 { return DO;       }    
"while" 	 { return WHILE;    } 
"switch"     { return SWITCH;   } 
"case"       { return CASE;     } 
"default"    { return DEFAULT;  } 
"break"      { return BREAK;    } 
 
"="          { return ASSIGN;   }
"("          { return LPAREN;   }
")"          { return RPAREN;   }
"{"          { return LBRACE;   }
"}"          { return RBRACE;   }
":"          { return COLON;    }
","          { return COMMA;    }

"+"          { return PLUS;     }
"-"         { return MINUS;     }
"*"         { return MULTIPLY;  }
"/"         { return DIVIDE;    }


"return"    { return RETURN; }
"void"      { return VOID; }

"&&"		{ return OP_AND;    }
"||"		{ return OP_OR;     }
"!"			{ return OP_NOT;    }
"=="		{ return OP_EQ;     }
"!="		{ return OP_NOTEQ;  }

">="		{ return OP_GTE;    }
"<="		{ return OP_LTE;    }
">"			{ return OP_GT;     }
"<"			{ return OP_LT;     }


"int"		{return TYPE_INTEGER;   }
"float"		{return TYPE_FLOAT;     }   
"bool"      {return TYPE_BOOL;      }
"char"		{return TYPE_CHARACTER; }
"const"   	{return TYPE_CONSTANT;  }


[*+-/=%;~&|^(){}:]       {  return yytext[0];}


-?[0-9]+				 {  yylval.INTEGER  = atoi(yytext);     return NUM_INTEGER ;}

-?[0-9]+.[0-9]+          {  yylval.FLOAT    = atof(yytext);     return NUM_FLOATING;}

[a-zA-Z]+[_a-zA-Z0-9]*   {  yylval.STRING = yytext;              return IDENTIFIER ; }

'.' 					 { 	yylval.CHARACTER = yytext[1] ;      return CHAR_VALUE;  }

'true'                   {  yylval.BOOLEAN = true;              return BOOL;}

'false'                  {  yylval.BOOLEAN = false;             return BOOL;}





[ \t\n]+                    ;       /*whitespaces*/
"//".*                  	;       /*comment*/


%%

int yywrap(void) { return 1;}