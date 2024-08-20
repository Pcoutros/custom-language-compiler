// Pete Coutros
// Project 3 - Interpreter
// 3/23/24
// CMSC 430 Compiler Theory and Design

// MODIFIED BY PETE COUTROS - modifications are indicated by comments above the code

// Code from listing.cc from Project2 added here

// This file contains the bodies of the functions that produces the compilation listing

// Functions were added to convert from hex to int and char to int

#include <cstdio>
#include <string>
#include <queue>
#include <cstring>
#include <math.h>

using namespace std;

#include "listing.h"

static int lineNumber;
static string error = "";
static int totalErrors = 0;

//Initialize variables to differentiate error types - ADDED by PETE COUTROS
static int lexicalErrors = 0;
static int syntaxErrors = 0;
static int semanticErrors = 0;

//Initialize queue to store multiple errors on one line - ADDED by PETE COUTROS
static queue<string> qErrors;

static void displayErrors();

void firstLine()
{
	lineNumber = 1;
	printf("\n%4d  ",lineNumber);
}

void nextLine()
{
	displayErrors();
	lineNumber++;
	printf("%4d  ",lineNumber);
}

int lastLine()
{
	printf("\r");
	displayErrors();
	printf("     \n");
	
	//Total errors are made up from lexical, syntax, and semantic - ADDED by PETE COUTROS
	int TotalErrors = lexicalErrors + syntaxErrors + semanticErrors;

	//If there are errors display the type and count - ADDED by PETE COUTROS
	if (totalErrors > 0) 
	{
		printf("Lexical Errors %d\n", lexicalErrors);
		printf("Syntax Errors %d\n", syntaxErrors);
		printf("Semantic Errors %d\n", semanticErrors);
	}
	//Otherwise compilation was successful - ADDED by PETE COUTROS
	else
		printf("Compiled Successfully\n\n");
	return totalErrors;
}
    
void appendError(ErrorCategories errorCategory, string message)
{
	string messages[] = { "Lexical Error, Invalid Character ", "",
		"Semantic Error, ", "Semantic Error, Duplicate ",
		"Semantic Error, Undeclared " };

	error = messages[errorCategory] + message;

	//Add errors to the queue - ADDED by PETE COUTROS
	qErrors.push(error);

	totalErrors++;

	//Check the type of error and increment accordingly - ADDED by PETE COUTROS
	if (error == messages[LEXICAL] + message) {
		lexicalErrors++;
	} else if (error == messages[SYNTAX] + message) {
		syntaxErrors++;
	} else if (error == messages[GENERAL_SEMANTIC] + message || error == messages[DUPLICATE_IDENTIFIER] + message || error == messages[UNDECLARED] + message) {
		semanticErrors++;
	}
	
}

void displayErrors()
{
	//Go through queue and print errors, remove from queue after printing - ADDED by PETE COUTROS
	while (!qErrors.empty()) {
		printf("%s\n", qErrors.front().c_str());
		qErrors.pop();
	}
}

// ADDED by PETE COUTROS 
// Function that converts hexadecimal strings to integers
int hexToInt(char* str)
{
	int result = 0;		// Initialize variable to store the result
	int strInt = 0;		// Initialize variable to hold the integer representation of the cstr
	
	// To get the exponent needed to raise 16 to, we need to subtract the string length by 2
	// once to remove the leading # and the second time so that exponent ends at 0 and not 1			
	int exponent = strlen(str) -2;			

	// Loop over cstr starting at index 1 to skip leading #
	for (int i = 1; str[i] != '\0'; i++) {

		// Determine if a-fA-F is present and assign correct int value, otherwise it will use ASCII value
		switch (str[i]) {
			case 'a':
			case 'A':
				strInt = 10;
				break;
			case 'b':
			case 'B':
				strInt = 11;
				break;
			case 'c':
			case 'C':
				strInt = 12;
				break;
			case 'd':
			case 'D':
				strInt = 13;
				break;
			case 'e':
			case 'E':
				strInt = 14;
				break;
			case 'f':
			case 'F':
				strInt = 15;
				break;
			default:
				// if not a-fA-F then it is valid integer so convert cstr to int using "- '0'"
				strInt = str[i] - '0';		
		}

		// Hex is converted by taking the int value and multiplying by 16 ^ exponent
		// Where exponent depends on the index within the cstr
		result += (strInt) * pow(16, exponent);

		exponent--;		// Decrement exponent for next int in cstr
	}
	
	return result;
}

// ADDED by PETE COUTROS
// Function to convert character to int using ASCII values. Characters include ordinary an escape characters
int charToInt(char* str)
{
	int result = 0;		// Initialize variable to store result
	
	// Look at the second character of the cstr as the first is an '
	switch (str[1]) {

		// If second character is \ then we are dealing with an escape character 	
		case '\\':
			switch(str[2]) {
				case 'b':
					result = 8;	// ASCII for Backspace is 8
					break;
				case 't':
					result = 9;	// ASCII for Horizontal Tab is 9
					break;
				case 'n':
					result = 10;	// ASCII for Line Feed is 10
					break;
				case 'f':
					result = 12;	// ASCII for Form Feed is 12
					break;
				case 'r':
					result = 13;	// ASCII for Carriage Return is 13
					break;
				}
			break;
		
		// Otherwise character is an ordinary character and we just take regular ASCII value
		default:
			result = str[1];
	}
	
	return result;
}

// ADDED by PETE COUTROS
// Function to convert character to double using ASCII values. Characters include ordinary an escape characters. UNUSED FUNCTION
// as the quotes are stripped off when scanning so the charToInt function cannot be used.
/*double chartof(char* str)
{
	int result = 0;		// Initialize variable to store result
	
	// Look at the first character of the cstr
	switch (str[0]) {

		// If first character is \ then we are dealing with an escape character 	
		case '\\':
			switch(str[1]) {
				case 'b':
					result = 8;	// ASCII for Backspace is 8
					break;
				case 't':
					result = 9;	// ASCII for Horizontal Tab is 9
					break;
				case 'n':
					result = 10;	// ASCII for Line Feed is 10
					break;
				case 'f':
					result = 12;	// ASCII for Form Feed is 12
					break;
				case 'r':
					result = 13;	// ASCII for Carriage Return is 13
					break;
				}
			break;
		
		// Otherwise character is an ordinary character and we just take regular ASCII value
		default:
			result = str[0];
	}
	
	return result;
}
*/