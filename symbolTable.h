
#pragma once

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <iostream>
#include <fstream>

using namespace std;
int yyerror(const char *msg);



#define MAX_IDENTIFIERS 100
#define MAX_SCOPES 10

// Variables related to scope
int tableIndex = 0;
int currentScope = 0;
int totalNumberOfScopes = 1;

typedef enum  {typeInt, typeString, typeBool, typeVoid} dataTypeEnum;
typedef enum   {isFunction, isParameter, isConstantVariable, isVariable, isConstant}  entryTypeEnum;
struct symbolTableEntry
{
	char* lexeme;
	dataTypeEnum dataType;
	entryTypeEnum entryType;
	struct symbolTableEntry*next;
	bool isInitialized;
	bool isUsed;
    //Extra Function Parameters
    int* functionParametersList;
    int functionsParametersNumber;
};


struct symbolTable
{
	symbolTableEntry** symbolTable;
	int parent;
};

extern symbolTable symbolTableList[MAX_SCOPES];

/* Create a new hash_table. */
symbolTableEntry** createTable()
{
	symbolTableEntry** ptr = NULL; // declare a pointer

	/* Allocate memory for a hashtable array of size HASH_TABLE_SIZE */
	if( ( ptr = (symbolTableEntry**) malloc( sizeof( symbolTableEntry* ) * MAX_IDENTIFIERS ) ) == NULL )
    	return NULL;

	int i;

	// Intitialise all entries as NUscopeLL
    for( i = 0; i < MAX_IDENTIFIERS; i++ )
	{
		ptr[i] = NULL;
	}

	return ptr;
}

void appendErrorToFile2(std::string line)
{
    std::ofstream file;
    file.open ("C:/Users/AndrewTawdros/Desktop/4th Year/Second Term/Compilers/Project/Team17/symbol", std::ios::out | std::ios::app );
    file << line << std::endl;
}
////////////////////////////////Scope Handling//////////////////////////////////
int createNewScope()
{
	tableIndex++;
	totalNumberOfScopes++;
	symbolTableList[tableIndex].symbolTable = createTable();
	symbolTableList[tableIndex].parent = currentScope;

	return tableIndex;
}

int exitScope()
{
	return symbolTableList[currentScope].parent;
}

///////////////////////////////Operations///////////////////////////////////////
int jenkinsHash(char *lexeme)
{
	size_t i;
	int hashvalue = 0;
    int index;

    //Looping on the lexeme
    //Calculate the hash value
	for (i = 0; i < strlen(lexeme); i++ ) {
        hashvalue += lexeme[i];
        hashvalue += ( hashvalue << 10 );
        hashvalue ^= ( hashvalue >> 6 );
    }
	hashvalue += ( hashvalue << 3 );
	hashvalue ^= ( hashvalue >> 11 );
    hashvalue += ( hashvalue << 15 );

    // Calulating the index of the hashedValue to fit it in the table
    //TODO: MASR3
	
    index = (hashvalue% MAX_IDENTIFIERS + MAX_IDENTIFIERS) % MAX_IDENTIFIERS;   
	return index;
}



symbolTableEntry *createEntry( char *lexeme, dataTypeEnum dataType )
{
	symbolTableEntry *newEntry;

	//Allocate space for newEntry
	if((newEntry = (symbolTableEntry*) malloc(sizeof(symbolTableEntry))) == NULL) {
		return NULL;
	}

	//Copy lexeme to newEntry location using strdup
	if( (newEntry->lexeme = strdup(lexeme)) == NULL) {
		return NULL;
	}

	newEntry->next = NULL;
	newEntry->functionParametersList = NULL;
	newEntry->dataType = dataType;
	newEntry->functionsParametersNumber = 0;
	newEntry->entryType = isVariable;
	newEntry->isUsed = false;
	newEntry->isInitialized = false;

	return newEntry;
}

symbolTableEntry* search(symbolTableEntry** symbolTable, char* lexeme)
{
	int idx = 0;
	symbolTableEntry* myEntry;

    //Use the hashing function to get my index and get the entry
	idx = jenkinsHash( lexeme );
	myEntry = symbolTable[idx];

    //Checking for myEntry and handling the collisions
	while( myEntry != NULL && strcmp( lexeme, myEntry->lexeme ) != 0 )
	{
		myEntry = myEntry->next;
	}


	if(myEntry == NULL){
        return NULL;
    }
	else {
        return myEntry;
    }
		
}

