// Pete Coutros
// Project 3 - Interpreter
// 4/14/24
// CMSC 430 Compiler Theory and Design

// This file contains the bodies of the evaluation functions. All functions were modified from the skeleton code to include missing operators/implementations
// A function was added to evaluate the fold production 

#include <string>
#include <cmath>
#include <cstring>

using namespace std;

#include "values.h"
#include "listing.h"

// Function to evaluate arithmetic 
double evaluateArithmetic(double left, Operators operator_, double right) {
	double result;
	switch (operator_) {
		case ADD:
			result = left + right;
			break;
		case MINUS:
			result = left - right;
			break;
		case MULTIPLY:
			result = left * right;
			break;
		case DIVIDE:
			result = left / right;
			break;
		case REMAINDER:
			result = fmod(left, right);
			break;
		case POWERTO:
			result = pow(left, right);
			break;
		case NEGATE:
			result = -1 * right;
		default:
			break;
	}
	return result;
}

// Function to evaluate condition
double evaluateLogical(double left, Operators operator_, double right) {
	double result;
	switch (operator_) {
		case AND:
			result = left && right;
			break;
		case OR:
			result = left || right;
			break;
		case NOT:
			result = ! right;
			break;
		default:
			break;
	}
	return result;
}

// Function to evaluate the relation
double evaluateRelational(double left, Operators operator_, double right) {
	double result;
	switch (operator_) {
		case LESS:
			result = left < right;
			break;
		case EQUALS:
			result = left == right;
			break;
		case LESSMORE:
			result = left != right;
			break;
		case MORE:
			result = left > right;
			break;
		case MOREEQ:
			result = left >= right;
			break;
		case LESSEQ:
			result = left <= right;
			break;
		default:
			break;
	}
	return result;
}

// Function to evaluate the fold based on direction, operator, and list input
// There is no validation checks for value entry, ie does NOT check if list[i] != 0 for division
double evaluateFold(Direction direction, Operators operator_, vector<double>& list) {
	double result;
	switch (operator_) {
		case ADD:
			result = 0;						// Initialize result to 0 for addition (0 + anything = anything)
			for (int i = 0; i < list.size(); i++) {
				result += list[i];
			}
			break;
		case MINUS:
			if (direction == L) {
				result = list[0];				// Initialize result to first item in list to begin subtracting from
				for (int i = 1; i < list.size(); i++) {		// Iterate starting at second item in list
					result -= list[i];
				}
			} else {
				result = list[list.size()-1];			// Initialize result to last item in list to begin subtracting from
				for (int i = list.size() - 2; i >= 0; i--) {	// Iterate starting at second to last item in list
					result = list[i] - result;		// Right associative
				}
			}
			break;
		case MULTIPLY:
			result = 1;						// Initialize result to 1 for multiplication (1 * anything = anything)
			for (int i = 0; i < list.size(); i++) {
				result *= list[i];
			}
			break;
		case DIVIDE:
			if (direction == L) {
				result = list[0];				// Initialize result to first item in list to begin dividing from
				for (int i = 1; i < list.size(); i++) {		// Iterate starting at second item in list
					result /= list[i];
				}
			} else {
				result = list[list.size()-1];			// Initialize result to last item in list to begin dividing from
				for (int i = list.size() - 2; i >= 0; i--) {	// Iterate starting at second to last item in list
					result = list[i] / result;		// Right associative 
				}
			}			
			break;
		default:
			break;
	}
	return result;
}