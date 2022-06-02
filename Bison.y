%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <string>
#include <iostream>
#include <fstream>
#include "symbolTable.h"
#include "Functions.h"


symbolTable symbolTableList[MAX_SCOPES];
dataTypeEnum varType;
bool isFunctionParam = false;
bool isBracketScope = false;
bool isClosedBracketScope = false;

bool isSwitchScope = false;
bool notInitialized = false;
int startLabel=0;
int endLabel = 1;
int paramList [5];
int paramListIndex = 0;
int argumentList [5];

dataTypeEnum functionDataType; 
dataTypeEnum switchDataType; 
%}

%union {
    int iValue;                 /* integer value */
    char sIndex;                /* symbol table index */
    char * stringValue;
    struct symbolTableEntry * entry;
};


%token <entry> STRING INTEGER
%token <entry> VARIDENTIFIER
%type <entry>  functionDeclaration
%type <entry>  constDeclaration
%type <entry>  varDeclaration
%type <entry>  variable
%type <entry>  lValue
%type <entry>  consValues
%type <entry>  expr
%type <entry> caseStmt
%token <entry> TRUEBOOL FALSEBOOL 
%token INT STR BOOL SWITCH CASE DEFAULT CONST  DO OR AND NOT FUNCTION
%token <entry> FUNCIDENTIFIER
%token WHILE IF FOR BREAK
 

%nonassoc VARFX 
%nonassoc IFX 
%nonassoc ELSE 
%nonassoc ';' 
%nonassoc '=' 
%left  EQ NE '>' '<' OR AND 
%left '+' '-' 
%left '*' '/' 
%nonassoc UMINUS NOT





%%
program:
        function                {       
                                        for(int j=0; j<totalNumberOfScopes; j++)
                                        {
                                                symbolTable symb= symbolTableList[j];
                                                symbolTableEntry* traverser;
                                                display_symbol_table(j,symb.symbolTable);
                                                for(int i=0; i < MAX_IDENTIFIERS; i++)
                                                {
                                                        traverser = symb.symbolTable[i];
                                                }
                                        }
                                        
                                }    
        ;

function:
        function  functionDeclaration         { }
        | function varDeclaration 
        | function constDeclaration 
        | /* NULL */
        ;
type:   INT                     {varType = dataTypeEnum::typeInt;}
        | STR                   {varType = dataTypeEnum::typeString;} 
        | BOOL                  {varType = dataTypeEnum::typeBool;}
        ;
   
functionParam:
        variable           {}
        | variable  {} ',' functionParam
        | ;
functionArgs: 
        expr                            {       
                                                if($1!=NULL){

                                                        argumentList[argumentListIndex] = $1->dataType;
                                                         std::string  stringToAdd = "pop r";
                                                         stringToAdd += to_string(argumentListIndex);  
                                                         appendLineToFile(stringToAdd);  
                                                        argumentListIndex++;
                                                }else{
                                                        argumentList[argumentListIndex] = -1;
                                                        argumentListIndex++;      
                                                }
                                        }        

        | expr                          {
                                                if($1!=NULL){

                                                        argumentList[argumentListIndex] = $1->dataType;
                                                        std::string  stringToAdd = "pop r";
                                                         stringToAdd += to_string(argumentListIndex);  
                                                         appendLineToFile(stringToAdd);  
                                                        argumentListIndex++;
                                                }else{
                                                        argumentList[argumentListIndex] = -1;
                                                        argumentListIndex++;      
                                                }
                                        } 
        ',' functionArgs
        | /* NULL */
        ;
varDeclaration:
         variable ';'                   {
                                              
                                                if($1 !=NULL){
                                                        $1->entryType = entryTypeEnum::isVariable;
                                                        $$=$1;

                                                }else{
                                                        $$=NULL;  
                                                }
                                                
                                                
                                        }         
        | variable '=' expr ';'         {

                                                if($1 !=NULL && $3 != NULL){
                                                        $1->entryType = entryTypeEnum::isVariable;
                                                        if($1->dataType != $3->dataType){
                                                                appendErrorToFile("Type mismatch at line "+ to_string(yylineno));
                                                                $$=NULL;
                                                        }else{
                                                                $1->isInitialized = true;
                                                                std::string  stringToAdd = "pop ";
                                                                stringToAdd += $1->lexeme;  
                                                                appendLineToFile(stringToAdd);       
                                                                $$=$1;    
                                                        }
                                                        
                                                }else{
                                                        $$=NULL;
                                                } 
                                               
                                        }
        ;
