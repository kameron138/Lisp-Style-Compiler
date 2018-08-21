%option noyywrap



%{
	#include <stdlib.h>
	#include <stdio.h>
	#include "lisp.tab.h"		// Libraries to include
	#include <string.h>
	#define YYSTYPE double		// Set default value to double

	#define YY_DECL int yylex()	// Define the yylex() function
%}
					/* BEGIN REGULAR EXPRESSIONS */
%%

[ \t]    ;  {/* eat up whitespace */}
^0[0-9].*$		{yylval.oct = atof(yytext); return OCTAL;}
[0-9]+(\.[0-9]+)?	{yylval.dval = atof(yytext); return DOUBLE;}		/* All of the important lexemes to be caught, return their token to the Bison file */
"+" 			{return ADD; }
"-"			{return SUB; }
"/"			{return DIVIDE; }
"*"			{return MULTIPLY; }
"let"   		{return LET;}
"print" 		{return PRINT;}
"EQ"    		{return EQUAL;}
"LT"    		{return LESSTHAN;}
"LE"   		 	{return LESSTHANEQUAL;}
"GT"    		{return GREATERTHAN;}
"GE"    		{return GREATERTHANEQUAL;}
"NE"    		{return NOTEQUAL;}
"if"    		{return IF;}
"("			{return LEFTPAR;}
")"			{return RIGHTPAR;}
[a-zA-Z]		{return VARIABLE;}
"stop"			{return QUIT;}
"^"			{return POWER;}
"symbol-table"		{return TABLE;}
\;[^\n]* 

%%
