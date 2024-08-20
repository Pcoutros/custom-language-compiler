// Pete Coutros
// Project 3 - Interpreter
// 4/14/24
// CMSC 430 Compiler Theory and Design

// This file contains type definitions and the function
// definitions for the evaluation functions

typedef char* CharPtr;

enum Direction {L, R};	//ADDED by PETE COUTROS

enum Operators {ADD, MINUS, MULTIPLY, DIVIDE, REMAINDER, POWERTO, NEGATE, AND, OR, NOT, LESS,
		EQUALS, LESSMORE, MORE, MOREEQ, LESSEQ};

double evaluateArithmetic(double left, Operators operator_, double right);
double evaluateRelational(double left, Operators operator_, double right);
double evaluateLogical(double left, Operators operator_, double right);
double evaluateFold(Direction direction, Operators operator_, vector<double>& list);	//ADDED by PETE COUTROS
