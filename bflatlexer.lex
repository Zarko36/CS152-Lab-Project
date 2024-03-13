%option yylineno
%{
#include "y.tab.h"
#include <unistd.h>
#include <stdio.h>

int yycolumn = 1; // Adding support for column tracking

char *create_string(char *value, int length) {
  char *return_value = new char[length + 1];
  strcpy(return_value, value);
  return return_value;
}
%}


DIGIT [0-9]
ALPHA [a-zA-Z]
COMMENT //.*\n
/* 1.Integer scalar variables. */
/*2.One-dimensional arrays of integers.*/
/*3.Assignment statements.*/
/*4.While and Do-While loops.*/
/*5.Continue statement.*/
/*6.Break statement.*/
/*7.If-then-else statements.*/
/*8.Read and write statements.*/
/*9.Comments.*/
/*10.Functions.*/
/*11.for whitespace */
/*12. error */
/*13. arithmetic operators*/
/*14. comparison operators*/
/*15. Special Symbols*/
/*16.identifiers and numbers*/
/*17. Reserved Words*/
%%

"func"     { yycolumn+= yyleng; return FUNCTION; }
"int"      { yycolumn+= yyleng; return INTEGER;}
"if"           { printf("IF\n"); yycolumn+= yyleng; return IF;}
"elif"        { printf("ELSEIF\n"); yycolumn+= yyleng; return ELSEIF;}
"else"         { printf("ELSE\n");yycolumn+= yyleng; return ELSE; }
"while"        { yycolumn+= yyleng; return WHILE; }
"do"           { printf("DO\n"); yycolumn+= yyleng; return DO;}
"continue"     { printf("CONTINUE\n"); yycolumn+= yyleng; return CONTINUE; }
"break"        { yycolumn+= yyleng; return BREAK; }
"read"         { printf("READ\n"); yycolumn+= yyleng; return READ; }
"write"        { yycolumn+= yyleng; return WRITE;}
"not"          { printf("NOT\n"); }
"true"         { printf("TRUE\n"); }
"false"        { printf("FALSE\n"); }
"return"       { yycolumn+= yyleng; return RETURN;}
"print"        { printf("PRINT\n"); yycolumn+= yyleng; return PRINT;}

[ \t]+         { yycolumn += yyleng; }
\n            { yycolumn = 1; yylineno; }


";"                  {yycolumn+= yyleng; return SEMICOLON;}
":"                  { printf("COLON\n"); }
","                  {yycolumn+= yyleng; return COMMA;}
"("                  {  yycolumn+= yyleng; return L_PAREN; }
")"                  {  yycolumn+= yyleng; return R_PAREN; }
"["                  { yycolumn+= yyleng; return L_SQUARE_BRACKET;}
"]"                  { yycolumn+= yyleng; return R_SQUARE_BRACKET;}
":="                 { yycolumn+= yyleng; return ASSIGN; }
"{"                  { yycolumn+= yyleng; return L_CURLY;}
"}"                  {  yycolumn+= yyleng; return R_CURLY;}


"-"            { yycolumn+= yyleng; return SUB;}
"+"            { yycolumn+= yyleng; return ADD;}
"*"            { yycolumn+= yyleng; return MULT;}
"/"            { yycolumn+= yyleng; return DIV;}
"%"            { yycolumn+= yyleng; return MOD;}

"=="           { yycolumn+= yyleng; return EQ;}
"!="           { yycolumn+= yyleng; return EQ;}
"<"            { yycolumn+= yyleng; return LT;}
">"            { yycolumn+= yyleng; return GT;}
"<="           { yycolumn+= yyleng; return LTE;}
">="           { yycolumn+= yyleng; return GTE;}


{DIGIT}+       { yycolumn+= yyleng; yylval.int_val = atoi(yytext); return NUMBER; }
{ALPHA}({ALPHA}|{DIGIT}|_)* { yycolumn+= yyleng; yylval.op_val = create_string(yytext,yyleng); return IDENT; }


"//".*               {yycolumn = 1;}
[ \t\n\r\f]+             {}

. {
    printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn, yytext);
    exit(1);
}


%%
/*
int main(void)
{
  yylex();
}
*/