%{
#include <unistd.h>
#include <stdio.h>

int yycolumn = 1; // Adding support for column tracking
%}


DIGIT [0-9]
ALPHA [a-zA-Z]
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

"function"     { printf("FUNCTION\n"); }
"beginparams"  { printf("BEGIN_PARAMS\n"); }
"endparams"    { printf("END_PARAMS\n"); }
"beginlocals"  { printf("BEGIN_LOCALS\n"); }
"endlocals"    { printf("END_LOCALS\n"); }
"beginbody"    { printf("BEGIN_BODY\n"); }
"endbody"      { printf("END_BODY\n"); }
"integer"      { printf("INTEGER\n"); }
"array"        { printf("ARRAY\n"); }
"of"           { printf("OF\n"); }
"if"           { printf("IF\n"); }
"then"         { printf("THEN\n"); }
"endif"        { printf("ENDIF\n"); }
"else"         { printf("ELSE\n"); }
"while"        { printf("WHILE\n"); }
"do"           { printf("DO\n"); }
"beginloop"    { printf("BEGINLOOP\n"); }
"endloop"      { printf("ENDLOOP\n"); }
"continue"     { printf("CONTINUE\n"); }
"break"        { printf("BREAK\n"); }
"read"         { printf("READ\n"); }
"write"        { printf("WRITE\n"); }
"not"          { printf("NOT\n"); }
"true"         { printf("TRUE\n"); }
"false"        { printf("FALSE\n"); }
"return"       { printf("RETURN\n"); }
"print"        { printf("PRINT\n");}

[ \t]         { yycolumn += yyleng; }
\n            { yycolumn = 1; }


";"                  { printf("SEMICOLON\n"); }
":"                  { printf("COLON\n"); }
","                  { printf("COMMA\n"); }
"("                  { printf("L_PAREN\n"); }
")"                  { printf("R_PAREN\n"); }
"["                  { printf("L_SQUARE_BRACKET\n"); }
"]"                  { printf("R_SQUARE_BRACKET\n"); }
":="                 { printf("ASSIGN\n"); }
"{"                  { printf("L_CURLY\n");}
"}"                  { printf("R_CURLY\n");}


"-"            { printf("SUB\n"); }
"+"            { printf("ADD\n"); }
"*"            { printf("MULT\n"); }
"/"            { printf("DIV\n"); }
"%"            { printf("MOD\n"); }

"=="           { printf("EQ\n"); }
"!="           { printf("NEQ\n"); }
"<>"           { printf("NEQ\n"); }
"<"            { printf("LT\n"); }
">"            { printf("GT\n"); }
"<="           { printf("LTE\n"); }
">="           { printf("GTE\n"); }

{DIGIT}+       { printf("NUMBER: %s\n", yytext); }
{ALPHA}({ALPHA}|{DIGIT}|_)* { printf("IDENT %s\n", yytext); }


"//".*               {}
[ \t\n]+             {}

. {
    printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno, yycolumn, yytext);
    exit(1);
}


%%

int main(void)
{
  yylex();
}