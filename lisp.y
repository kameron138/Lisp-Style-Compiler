%{

	
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>
	#include "lisp.tab.h"

	double symbolValMap(char c);				// Function to get the variable spot based off the char
	void updateSymbolValMap(char c, double val);		// Function to update the variable value if neccessarry
	int sym[52];						// Array that holds the variables
	extern int yylex();					// Establishing the yylex() function
	void printTable();					// Function to print everything in the array
	extern FILE* yyin;					// File to be passed in

	extern int yyparse();					// What to call when Bison file is successfully compiled
	double convertOctal(double d);				// Function to convert octal number to decimal
	void yyerror(const char* msg);				// Function to output errors
%}
  
%union {					
	double oct;						// Union holds all the Tokens important meta-values
	double dval;
	char id;
	double varID;
}
%token QUIT POWER TABLE						/* tokens with no meta values */
%token<dval> DOUBLE						/* tokens with  meta values */
%token<oct> OCTAL						
%token<id> VARIABLE
%token LET PRINT EQUAL LESSTHAN LESSTHANEQUAL GREATERTHAN GREATERTHANEQUAL		/* Tokens with no meta values */
%token NOTEQUAL IF LEFTPAR RIGHTPAR MULTIPLY DIVIDE SUB ADD


%type<dval> mixed_expression term line		/* declare types to get the meta values from regex's */
%type<id> varName
%type<oct> octexpr

%left SUB ADD MULTIPLY DIVIDE

%start program

						/* BEGIN GRAMMAR RULES */
%%
program:
	| program line						     {printf("%g", "%1f", $2);}
	;