//isAvailable is a function that returns the entry of the lexeme if it exists in the symbol table (is_Available)
symbolTableEntry* isAvailable(char* lexeme)
{
	//Start with my scope
	int idx = currentScope;
	symbolTableEntry* temp = NULL;

	//As long as I didn't reach the root continue
	while(idx != -1)
	{
		//Search for the lexeme in the current symbol table
		temp = search(symbolTableList[idx].symbolTable, lexeme);

		//If found return
		if(temp != NULL){
			temp->isUsed = true;
			return temp;
		}

		//Get the parent scope
		idx = symbolTableList[idx].parent;
	}

	return temp;
}


symbolTableEntry* insert(symbolTableEntry** symbolTable, char* lexeme, dataTypeEnum dataType)
{
	symbolTableEntry* temp = search(symbolTable, lexeme);

	//Check if the lexeme already have an entry, then return null (ERROR)
	if( temp != NULL)
	{
		printf("ERROR: Redeclared Variable %s\n", lexeme);
		std::string temp = lexeme;
		appendErrorToFile2("Redeclared Variable +" + temp);

		return NULL;
	}
	
	int idx;
	symbolTableEntry* newEntry = NULL;
	symbolTableEntry* head = NULL;

    // Get the index for this lexeme based on the jenkinsHash function
	idx = jenkinsHash(lexeme);
	
	
    //Error handling for createEntry
    newEntry = createEntry(lexeme, dataType);
	if(newEntry == NULL)
	{
		printf("ERROR: Couldn't create a new entry in the hashed table\n");

		exit(1);
	}else{
	
	}

    //Inserting my new entry in the hashtable and handling collisions
	head = symbolTable[idx];
	if(head == NULL)
	{
		symbolTable[idx] = newEntry;
	}
	else
	{
		newEntry->next = symbolTable[idx];
		symbolTable[idx] = newEntry;
	}

	return symbolTable[idx];
}


void print_dashes(int n)
{
  printf("\n");

	int i;
	for(i=0; i< n; i++)
	printf("=");
	printf("\n");
}



void appendSymbolToFile(int symbolTable,std::string line)
{
    std::ofstream file;
    file.open ("C:/Users/AndrewTawdros/Desktop/4th Year/Second Term/Compilers/Project/Team17/symbol"+to_string(symbolTable)+".txt", std::ios::out | std::ios::app );
    file << line << std::endl;
}

// Traverse the myhash table and print all the entries
void display_symbol_table(int symbolTable, symbolTableEntry** hash_table_ptr)
{
	
	symbolTableEntry* traverser;

	print_dashes(100);

 	printf(" %-20s %-20s %-20s %-20s\n","lexeme","dataType","entryType","parameterList");

	print_dashes(100);
	std::ofstream file;
    file.open ("C:/Users/AndrewTawdros/Desktop/4th Year/Second Term/Compilers/Project/Team17/symbol"+to_string(symbolTable)+".txt", std::ios::out);
    file << "";
	for(int i=0; i < MAX_IDENTIFIERS; i++)
	{
		// printf("In loop\n");
		traverser = hash_table_ptr[i];
		while( traverser != NULL)
		{	
			std::string toLog = traverser->lexeme;
			toLog+= " ";
			toLog+= to_string(traverser->dataType);
			toLog+= " ";
			toLog+= to_string(traverser->entryType);
			toLog+= " ";
			
			printf(" %-20s %-20d %-20d", traverser->lexeme, traverser->dataType, traverser->entryType);
			if(traverser->functionsParametersNumber!=0){
				for(int i=0; i<traverser->functionsParametersNumber; i++){
					toLog+= to_string(traverser->functionParametersList[i]);
					toLog+=",";
					printf("%-5d",traverser->functionParametersList[i]);
				}
			}
			appendSymbolToFile(symbolTable,toLog);
			printf("\n");
			traverser = traverser->next;
		}
	}

	print_dashes(100);

}




