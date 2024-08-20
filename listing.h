// Pete Coutros
// Project 3 - Interpreter
// 3/23/24
// CMSC 430 Compiler Theory and Design

// Added function to convert hexadecimal string to integers
// Added function to convert char to integer
// Added function to convert char to double

// This file contains the function prototypes for the functions that produce
// the compilation listing

enum ErrorCategories {LEXICAL, SYNTAX, GENERAL_SEMANTIC, DUPLICATE_IDENTIFIER,
	UNDECLARED};

void firstLine();
void nextLine();
int lastLine();
void appendError(ErrorCategories errorCategory, string message);
int hexToInt(char* str);
int charToInt(char* str);
double chartof(char* str);