line: '\n'
	| mixed_expression   					     
	| LEFTPAR QUIT RIGHTPAR	  				     {printf("bye!\n"); exit(EXIT_SUCCESS);} 
	| LEFTPAR PRINT term RIGHTPAR          			     {$$ = $3;}
	| LEFTPAR LET term  mixed_expression RIGHTPAR                {updateSymbolValMap($3, $4); $$ = $4;}
	| LEFTPAR PRINT mixed_expression RIGHTPAR                    {$$ = $3;}
	| LEFTPAR EQUAL mixed_expression mixed_expression RIGHTPAR   		{if ($3 == $4) $$ = 1; else $$ = 0;}
	| LEFTPAR EQUAL term mixed_expression RIGHTPAR               		{if ($3 == $4) $$ = 1; else $$ = 0;}
	| LEFTPAR EQUAL mixed_expression term RIGHTPAR  	     		{if ($3 == $4) $$ = 1; else $$ = 0;}
	| LEFTPAR EQUAL term term RIGHTPAR		      	     		{if ($3 == $4) $$ = 1; else $$ = 0;}
	| LEFTPAR LESSTHAN mixed_expression mixed_expression RIGHTPAR   	{if ($3 < $4)  $$ = 1; else $$ = 0;}
        | LEFTPAR LESSTHAN term mixed_expression RIGHTPAR               	{if ($3 < $4)  $$ = 1; else $$ = 0;}
        | LEFTPAR LESSTHAN mixed_expression term RIGHTPAR               	{if ($3 < $4)  $$ = 1; else $$ = 0;}
        | LEFTPAR LESSTHAN term term RIGHTPAR                           	{if ($3 < $4)  $$ = 1; else $$ = 0;}
	| LEFTPAR LESSTHANEQUAL mixed_expression mixed_expression RIGHTPAR   	{if ($3 <= $4) $$ = 1; else $$ = 0;}
        | LEFTPAR LESSTHANEQUAL term mixed_expression RIGHTPAR               	{if ($3 <= $4) $$ = 1; else $$ = 0;}
        | LEFTPAR LESSTHANEQUAL mixed_expression term RIGHTPAR               	{if ($3 <= $4) $$ = 1; else $$ = 0;}
        | LEFTPAR LESSTHANEQUAL term term RIGHTPAR                           	{if ($3 <= $4) $$ = 1; else $$ = 0;}
	| LEFTPAR GREATERTHAN mixed_expression mixed_expression RIGHTPAR   	{if ($3 > $4)  $$ = 1; else $$ = 0;}
        | LEFTPAR GREATERTHAN term mixed_expression RIGHTPAR               	{if ($3 > $4)  $$ = 1; else $$ = 0;}
        | LEFTPAR GREATERTHAN mixed_expression term RIGHTPAR               	{if ($3 > $4)  $$ = 1; else $$ = 0;}
        | LEFTPAR GREATERTHAN term term RIGHTPAR                           	{if ($3 > $4)  $$ = 1; else $$ = 0;}
	| LEFTPAR GREATERTHANEQUAL mixed_expression mixed_expression RIGHTPAR   {if ($3 >= $4) $$ = 1; else $$ = 0;}
        | LEFTPAR GREATERTHANEQUAL term mixed_expression RIGHTPAR               {if ($3 >= $4) $$ = 1; else $$ = 0;}
        | LEFTPAR GREATERTHANEQUAL mixed_expression term RIGHTPAR               {if ($3 >= $4) $$ = 1; else $$ = 0;}
        | LEFTPAR GREATERTHANEQUAL term term RIGHTPAR                           {if ($3 >= $4) $$ = 1; else $$ = 0;}
	| LEFTPAR NOTEQUAL mixed_expression mixed_expression RIGHTPAR  		{if ($3 != $4) $$ = 1; else $$ = 0;}
        | LEFTPAR NOTEQUAL term mixed_expression RIGHTPAR              		{if ($3 != $4) $$ = 1; else $$ = 0;}
        | LEFTPAR NOTEQUAL mixed_expression term RIGHTPAR               	{if ($3 != $4) $$ = 1; else $$ = 0;}
        | LEFTPAR NOTEQUAL term term RIGHTPAR                           	{if ($3 != $4) $$ = 1; else $$ = 0;}
	| LEFTPAR IF line mixed_expression RIGHTPAR				{if ($3 == 1) $$ = $4; else $$ = 0;}
	| LEFTPAR IF line mixed_expression mixed_expression RIGHTPAR            {if ($3 == 1) $$ = $4; else $$ = $5;}
	| LEFTPAR IF line term RIGHTPAR		                        	{if ($3 == 1) $$ = $4; else $$ = 0;}
	| LEFTPAR IF line term term  RIGHTPAR    			        {if ($3 == 1) $$ = $4; else $$ = $5;}
	| LEFTPAR TABLE RIGHTPAR					{printTable();}
	| LEFTPAR ADD octexpr octexpr RIGHTPAR				{$$ = $3 + $4;}
	| LEFTPAR ADD octexpr mixed_expression RIGHTPAR			{$$ = $3 + $4;}
	| LEFTPAR ADD mixed_expression octexpr RIGHTPAR                 {$$ = $3 + $4;}
	| LEFTPAR SUB octexpr octexpr RIGHTPAR                          {$$ = $3 - $4;}
	| LEFTPAR SUB octexpr mixed_expression RIGHTPAR                 {$$ = $3 - $4;}
	| LEFTPAR SUB mixed_expression octexpr RIGHTPAR                 {$$ = $3 - $4;}
	| LEFTPAR MULTIPLY octexpr octexpr RIGHTPAR                     {$$ = $3 * $4;}
        | LEFTPAR MULTIPLY octexpr mixed_expression RIGHTPAR            {$$ = $3 * $4;}
        | LEFTPAR MULTIPLY mixed_expression octexpr RIGHTPAR            {$$ = $3 * $4;}
	| LEFTPAR DIVIDE octexpr octexpr RIGHTPAR                       {$$ = $3 / $4;}
        | LEFTPAR DIVIDE octexpr mixed_expression RIGHTPAR              {$$ = $3 / $4;}
        | LEFTPAR DIVIDE mixed_expression octexpr RIGHTPAR              {$$ = $3 / $4;}
			
	;