constDeclaration:
        CONST variable '='  expr  ';'   {
                                                if($4!=NULL){

                                                        $2->entryType = entryTypeEnum::isConstantVariable;
                                                        if($2->dataType != $4->dataType){
                                                                appendErrorToFile("Type mismatch at line "+ to_string(yylineno));
                                                        }else{
                                                                $2->isInitialized = true;     
                                                                std::string  stringToAdd = "pop ";
                                                                stringToAdd += $2->lexeme;  
                                                                appendLineToFile(stringToAdd);       
                                                                $$=$2;         
                                                        }
                                                }
                                               
                                               
                                        }
        ;
variable: 
        type VARIDENTIFIER              {
                                               
                                                $2 = insert(symbolTableList[currentScope].symbolTable,yylval.stringValue,varType);
                                                
                                                if(isFunctionParam == true){
                                                        $2->entryType = entryTypeEnum::isParameter;
                                                        paramList[paramListIndex] = varType;
                                                        std::string  stringToAdd = "mov r";
                                                        stringToAdd +=  to_string(paramListIndex);
                                                        stringToAdd += " , ";  
                                                        stringToAdd += $2->lexeme;
                                                        appendLineToFile(stringToAdd); 
                                                        paramListIndex++;
                                                        $2->isInitialized = true;
                                                }               
                                                $$ = $2;
                                                                                             
                                        }
        ;
functionDeclaration: 
        type FUNCTION  FUNCIDENTIFIER  {
                                                isFunctionParam=true;
                                                $3 = insert(symbolTableList[currentScope].symbolTable,yylval.stringValue,varType); 
                                                $3->entryType = entryTypeEnum::isFunction; 
                                                std::string temp = $3->lexeme;
                                                temp+=":";
                                                appendLineToFile(temp);    
                                                                                                                           
                                        }
        '('                             {       
                                                currentScope = createNewScope();
                                                isBracketScope = true;
                                        }
        functionParam ')'               {       
                                                int*temp = (int*) malloc(sizeof(int)*(paramListIndex+1));
                                                for(int i=0; i<paramListIndex; i++){
                                                        temp[i] = paramList[i];
                                                }
                                                $3->functionParametersList=temp;
                                                $3->functionsParametersNumber=paramListIndex;
                                                isFunctionParam=false;
                                                paramListIndex=0;
                                        }
        openScope                       {       
                                                functionDataType = $3->dataType;
                                                isBracketScope = false;
                                        }
        stmtList closeScope             {
                                           $$ = $3;
                                        };
/* regarding scope */
stmtBlock: 
        openScope stmtList closeScope
        ;
stmt:
          ';'                                 { }
        | expr ';'                            { }
        | whileStmt                           { }
        | doStmt                              { }
        | forStmt                             { }
        | breakStmt                           { }
        | ifStmt                              { }
        | stmtBlock                           { }
        | varDeclaration                      { }
        | constDeclaration                    { }
        | switchStmt                          { }
        ;

ifStmt: IF '(' expr ')'                         {       
                                                        createLabel(labelType::ifLabel);
                                                        std::string temp = "JNZ L";
                                                        temp+= to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                        appendLineToFile(temp);
                                                        temp = "JMP L";
                                                        temp+= to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                        appendLineToFile(temp);
                                                        temp = "L";
                                                        temp+= to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                        temp+=':';
                                                        appendLineToFile(temp);  
                                                }
        stmt ifContinue                         {
                                                        deleteLabel();
                                                }
        ;
ifContinue: 
        %prec IFX         {
                                                        /*TODO:CHECK BOOL EXPRESSION*/
                                                        std::string temp = "L";
                                                        temp+= to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                        temp+=':';
                                                        appendLineToFile(temp);
                                                }
        |
        ELSE            {
                                                        /*TODO:CHECK BOOL EXPRESSION*/
                                                        std::string temp = "L";
                                                        temp+= to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                        temp+=':';
                                                        appendLineToFile(temp);
                                                } 
        stmt      {/*TODO:CHECK BOOL EXPRESSION*/}

        ;

