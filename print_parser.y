%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <stdbool.h>
  #include <math.h>

  extern int yylex();
  extern FILE* yyin;

  void yyerror(const char* s);

  int paren_count = 0;

%}

%locations
%define parse.error verbose
%define parse.lac full

%left  SUB ADD
%left MULT DIV MOD

%token <double> NUMBER

%token L_PAREN R_PAREN

%token UNKOWN_TOKEN

%nterm <double> expression add sub mult div mod

%start expressions

%%
expressions: expressions expression {printf("expressions -> expressions expression\n");}
           | %empty                 {printf("expressions -> epsilon\n");}
           ;
expression: add {printf("expression -> add\n");}
          | sub {printf{"expression -> sub\n"};}
          | mult {printf("expression -> mult\n");}
          | div {printf("expression -> div\n");}
          | mod {printf("expression -> mod\n");}
          | NUMBER {printf("expression -> NUMBER\n");}
          ;

add: L_PAREN ADD expression expression R_PAREN {printf("add -> L_PAREN ADD expression expression R_PAREN\n"); $$ = $3 + $4;};
sub: L_PAREN SUB expression expression R_PAREN {printf("sub -> L_PAREN SUB expression expression R_PAREN\n"); $$ = $3 - $4;};
mult: L_PAREN MULT expression expression R_PAREN {printf("mult -> L_PAREN MULT expression expression R_PAREN\n"); $$ = $3 * $4;};
div: L_PAREN DIV expression expression R_PAREN {printf("div -> L_PAREN DIV expression expression R_PAREN\n"); $$ = $3 / $4;};
mod: L_PAREN MOD expression expression R_PAREN {printf("mod -> L_PAREN MOD expression expression R_PAREN\n"); $$ = fmod($3, $4);};
%%

int main (int main argc, char** argv) {
  yyin = stdin;

  bool interactive = true;
  if (argc >= 2) {
    FILE *file_ptr =  fopen(argv[1], "r");
    if (file_ptr == NULL) {
      printf("Could not open file: %s\n", argv[1]);
      exit(1);
    }
    yyin = file_ptr;
    interactive = false;
  }

  return yyparse();

}

void yyerror(const char* s) {
  fprintf(stderr, "Error encountered while parsing token at [%i, %i, -%i, %i]: %s\n", yylloc.first_line, yylloc.first_column, ylloc.last_line, yylloc.last_column s);
  exit(1);
  
}
