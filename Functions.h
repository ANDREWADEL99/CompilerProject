#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <string>
#include <iostream>
#include <fstream>
#include "symbolTable.h"

extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;
bool isForScope = false;


#define YYDEBUG 1

/* prototypes */
int yylex(void);
void yyerror(char *s);
void appendErrorToFile(std::string line);
void addText (std::string myTxt);
void appendLineToFile(std::string line);

typedef enum   {whileLabel,doLabel, forLabel, ifLabel, switchLabel}  labelType;
void createLabel(labelType type);
int getNextCaseLabel();
int getCurrentCaseLabel();
void deleteLabel();

struct label{
        labelType type;
        int labelsNames[20];
        int currentSwitchLabel = 0;
        int hasDefault = 0;
        dataTypeEnum switchType;
};
struct labelsController {
        int currentIndex = -1;
        label * labelBlocks[100];      
};
labelsController labels;
int argumentListIndex = 0;
int labelNumber = 0;


void yyerror(char *s) {
    std::string temp=s;
    temp+=" at: "+to_string(yylineno);
    appendErrorToFile(temp);
    fprintf(stdout, "%s\n", s);
}

#define LEN 256
void appendLineToFile(std::string line)
{
    std::ofstream file;
    file.open ("./output.txt", std::ios::out | std::ios::app );
    file << line << std::endl;
}

void appendErrorToFile(std::string line)
{
    std::ofstream file;
    file.open ("./error.txt", std::ios::out | std::ios::app );
    file << line << std::endl;
}
void createLabel(labelType type){
        labels.currentIndex++;
        labels.labelBlocks[labels.currentIndex] =  (label*) malloc(sizeof(label));
        labels.labelBlocks[labels.currentIndex]->type = type;
        
        if(type == labelType::forLabel){

                for(int i =0; i< 4;i++){
                        
                        labels.labelBlocks[labels.currentIndex]->labelsNames[i] = labelNumber; 
                        labelNumber++;
                }
        }else if(type == labelType::switchLabel){
                for(int i =0; i< 20;i++){
                        labels.labelBlocks[labels.currentIndex]->labelsNames[i] = labelNumber; 
                        labelNumber++;
                        
                }
        }
        else if(type == labelType::ifLabel){
                for(int i =0; i< 2;i++){
                        labels.labelBlocks[labels.currentIndex]->labelsNames[i] = labelNumber; 
                        labelNumber++;
                }
        }else if(type == labelType::whileLabel){
                for(int i =0; i< 2;i++){
                        labels.labelBlocks[labels.currentIndex]->labelsNames[i] = labelNumber; 
                        labelNumber++; 
                }
        }else{
                for(int i =0; i< 2;i++){
                        labels.labelBlocks[labels.currentIndex]->labelsNames[i] = labelNumber; 
                        labelNumber++; 
                }
        }
}
int getNextCaseLabel(){
        if(labels.labelBlocks[labels.currentIndex]->type !=  labelType::switchLabel)
                return -1;
     
        return labels.labelBlocks[labels.currentIndex]->labelsNames[++labels.labelBlocks[labels.currentIndex]->currentSwitchLabel];

}
int getCurrentCaseLabel(){
        if(labels.labelBlocks[labels.currentIndex]->type !=  labelType::switchLabel)
                return -1;
        return labels.labelBlocks[labels.currentIndex]->labelsNames[labels.labelBlocks[labels.currentIndex]->currentSwitchLabel];

}
void deleteLabel(){
        free(labels.labelBlocks[labels.currentIndex]);
        labels.labelBlocks[labels.currentIndex] = NULL;
        labels.currentIndex--;
        if(labels.currentIndex==-1)
            isForScope = false;
        
}