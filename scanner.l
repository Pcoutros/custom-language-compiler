/* Pete Coutros
   Project 3 - Interpreter 
   4/13/24
   CMSC 430 Compiler Theory and Design

   MODIFIED by PETE COUTROS - additional lexemes and token names added (
   {comment2}, "-", "/", "%", "^", "~", "|", "!", "=", "<>", ">", ">=", 
   "<=", else, elsif, endfold, endif, fold, if, left, real, right, then,
   {hexadec}, and {reallit}.

   Some regular expressions modified/added (comment2 - added, id - modified,
   hexadec - added, reallit - added, char - modified)

   Note: The comment, id, hex, real, and char lexeme regular expressions were
   modified from Project 1 to the current state with the help of an email
   the professor sent with the correct regular expression definitions.

   Code from Project3 scanner.l in the skeleton code was added to my scanner.l
   file from project2.

   Lexeme-token pairs modified to include assignment statements used for semantic actions
*/

/* This file contains flex input file */

%{
#include <cstdio>
#include <string>
#include <vector>

using namespace std;

#include "values.h"
#include "listing.h"
#include "tokens.h"

%}

%option noyywrap

ws		[ \t\r]+
comment		("//"|"--").*\n
line		[\n]
id		[A-Za-z](_?_?[A-Za-z0-9])*
digit		[0-9]
dec		{digit}+
hex		#[0-9a-fA-F]+
real		{digit}*"."{digit}+([eE][+-]?{digit}+)?
char		'.'|'\\[btnrf]'
punc		[\(\),:;]
%%

{ws}		{ ECHO; }
{comment}	{ ECHO; nextLine(); }
{line}		{ ECHO; nextLine(); }
"+"		{ ECHO; yylval.oper = ADD; return(ADDOP); }
"-"		{ ECHO; yylval.oper = MINUS; return(ADDOP); }
"*"		{ ECHO; yylval.oper = MULTIPLY; return(MULOP); }
"/"		{ ECHO; yylval.oper = DIVIDE; return(MULOP); }
"%"		{ ECHO; yylval.oper = REMAINDER; return(REMOP); }
"^"		{ ECHO; yylval.oper = POWERTO; return(EXPOP); }
"~"		{ ECHO; yylval.oper = NEGATE; return(NEGOP); }
"&"		{ ECHO; yylval.oper = AND; return(ANDOP); }
"|"		{ ECHO; yylval.oper = OR; return(OROP); }
"!"		{ ECHO; yylval.oper = NOT; return(NOTOP); }
"<"		{ ECHO; yylval.oper = LESS; return(RELOP); }
"="		{ ECHO; yylval.oper = EQUALS; return(RELOP); }
"<>"		{ ECHO; yylval.oper = LESSMORE; return(RELOP); }
">"		{ ECHO; yylval.oper = MORE; return(RELOP); }		
">="		{ ECHO; yylval.oper = MOREEQ; return(RELOP); }
"<="		{ ECHO; yylval.oper = LESSEQ; return(RELOP); }
"=>"		{ ECHO; return(ARROW); }
begin		{ ECHO; return(BEGIN_); }
case		{ ECHO; return(CASE); }
character	{ ECHO; return(CHARACTER); }
end		{ ECHO; return(END); }
endswitch	{ ECHO; return(ENDSWITCH); }
function	{ ECHO; return(FUNCTION); }
integer		{ ECHO; return(INTEGER); }
is		{ ECHO; return(IS); }
list		{ ECHO; return(LIST); }
of		{ ECHO; return(OF); }
others		{ ECHO; return(OTHERS); }
returns		{ ECHO; return(RETURNS); }
switch		{ ECHO; return(SWITCH); }
when		{ ECHO; return(WHEN); }
else		{ ECHO; return(ELSE); }
elsif		{ ECHO; return(ELSIF); }
endfold		{ ECHO; return(ENDFOLD); }
endif		{ ECHO; return(ENDIF); }
fold		{ ECHO; return(FOLD); }
if		{ ECHO; return(IF); }
left		{ ECHO; yylval.direction = L; return(LEFT); }
real		{ ECHO; return(REAL); }
right		{ ECHO; yylval.direction = R; return(RIGHT); }
then		{ ECHO; return(THEN); }

{id}		{ ECHO; yylval.iden = (CharPtr)malloc(yyleng + 1); 
			strcpy(yylval.iden, yytext); return(IDENTIFIER);}
{dec}		{ ECHO; yylval.value = atoi(yytext); return(INT_LITERAL); }
{hex}		{ ECHO; yylval.value = hexToInt(yytext); return(INT_LITERAL); }
{real}		{ ECHO; yylval.value = atof(yytext); return(REAL_LITERAL); }
{char}		{ ECHO; yylval.value = charToInt(yytext); return(CHAR_LITERAL); }
{punc}		{ ECHO; return(yytext[0]); }
.		{ ECHO; appendError(LEXICAL, yytext); }
%%

