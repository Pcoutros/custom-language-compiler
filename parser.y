/* Pete Coutros
   Project 3 - Interpreter
   3/23/24
   CMSC 430 Compiler Theory and Design

   Tokens from project 1 "tokens.h" file added in the definitions section.
   Grammars expanded on to include all syntactic additions/changes in the requirements.
   Error recovery added to grammars per the requirements.

   Code from Project2 parser.y added here

   Project 3 Parser with semantic actions for the interpreter

   Productions modified to include proper semantic action
   Comments were not included for semantic actions as it would clutter up the code
   Token and Type definitions were modified to include missing ones from skeleton
   Global array added to store parameters

*/

%{

#include <iostream>
#include <cmath>
#include <string>
#include <vector>
#include <map>

using namespace std;

#include "values.h"
#include "listing.h"
#include "symbols.h"

int yylex();
void yyerror(const char* message);
double extract_element(CharPtr list_name, double subscript);

Symbols<double> scalars;
Symbols<vector<double>*> lists;
double result;

double *param_array;			// Initialize the global array to store parameters of the function
int param_array_index = 1;		// Skip the first index that is 0 due to trying to store ./compile

vector<double>* listPtr;		// Initialize a ptr to the list

%}

%define parse.error verbose

%union {
	CharPtr iden;
	Operators oper;
	Direction direction;		
	double value;
	vector<double>* list;
}

%token <iden> IDENTIFIER

%token <value> INT_LITERAL CHAR_LITERAL REAL_LITERAL

%token <oper> ADDOP MULOP ANDOP RELOP OROP NOTOP REMOP EXPOP NEGOP

%token <direction> LEFT RIGHT		

%token ARROW

%token BEGIN_ CASE CHARACTER ELSE END ENDSWITCH FUNCTION INTEGER IS LIST OF OTHERS
	RETURNS SWITCH WHEN ELSIF ENDFOLD ENDIF FOLD IF REAL THEN

%type <value> body statement_ statement cases case expression term secondary primary
	 condition relation_tertiary relation_secondary relation elsif elsifs 

%type <list> list expressions list_choice

%type <direction> direction	
	
%type <oper> operator			


%%

function:	
	function_header optional_variables body {result = $3;} ;
	
function_header:	
	FUNCTION IDENTIFIER optional_parameters RETURNS type ';' |
	error ';' ;

optional_parameters:
	parameters | 
	%empty;

parameters:
	parameters ',' parameter |
	parameter ;

parameter:
	IDENTIFIER ':' type {scalars.insert($1, param_array[param_array_index]); param_array_index++;};

type:
	INTEGER |
	REAL |
	CHARACTER ;
	
optional_variables:
	optional_variables optional_variable |
	%empty ;
 
optional_variable:
	variable ;
	
variable:	
	IDENTIFIER ':' type IS statement ';' {scalars.insert($1, $5);} |
	IDENTIFIER ':' LIST OF type IS list ';' {lists.insert($1, $7);} |
	error ';' ;

list:
	'(' expressions ')' {$$ = $2;} ;

expressions:
	expressions ',' expression {$1->push_back($3); $$ = $1;} | 
	expression {$$ = new vector<double>(); $$->push_back($1);} ;

body:
	BEGIN_ statement_ END ';' {$$ = $2;} ;

statement_:
	statement ';' |
	error ';' {$$ = 0;} ;
    
statement:
	expression |
	WHEN condition ',' expression ':' expression {$$ = $2 ? $4 : $6;} |
	SWITCH expression IS cases OTHERS ARROW statement_ ENDSWITCH {$$ = !isnan($4) ? $4 : $7;} |
	IF condition THEN statement_ elsifs ELSE statement_ ENDIF {$$ = $2 ? $4 : !isnan($5) ? $5 : $7;} |
	FOLD direction operator list_choice ENDFOLD {$$ = evaluateFold($2, $3, *$4);} ;

direction:
	LEFT {$$ = $1;} |
	RIGHT {$$ = $1;};

operator:
	ADDOP {$$ = $1;} |
	MULOP {$$ = $1;} ;

list_choice:
	list {$$ = $1;} |
	IDENTIFIER {if (!lists.find($1, $$)) appendError(UNDECLARED, $1);} ; 

elsifs:
	elsifs elsif {$$ = !isnan($1) ? $1 : $2;} |
	%empty {$$ = NAN;};
 
elsif:
	ELSIF condition THEN statement ';' {$$ = $2 ? $4 : NAN;};

cases:
	cases case {$$ = !isnan($1) ? $1 : $2;} |
	%empty {$$ = NAN;} ;
	
case:
	CASE INT_LITERAL ARROW statement ';' {$$ = $<value>-2 == $2 ? $4 : NAN;} |
	error ';' {$$ = 0;} ; //SA added

condition:
	condition OROP relation_tertiary {$$ = evaluateLogical($1, $2, $3);} |
	relation_tertiary ;

relation_tertiary:
	relation_tertiary ANDOP relation_secondary {$$ = evaluateLogical($1, $2, $3);} |
	relation_secondary ;

relation_secondary:
	NOTOP relation {$$ = evaluateLogical(0, $1, $2);} |
	relation ;

relation:
	'(' condition ')' {$$ = $2;} |
	expression RELOP expression {$$ = evaluateRelational($1, $2, $3);} ;

expression:
	expression ADDOP term {$$ = evaluateArithmetic($1, $2, $3);} |
	term ;
      
term:
	term MULOP secondary {$$ = evaluateArithmetic($1, $2, $3);} |
	term REMOP secondary {$$ = evaluateArithmetic($1, $2, $3);} |
	secondary ;

secondary:
	primary EXPOP secondary {$$ = evaluateArithmetic($1, $2, $3);} |
	primary;

primary:
	'(' expression ')' {$$ = $2;} |
	NEGOP primary {$$ = evaluateArithmetic(0, $1, $2);} |
	INT_LITERAL | 
	CHAR_LITERAL |
	REAL_LITERAL |
	IDENTIFIER '(' expression ')' {$$ = extract_element($1, $3); } |
	IDENTIFIER {if (!scalars.find($1, $$)) appendError(UNDECLARED, $1);} ;

%%

void yyerror(const char* message) {
	appendError(SYNTAX, message);
}

double extract_element(CharPtr list_name, double subscript) {
	vector<double>* list; 
	if (lists.find(list_name, list))
		return (*list)[subscript];
	appendError(UNDECLARED, list_name);
	return NAN;
}

int main(int argc, char *argv[]) {

	param_array = new double[argc];					// Parameter array is allocated based on argc
	
	for (int i = 1; i < argc; i++) {				// Start at index 1 to skip ./compile (which is stored as 0)
		if (argv[i][0] == '#' ) {				// Need to check if param is a hex input
			param_array[i] = hexToInt(argv[i]);		// CLI hex argument converted to int and stored in param_array
		}
		else if (argv[i][0] == '\'') {				// Need to check if param is a character input
			param_array[i] = charToInt(argv[i]);		// CLI character argument converted to int and stored in param_array
		} else {
			param_array[i] = atof(argv[i]);			// CLI numeric argument converted to double and stored in param_array
		}
	}

	firstLine();
	yyparse();
	if (lastLine() == 0)
		cout << "Result = " << result << endl;
	return 0;
} 