breakStmt:
        BREAK   ';'                             {
                                                        if(!isForScope && !isSwitchScope){
                                                               
                                                                appendErrorToFile("Break couldn't be called outside the scope of a loop/switch at line "+ to_string(yylineno)); 
                                                                        
                                                        }else{
                                                                std::string temp = "JMP L";
                                                                if(labels.labelBlocks[labels.currentIndex]->type == labelType::forLabel){
                                                                        temp += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[3]);
                                                                }else if(labels.labelBlocks[labels.currentIndex]->type == labelType::switchLabel){
                                                                        temp += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[19]);
                                                                }else{
                                                                         temp += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                                }
                                                                appendLineToFile(temp);
                                                        }
                                                }
        ;
switchStmt:
        SWITCH '(' expr ')' openScope   {
                                                
                                                if($3->entryType != entryTypeEnum::isVariable){
                                                        
                                                        appendErrorToFile("Switch must take a variable at line "+ to_string(yylineno)); 
                                                }
                                                
                                                createLabel(labelType::switchLabel);
                                               
                                                labels.labelBlocks[labels.currentIndex]->switchType = $3->dataType;
                                                isSwitchScope = true;
                                                switchDataType = $3->dataType;
                                                
                                        }
         caseStmts closeScope           {
                                                int caseNumer = getCurrentCaseLabel();
                                
                                                std::string stringToAdd = "L";
                                                stringToAdd+=to_string(caseNumer);
                                                stringToAdd+=":";
                                                appendLineToFile(stringToAdd);
                                                stringToAdd = "L";
                                                stringToAdd+=to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[19]);
                                                stringToAdd+=":";
                                                appendLineToFile(stringToAdd);
                                                deleteLabel();
                                                isSwitchScope = false;
                                        }
        ;
caseStmts:
        caseStmt caseStmts | caseStmt      
        ;
caseStmt:
        CASE                            { 
                                                int caseNumer = getCurrentCaseLabel();
                                
                                                std::string stringToAdd = "L";
                                                stringToAdd+=to_string(caseNumer);
                                                stringToAdd+=":";
                                                appendLineToFile(stringToAdd);
                                        }
        expr                            {
     
                                                if($3!=NULL &&$3->dataType != labels.labelBlocks[labels.currentIndex]->switchType){
                                                        appendErrorToFile("Type mismatch at line "+ to_string(yylineno)); 

                                                }else{

                                                int nextCaseNumber = getNextCaseLabel();
                                                
                                                std::string stringToAdd = "cmpEQ ";
                                                appendLineToFile(stringToAdd);
                                                stringToAdd = "JZ L";
                                                stringToAdd+= to_string(nextCaseNumber);
                                                appendLineToFile(stringToAdd);
                                                }
                                        
  
                                      }
                ':'               {
                                       
                                  }       
                stmtList          {
                                        
                                  }
        | DEFAULT                       {
                                                if(labels.labelBlocks[labels.currentIndex]->hasDefault==0){
                                                        std::string stringToAdd = "L";
                                                        int caseNumer = getCurrentCaseLabel();
                                                        stringToAdd+=to_string(caseNumer);
                                                        stringToAdd+=":";
                                                        appendLineToFile(stringToAdd);
                                                        labels.labelBlocks[labels.currentIndex]->hasDefault=1;
                                                }else{
                                                        appendErrorToFile("Switch can't have more than one default at line "+ to_string(yylineno)); 
                                                }
                                        }


        ':' stmtList          {}
        ;
whileStmt: WHILE '('                                            {    
                                                                        createLabel(labelType::whileLabel);
                                                                        currentScope = createNewScope();
                                                                        isBracketScope = true;
                                                                        std::string stringToAdd = "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                                        startLabel = labelNumber;
                                                                        stringToAdd += ": ";
                                                                        appendLineToFile(stringToAdd);  
                                                                }
           expr ')' openScope                                   {
                                                                        isForScope = true;
                                                                        isBracketScope = false;
                                                                        std::string stringToAdd = "JZ ";
                                                                        stringToAdd += "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                                        appendLineToFile(stringToAdd);
                                                                              
                                                                }
           stmtList closeScope                                  {
                                                                        std::string stringToAdd = "JMP ";
                                                                        stringToAdd += "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                                        appendLineToFile(stringToAdd);
                                                                        stringToAdd = "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                                        stringToAdd += ": ";
                                                                        appendLineToFile(stringToAdd);  
                                                                        deleteLabel();
                                                                              
                                                                }
        ;

