
l_paren  \(
r_paren  \)

add      \+
sub      \-
mult      \*
div      \/
mod      %
equal    =

digit   [0-9]
digits  {digit}+
integer [+-]?{digits}
float   [+-]?({digits}(\.{digits}?)?|\.{digits})([eE]{integer})?
number {float}
whitespace [ \t\n]

%{
#include <unistd.h>
#include <stdio.h>
int yycolumn = 1; //column tracking
#define yy_DECL int yylex()
#include "calc.tab.h" 

%}

%%
{sub}       return SUB;
{add}       return ADD;
{mult}      return MULT;
{div}       return DIV;
{mod}       return MOD;
{number}    yylval.NUMBER = atof(yytext); return NUMBER; 
{l_paren}   return L_PAREN;
{r_paren}   return R_PAREN;
{equal}         return EQUAL;



{whitespace} 


.          printf("Error: Unrecognized symbol '%s'\n", yytext); return 1; 
%%