mixed_expression: DOUBLE			{$$ = $1;}
	| LEFTPAR ADD  mixed_expression mixed_expression RIGHTPAR     {$$ = $3 + $4;}
	| LEFTPAR SUB  mixed_expression mixed_expression RIGHTPAR     { $$ = $3 - $4; }
	| LEFTPAR MULTIPLY mixed_expression mixed_expression RIGHTPAR {$$ = $3 * $4;}
	| LEFTPAR DIVIDE mixed_expression mixed_expression RIGHTPAR   {$$ = $3 / $4;}
	| LEFTPAR  mixed_expression RIGHTPAR		   	    { $$ = $2; }
	| LEFTPAR ADD  mixed_expression term RIGHTPAR     {$$ = $3 + $4;}
	| LEFTPAR SUB  mixed_expression term RIGHTPAR     { $$ = $3 - $4; }
	| LEFTPAR MULTIPLY mixed_expression term RIGHTPAR {$$ = $3 * $4;}
        | LEFTPAR DIVIDE mixed_expression term RIGHTPAR   {$$ = $3 / $4;}
        | LEFTPAR ADD  term mixed_expression RIGHTPAR     {$$ = $3 + $4;}
        | LEFTPAR SUB  term mixed_expression RIGHTPAR     { $$ = $3 - $4; }
        | LEFTPAR MULTIPLY term mixed_expression RIGHTPAR {$$ = $3 * $4;}
        | LEFTPAR DIVIDE term mixed_expression RIGHTPAR   {$$ = $3 / $4;}
        | LEFTPAR ADD  term  term RIGHTPAR     {$$ = $3 + $4;}
        | LEFTPAR SUB  term term RIGHTPAR     { $$ = $3 - $4; }
        | LEFTPAR MULTIPLY term  term RIGHTPAR {$$ = $3 * $4;}
        | LEFTPAR DIVIDE term term RIGHTPAR   {$$ = $3 / $4;}
	| LEFTPAR POWER mixed_expression mixed_expression RIGHTPAR {$$ = pow($3, $4);}
	| LEFTPAR POWER mixed_expression term RIGHTPAR 		   {$$ = pow($3, $4);}
	| LEFTPAR POWER term  mixed_expression RIGHTPAR		 {$$ = pow($3, $4);}
	| LEFTPAR POWER term term RIGHTPAR			 {$$ = pow($3, $4);}

	;
term: DOUBLE		{$$ = $1;}
	| VARIABLE	{$$ = symbolValMap($1);}
	;
octexpr: OCTAL	{$$ = convertOctal($1);}
	;
%%
					// END GRAMMAR
					// BEGIN FUNCTION DEFINITIONS
int main() {
	int i;
	for (i=0; i <52; i++){
		sym[i] = 0;
	}
	yyparse();
	return 0;			// Basic main routine
}
int computeSymbolIndex(char token)
{
	int idx = -1;
	if (islower(token)){
		idx = token - 'a' + 26;
	}
	else if (isupper(token)){
		idx = token - 'A';
	}
	return idx;
}
void updateSymbolValMap(char c, double val)
{
	int num = computeSymbolIndex(c);
	sym[num] = val;
}
double symbolValMap(char c)
{
	int num = computeSymbolIndex(c);
	return sym[num];
}
void printTable()
{
	int i;
	for (i = 0; i < 52; i++)
	{
		if (sym[i] != 0)
		{
			int charASCII = i + 'a' - 26;
			printf("%c",  charASCII, "%g", "%1f", " = ", sym[i] ); 
		}
	}
}
double convertOctal(double d)
{
	int decimal = 0, remainder;
	int count = 0;
	while (d > 0)
	{
		remainder = fmod(d, 10);
		decimal = decimal + remainder * pow(8, count);
		d = d/10;
		count++;
	}
	return decimal;
}
void yyerror(char const* msg)
{
	fprintf(stderr, "Parse error: %s\n", msg);
	yyparse();
}