forStmt:  FOR '('                                               {       
                                                                        createLabel(labelType::forLabel);
                                                                        
                                                                        currentScope = createNewScope();
                                                                        isBracketScope = true;
                                                                         
                                                                        
                                                                }
          loopExpression ')' openScope                          {
                                                                
                                                                        std::string temp ="L"+ to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[2]);
                                                                        temp+=":";
                                                                        appendLineToFile(temp); 
                                                                        isForScope = true;
                                                                        isBracketScope = false;   
                                                                        endLabel = labelNumber;
                                                                }
          stmtList closeScope                                   {       
                                                                        
                                                                        std::string stringToAdd = "JMP ";
                                                                        stringToAdd +="L"+to_string( labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                                        appendLineToFile(stringToAdd);
                                                                        std::string temp = "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[3]);
                                                                        temp+=":";
                                                                        appendLineToFile(temp);   
                                                                        deleteLabel();
                                                                }
        ;
doStmt: 
        DO openScope                                            {       createLabel(labelType::doLabel);
                                                                        isClosedBracketScope = true;
                                                                        isForScope = true;
                                                                        startLabel = labelNumber;
                                                                        std::string stringToAdd = "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                                        stringToAdd += ": ";
                                                                        appendLineToFile(stringToAdd);            
                                                                }
        stmtList closeScope                                     {
                                                                        isClosedBracketScope = false;        
                                                                        
                                                                }
        WHILE '(' expr ')' ';'                                  {      
                                                                        std::string stringToAdd = "JNZ ";
                                                                        stringToAdd += "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                                        appendLineToFile(stringToAdd);  

                                                                        stringToAdd = "L";
                                                                        stringToAdd += to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                                        stringToAdd += ": ";
                                                                        appendLineToFile(stringToAdd);  
                                                                        deleteLabel();          
                                                                }
        ;
loopExpression: 
        INT VARIDENTIFIER               {
                                                $2 = insert(symbolTableList[currentScope].symbolTable,yylval.stringValue,dataTypeEnum::typeInt);
                                                $2->isInitialized = true;
                                                
                                                
                                       }
        '=' expr                        {
                                                std::string stringToAdd = "pop ";
                                                stringToAdd += $2->lexeme;
                                                appendLineToFile(stringToAdd); 
                                                // stringToAdd = "JMP L";
                                                // stringToAdd += to_string(labelNumber+1);
                                                // appendLineToFile(stringToAdd); 
                                                std::string temp = "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                temp+=":";
                                                appendLineToFile(temp);  

                                        }
        ';' expr                        {
                                                
                                                std::string stringToAdd = "JNZ ";
                                                stringToAdd +="L"+ to_string( labels.labelBlocks[labels.currentIndex]->labelsNames[2]);
                                                appendLineToFile(stringToAdd); 
                                                stringToAdd = "JMP ";
                                                stringToAdd +="L"+ to_string( labels.labelBlocks[labels.currentIndex]->labelsNames[3]);
                                                appendLineToFile(stringToAdd); 
                                                std::string temp = "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                temp+=":";
                                                appendLineToFile(temp);  
                                                
                                        } 

        ';' expr                        {
                                                std::string stringToAdd = "JMP ";
                                                stringToAdd += "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                appendLineToFile(stringToAdd);
                                                
                                        }
        |  VARIDENTIFIER                {
                                                $1 = isAvailable(yylval.stringValue);
                                                if($1==NULL){
                                                        std::string temp = yylval.stringValue;
                                                        appendErrorToFile("Variable"+temp+ " not declared, at line "+ to_string(yylineno));
          
                                                }else if($1->entryType != entryTypeEnum::isVariable){
                                                       std::string temp = yylval.stringValue;
                                                        appendErrorToFile("Variable"+temp+ " is const, cant be assigned, at line "+ to_string(yylineno));
                                                }else{
                                                          $1->isInitialized = true;
                                                }
                                        }
        '=' expr                        {
                                                std::string stringToAdd = "pop ";
                                                stringToAdd += $1->lexeme;
                                                appendLineToFile(stringToAdd); 
                                                // stringToAdd = "JMP L";
                                                // stringToAdd += to_string(labelNumber+1);
                                                // appendLineToFile(stringToAdd); 
                                                std::string temp = "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                temp+=":";
                                                appendLineToFile(temp);  
                                        }


        
        ';' expr                        {
                
                                                
                                                std::string stringToAdd = "JNZ ";
                                                stringToAdd +="L"+ to_string( labels.labelBlocks[labels.currentIndex]->labelsNames[2]);
                                                appendLineToFile(stringToAdd); 
                                                stringToAdd = "JMP ";
                                                stringToAdd +="L"+ to_string( labels.labelBlocks[labels.currentIndex]->labelsNames[3]);
                                                appendLineToFile(stringToAdd); 
                                                std::string temp = "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[1]);
                                                temp+=":";
                                                appendLineToFile(temp);  
                                                
                                        } 
        

        ';'  expr                       {
                                                std::string stringToAdd = "JMP ";
                                                stringToAdd += "L"+to_string(labels.labelBlocks[labels.currentIndex]->labelsNames[0]);
                                                appendLineToFile(stringToAdd);
                                        }
        ; 
stmtList:
        stmt                   { }
        | stmtList stmt        { }
        ;
expr:
        lValue '=' expr                         {       
                                                        printf("Ana hena");
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != $3->dataType){
                                                                        appendErrorToFile("Type mismatch at line "+ to_string(yylineno));
                                                                }else if($1->entryType != entryTypeEnum::isVariable){
                                                                                std::string temp = yylval.stringValue;
                                                                                appendErrorToFile("Variable"+temp+ " is const, cant be assigned, at line "+ to_string(yylineno));
                                                                }else {
                                                                        $1->isInitialized = true;
                                                                        std::string stringToAdd = "pop ";
                                                                        stringToAdd += $1->lexeme;
                                                                        appendLineToFile(stringToAdd);                                                                      
                                                                }

                                                        }
                                                        
                                                        $$=$1;
                                                        
                                                }
        | lValue                                {       
                                                        if($1!=NULL){

                                                                if(!$1->isInitialized){
                                                                        std::string temp= $1->lexeme; 
                                                                        appendErrorToFile("Variable"+temp+ " not initialized at line "+ to_string(yylineno));
                                                                }else{
                                                                        std::string  stringToAdd = "push ";
                                                                        stringToAdd += $1->lexeme;
                                                                        appendLineToFile(stringToAdd); 
                                                                }
                                                        }
                                                        //notInitialized=false;
                                                        $$=$1;
                                                }
        | consValues                            {
                                                        $$=$1;
                                                }

        | '-' expr %prec UMINUS                 {
                                                        if($2!=NULL){
                                                                if($2->dataType != dataTypeEnum::typeInt){
                                                                        appendLineToFile("Can't - on a non integer value");
                                                                
                                                                }
                                                        }else{
                                                                std::string  stringToAdd = "neg ";
                                                                appendLineToFile(stringToAdd);  
                                                                $2->lexeme = '-'+$2->lexeme;

                                                        }

                                                        $$=$2;    
                                                }
        | FUNCIDENTIFIER                        { 

                                                        $1 = isAvailable(yylval.stringValue);
                                                        if($1==NULL)
                                                        {       std::string temp = yylval.stringValue;
                                                                std::string error = "Function" + temp +" not defined at line " + to_string(yylineno);
                                                                appendErrorToFile(error);
                                                                
                                                        }
                                                           
                                                                     
                                                }
         '(' functionArgs ')'                   {
                                                        if($1->functionsParametersNumber!=argumentListIndex){
                                                                
                                                                std::string error = "Expected" + to_string($1->functionsParametersNumber) +"arguments, but found" +to_string(argumentListIndex)+ "at line" + to_string(yylineno);
                                                                appendErrorToFile(error);
                                                              
                                                                $$=NULL;
                                                        }else{
                                                                bool flag = false;
                                                                for(int i=0; i<argumentListIndex; i++){
                                                                        if($1->functionParametersList[i] != argumentList[i]){
                                                                                appendErrorToFile("Calling arguments type are not matching at line "+ to_string(yylineno));
                                                                                flag = true;
                                                                                break;
                                                                                $$=NULL;
                                                                        }
                                                                }
                                                                if(!flag){
                                                                        $$=$1; 
                                                                }
                                                        }   
                                                        std::string  stringToAdd = "call ";
                                                         stringToAdd += $1->lexeme;  
                                                         appendLineToFile(stringToAdd);  
                                                        argumentListIndex=0;
                                                
                                                }
        | expr '+' expr                         {
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType==dataTypeEnum::typeBool || $3->dataType==dataTypeEnum::typeBool){
                                                                        
                                                                        appendErrorToFile("Failed to add bool expression at line "+ to_string(yylineno));
                                                                        $$=NULL;
                                                                }
                                                                else if($1->dataType != $3->dataType){
                                                                        appendErrorToFile("Type mismatch at line "+ to_string(yylineno));
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string  stringToAdd = "add ";
                                                                        appendLineToFile(stringToAdd);  
                                                                        $$ = $1;
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                       
                                                }
        | expr '-' expr                         {        
                                                        
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeInt || $3->dataType != dataTypeEnum:: typeInt){
                                                                        appendErrorToFile("Failed to subtract non integer variables at line "+ to_string(yylineno));
                                                                        $$=NULL;
                                                                }
                                                                else{
                                                                        std::string  stringToAdd = "sub ";
                                                                        appendLineToFile(stringToAdd); 
                                                                        stringToAdd = "neg ";
                                                                        appendLineToFile(stringToAdd); 
                                                                        $$=$1;
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
        | expr '*' expr                         {
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeInt || $3->dataType != dataTypeEnum:: typeInt){
                                                                          
                                                                          appendErrorToFile("Failed to multiply non integer variables at line "+ to_string(yylineno));
                                                                          $$=NULL;
                                                                }else{
                                                                        std::string  stringToAdd = "mul ";
                                                                        appendLineToFile(stringToAdd); 
                                                                        $$=$1;
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
        | expr '/' expr                         {
                                                         if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeInt || $3->dataType != dataTypeEnum:: typeInt){
                                                                    
                                                                        appendErrorToFile("Failed to divide non integer variables at line "+ to_string(yylineno));    
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string  stringToAdd = "div ";
                                                                        appendLineToFile(stringToAdd); 
                                                                        $$=$1;
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                        
                                                }
        | expr '<' expr                         {
                                                         if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeInt || $3->dataType != dataTypeEnum:: typeInt){
                                                                        
                                                                        appendErrorToFile("Failed to compare non integer variables at line "+ to_string(yylineno));
                                                                        
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string temp = "temp";
                                                                        int n = temp.length();
                                                                        char charArray[n+1];
                                                                        strcpy(charArray, temp.c_str());
                                                                        $$ = createEntry(charArray, dataTypeEnum::typeBool);
                                                                        std::string  stringToAdd = "cmpLT ";
                                                                        appendLineToFile(stringToAdd); 
                                                                }
                                                        }else{
                                                             $$=NULL;    
                                                        }
                                                       
                                                }
        | expr '>' expr                         {
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeInt || $3->dataType != dataTypeEnum::typeInt){
                                                                       
                                                                        appendErrorToFile("Failed to compare non integer variables at line "+ to_string(yylineno));
                                                                        
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string temp = "temp";
                                                                        int n = temp.length();
                                                                        char charArray[n+1];
                                                                        strcpy(charArray, temp.c_str());
                                                                        $$ = createEntry(charArray, dataTypeEnum::typeBool);
                                                                        std::string  stringToAdd = "cmpGT ";
                                                                        appendLineToFile(stringToAdd); 
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
    
                                                
        | expr OR expr                          {
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeBool || $3->dataType != dataTypeEnum:: typeBool){
                                                                        appendErrorToFile("Failed to OR non boolean variables at line "+ to_string(yylineno));
                                                                        
                                                                          $$=NULL;
                                                                }else{  
                                                                        std::string temp = "temp";
                                                                        int n = temp.length();
                                                                        char charArray[n+1];
                                                                        strcpy(charArray, temp.c_str());
                                                                        $$ = createEntry(charArray, dataTypeEnum::typeBool);
                                                                        std::string  stringToAdd = "or ";
                                                                        appendLineToFile(stringToAdd); 
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
        | expr AND expr                         {
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != dataTypeEnum:: typeBool || $3->dataType != dataTypeEnum:: typeBool){
                                                                        appendErrorToFile("Failed to and non boolean variables at line "+ to_string(yylineno));
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string temp = "temp";
                                                                        int n = temp.length();
                                                                        char charArray[n+1];
                                                                        strcpy(charArray, temp.c_str());
                                                                        $$ = createEntry(charArray, dataTypeEnum::typeBool);
                                                                        std::string  stringToAdd = "and ";
                                                                        appendLineToFile(stringToAdd);
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
        | NOT expr                              {
                                                        if($2!=NULL){
                                                                if($2->dataType != dataTypeEnum:: typeBool){
                                                                        
                                                                        appendErrorToFile("Failed to Not non boolean variables at line "+ to_string(yylineno));
                                                                        
                                                                        $$=NULL;
                                                                }else{
                                                                        $2->dataType = dataTypeEnum::typeBool;
                                                                        $$=$2; 
                                                                        std::string  stringToAdd = "not ";
                                                                        appendLineToFile(stringToAdd); 
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
        
        | expr NE expr                          {
                                                       if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != $3->dataType){
                                                                        appendErrorToFile("Failed to compare variables from different types at line "+ to_string(yylineno));
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string temp = "temp";
                                                                        int n = temp.length();
                                                                        char charArray[n+1];
                                                                        strcpy(charArray, temp.c_str());
                                                                        $$ = createEntry(charArray, dataTypeEnum::typeBool);
                                                                        std::string  stringToAdd = "cmpNE ";
                                                                        appendLineToFile(stringToAdd);
                                                                }
                                                        }else{
                                                                $$=NULL;
                                                        }
                                                }
        | expr EQ expr                          {
                                                        if($1!=NULL && $3!=NULL){
                                                                if($1->dataType != $3->dataType){
                                                                        appendErrorToFile("Failed to compare variables from different types at line "+ to_string(yylineno)); 
                                                                        
                                                                        $$=NULL;
                                                                }else{
                                                                        std::string temp = "temp";
                                                                        int n = temp.length();
                                                                        char charArray[n+1];
                                                                        strcpy(charArray, temp.c_str());
                                                                        $$ = createEntry(charArray, dataTypeEnum::typeBool);
                                                                        std::string  stringToAdd = "cmpEQ ";
                                                                        appendLineToFile(stringToAdd);
                                                                }
                                                        }else{
                                                                $$=NULL;   
                                                        }
                                                      
                                                }
        | '(' expr ')'                          {$$=$2;}
        ;
lValue: VARIDENTIFIER           {  
                                        $1 = isAvailable(yylval.stringValue);
                                        if($1==NULL){
                                                
                                                std::string temp = yylval.stringValue;
                                                appendErrorToFile("Variable "+temp+" not declared in scope at line "+ to_string(yylineno)); 
                                                                        
                                                $$=NULL;
                                        }
                                        else
                                        {$$ = $1;}
                                };
                                
consValues: 
        INTEGER                 { 

                                        $1 = createEntry(yylval.stringValue, dataTypeEnum::typeInt);
                                        $1->entryType = entryTypeEnum::isConstant;
                                        $$=$1;
                                        std::string stringToAdd = "push ";
                                        stringToAdd += yylval.stringValue;
                                        appendLineToFile(stringToAdd);
                                }
        | STRING                {
                                        $1 = createEntry(yylval.stringValue, dataTypeEnum::typeString);
                                        $1->entryType = entryTypeEnum::isConstant;
                                        $$=$1;
                                        std::string stringToAdd = "push ";
                                        stringToAdd += yylval.stringValue ;
                                        appendLineToFile(stringToAdd);
                                }
        | FALSEBOOL             {
                                        $1 = createEntry(yylval.stringValue, dataTypeEnum::typeBool);
                                        $1->entryType = entryTypeEnum::isConstant;
                                        $$=$1;
                                        std::string stringToAdd = "push 0";
                                        appendLineToFile(stringToAdd);
                                }
        | TRUEBOOL              {
                                        $1 = createEntry(yylval.stringValue, dataTypeEnum::typeBool);
                                        $1->entryType = entryTypeEnum::isConstant;
                                        $$=$1;
                                        std::string stringToAdd = "push 1";
                                        appendLineToFile(stringToAdd);
                                }  
        ;


openScope: '{'                  {
                                       
                                        if(!isBracketScope){
                                                currentScope = createNewScope();
                                        }
                                      
                                };       
closeScope: '}'                 {
                                        if(!isClosedBracketScope){
                                             currentScope = exitScope();   
                                        }
                                        
                                };
%%

int main (int argc, char *argv[]){
	// parsing
        std::ofstream file1;
        file1.open ("./error.txt", std::ios::out);
        file1<<"";
        std::ofstream file2;
        file2.open ("./output.txt", std::ios::out);
        file2<<"";
        symbolTableList[0].symbolTable = createTable();
        symbolTableList[0].parent = -1;
	yyin = fopen(argv[1], "r");

        if(!yyparse())
		printf("\nPARSER COMPLETE\n");
	else
		printf("\nPARSER FAILED!\n");
	fclose(yyin);
}