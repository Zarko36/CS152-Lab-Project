%{
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <iostream>
#include <vector>
#include <stack>
#include <queue>
#include <string>
#include <sstream> 
using namespace std;
void yyerror(const char *s);
int yylex(void);
extern int yylex();
extern FILE* yyin;
extern int yycolumn;
extern int yylineno;

bool isSyntaxError = false;

bool isSemanticsError = false;


struct CodeNode {
  std::string code;
  std::string name;
};

enum Type {Integer, Array};

struct Symbol {
  std::string name;
  Type type;
};

struct Function {
  std::string name;
  std::vector<Symbol> declarations;
};


std::vector<Function> symbol_table;

Function *get_function() {
  int last = symbol_table.size()-1;
  if (last < 0) {
    printf("***Error. Attempt to call get_function with an empty symbol table\n");
    printf("Create a 'Function' object using 'add_function_to_symbol_table' before\n");
    printf("calling 'find' or 'add_variable_to_symbol_table'");
    exit(1);
  }
  return &symbol_table[last];
}

bool find(std::string &value) {
  Function *f = get_function();
  for(int i=0; i < f->declarations.size(); i++) {
    Symbol *s = &f->declarations[i];
    if (s->name == value) {
      return true;
    }
  }
  return false;
}

bool find_function(string &value) {
  for(int i = 0; i < symbol_table.size(); i++) {
    if(symbol_table.at(i).name == value) {
      return true;
    }
  }
  return false;
} 

void add_variable_to_symbol_table(std::string &value, Type t) {
  Symbol s;
  s.name = value;
  s.type = t;
  Function *f = get_function();
  f->declarations.push_back(s);
}

void add_function_to_symbol_table(string &value) {
  Function f;
  f.name = value;
  symbol_table.push_back(f);
}

void print_symbol_table(void) {
  printf("symbol table:\n");
  printf("--------------------\n");
  for(int i=0; i<symbol_table.size(); i++) {
    printf("function: %s\n", symbol_table[i].name.c_str());
    for(int j=0; j<symbol_table[i].declarations.size(); j++) {
      printf("  locals: %s\n", symbol_table[i].declarations[j].name.c_str());
    }
  }
  printf("--------------------\n");
}

string makeTempVariable(int tempNum) {
  ostringstream oss;
  oss << "_temp" << tempNum;

  return oss.str();
}

std::queue<std::string> parameterStack;
std::vector<std::string>parameterVector;
vector<string>expressionVector;
int parameterNumber = 0;
char buffer[10];
int currTemp = 0;
bool isJustOneTerm = true;
queue<string>expressionQueue;
vector<string>variableVector;
bool isWhile = false;
int loopNumber = 0;
int endLoopNumber = 0;
int loopChecker = 0;
bool isNested = false;

%}

%union{
  int		int_val;
  char*	op_val;
  struct CodeNode *code_node;
  struct exprInfo {
    char* name;
    int numVal;
  }expr_info;
}


%start prog

%token FUNCTION L_PAREN R_PAREN L_CURLY R_CURLY COMMA SEMICOLON ASSIGN INTEGER L_SQUARE_BRACKET R_SQUARE_BRACKET IF ELSEIF EQ GT GTE LT LTE NEQ ADD DIV MOD MULT SUB READ WRITE RETURN ELSE WHILE DO CONTINUE BREAK PRINT
%token <int_val> NUMBER
%token <op_val> IDENT
%type <code_node> functions
%type <code_node> function
%type <code_node> identifier
%type <code_node> identifiers
%type <code_node> parameters
%type <code_node> contents
%type <code_node> content
%type <code_node> functionCall
%type <expr_info> term
%type <expr_info> expression
%type <expr_info> multDivModExpr
%type <expr_info> addSubExpr
%type <op_val> function_header
%type <code_node> comparison
%%

prog: functions
            {
              
            }
            | error {yyerrok, yyclearin;}
            ;

functions:  
            {
              
            }
            | function functions
            {
              
            }
            ;
function_header: FUNCTION IDENT {
  string function_name = $2;
  add_function_to_symbol_table(function_name);
  function_name = "main";
  if(!find_function(function_name)) {
    isSemanticsError = true;
    yyerror("function main must be included");
  }
  printf("func ");
  printf($2);
  printf("\n");
}
function: function_header L_PAREN parameters {
            for (int i = parameterVector.size()-1; i >= 0; i--) {
              cout << ". " << parameterVector.at(i) << endl;
            }

            for (int i = parameterVector.size()-1; i >= 0; i--) {
              cout << "= " << parameterVector.at(i) << ", " << "$" << parameterNumber << endl;
              ++parameterNumber;
            }
            if (parameterNumber > 0) {
              parameterNumber = 0;
              parameterVector.clear();
            }
          }
          R_PAREN L_CURLY contents R_CURLY
          {
            printf("endfunc\n\n");  
          }
          ;
parameters: 
          {
              
          }
          | INTEGER IDENT
          {

            parameterVector.push_back($2);

          }
          | INTEGER IDENT COMMA parameters
          {

            parameterVector.push_back($2);
          }
          ;
contents: {

          }
          | content contents
          {
             
          }
          | statements contents
          {}
          | content error {yyerrok;}
          ;
content:  INTEGER IDENT ASSIGN IDENT SEMICOLON
          {
            printf("= ");
            printf($2);
            printf(", ");
            printf($4);
            printf("\n");
          }
          | INTEGER IDENT L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET SEMICOLON
          {
            printf(".[] ");
            printf($2);
            printf(", ");
            printf("%d", $4);
            printf("\n");
          }
          | INTEGER IDENT ASSIGN NUMBER SEMICOLON
          {
            printf("= ");
            printf($2);
            printf(", ");
            printf("%d", $4);
            printf("\n");            
          }
          | INTEGER IDENT SEMICOLON
          {
            printf(". ");
            printf($2);
            printf("\n");
          }
          | IDENT ASSIGN functionCall SEMICOLON
          {
            printf("= ");
            printf($1);
            printf(", ");
            cout << variableVector.at(0) << endl;
            variableVector.clear();
            
          }
          | IDENT ASSIGN expression SEMICOLON
          {
            printf("= "); printf($1); printf(", ");
            cout << expressionQueue.front();
            expressionQueue.pop();
            
            printf("\n");
          }
          |IDENT ASSIGN IDENT SEMICOLON
          {
            printf("= ");
            printf($1);
            printf(", ");
            printf($3);
            printf("\n");
          }
          |arr ASSIGN identifier SEMICOLON
          {printf("content->arr ASSIGN identifier\n");}
          |IDENT L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET ASSIGN NUMBER SEMICOLON
          {
            printf("[]= ");
            printf($1);
            printf(", ");
            printf("%d", $3);
            printf(", ");
            printf("%d", $6);
            printf("\n");
          }
          |IDENT L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET ASSIGN expression SEMICOLON
          {
            printf("[]= ");
            printf($1);
            printf(", ");
            printf("%d", $3);
            printf(", ");
            cout  << expressionQueue.front();
            expressionQueue.pop();
            printf("\n");
          }
          | functionCall SEMICOLON
          {printf("content->functionCall\n");}
          ;
arr:  identifier L_SQUARE_BRACKET identifier R_SQUARE_BRACKET
      {printf("arr->identifier L_SQUARE_BRACKET identifier R_SQUARE_BRACKET\n");}
      ;     
functionCall: IDENT L_PAREN {printf("param ");} functionCall R_PAREN
              {
                printf(". _temp");
                printf("%d", currTemp);
                printf("\n");
                printf("call");
                printf($1);
                printf(", ");
                printf("_temp");
                printf("%d", currTemp);
                currTemp++;
              }
              | IDENT L_PAREN parameterExpression R_PAREN
              {
                while(!expressionQueue.empty()) {
                  cout << "param " << expressionQueue.front() << endl;
                  expressionQueue.pop();
                }

                printf(". _temp");
                printf("%d", currTemp);
                printf("\n");
                printf("call ");
                printf($1);
                printf(", _temp");
                printf("%d", currTemp);
                printf("\n");

                string tempVariable = makeTempVariable(currTemp);
                variableVector.push_back(tempVariable);
                ++currTemp;
              }
              | IDENT L_PAREN R_PAREN
              {
                printf(". _temp");
                printf("%d", currTemp);
                printf("\n");
                printf("call");
                printf($1);
                printf(", ");
                printf("_temp");
                printf("%d", currTemp);
                currTemp++;
              }
              ;
parameterExpression:  expression
                      {}
                      |expression COMMA parameterExpression
                      {}
                      ;              
identifiers: identifier
            {
              
            }
            | identifier COMMA identifiers
            {printf("identifiers->identifier COMMA identifiers\n");}
            ;
identifier:  IDENT
            {
              printf($1);
            }
            ;
statements: statement
            {}
            ;
statement:  ifStatement
            {}
            | whileStatement
            {}
            | readWriteStatements
            {}
            | returnStatement
            {}
            |breakStatement
            {}
            |continueStatement
            {}
            ;
breakStatement: BREAK SEMICOLON
                {
                  printf(":= endloop");
                  printf("%d", endLoopNumber);
                  printf("\n");
                }
                ;
continueStatement:  CONTINUE SEMICOLON
                    {}
readWriteStatements:  readWriteStatements SEMICOLON readWriteStatements
                      {}
                      | read SEMICOLON
                      {}
                      | write SEMICOLON
                      {}
                      ;
read: READ L_PAREN IDENT R_PAREN
      {
        printf(".< ");
        printf($3);
        printf("\n");
      }
      ;
write:  WRITE L_PAREN IDENT R_PAREN
        {
          printf(".> ");
          printf($3);
          printf("\n");
        }
        | WRITE L_PAREN IDENT L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET R_PAREN
        {
          printf(". _temp");
          printf("%d", currTemp);
          printf("\n");
          printf("=[] ");
          printf("_temp");
          printf("%d", currTemp);
          printf(", ");
          printf($3);
          printf(", ");
          printf("%d", $5);
          printf("\n");
          printf(".> ");
          printf("_temp");
          printf("%d", currTemp);
          printf("\n");
          currTemp++;
        }
        ;
returnStatement: returnStatement SEMICOLON returnStatement
                 {}
                | RETURN expression SEMICOLON
                {
                  printf("ret ");
                  cout << expressionQueue.front() << endl;
                  expressionQueue.pop();
                }
                | RETURN identifier L_PAREN expression R_PAREN SEMICOLON
                {printf("returnStatement->RETURN identifier L_PAREN expression R_PAREN\n");}
                | RETURN identifier L_PAREN R_PAREN SEMICOLON
                {printf("returnStatement->RETURN identifier L_PAREN R_PAREN\n");}
                ;
ifStatement: IF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY
            {printf("ifStatement->IF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY\n");}
            | IF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY ELSE L_CURLY contents R_CURLY
            {printf("ifStatement->IF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY ELSE L_CURLY contents R_CURLY\n");}
            | IF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY elseifStatment
            {printf("ifStatement->IF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY elseifStatment\n");}
            ;
elseifStatment: ELSEIF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY elseifStatment
                {printf("elseifStatment-> ELSEIF L_CURLY contents R_CURLY elseifStatment\n");}
                | ELSEIF L_PAREN logicExpression R_PAREN L_CURLY contents R_CURLY
                {printf("elseifStatment->ELSEIF L_CURLY contents R_CURLY\n");}
                | ELSE L_CURLY contents R_CURLY
                {printf("elseifStatment->ELSE L_CURLY contents R_CURLY\n");}
                ;
whileStatement: WHILE { if(loopChecker > 0) {isNested = true;} if(isNested) {++loopNumber; ++endLoopNumber;} ++loopChecker; printf(": beginloop"); printf("%d", loopNumber); printf("\n"); isWhile=true;} L_PAREN logicExpression R_PAREN L_CURLY {printf(":= endloop"); printf("%d", endLoopNumber); printf("\n"); printf(": loopbody"); printf("%d", loopNumber); printf("\n");} contents R_CURLY
                {
                  printf(":= beginloop");
                  printf("%d", loopNumber);
                  printf("\n");
                  printf(": endloop");
                  printf("%d", endLoopNumber);
                  printf("\n");
                  if (isNested) {
                    --loopNumber;
                    --endLoopNumber;
                  }
                  else {
                    ++loopNumber;
                    ++endLoopNumber;
                  }
                  --loopChecker;
                  if(loopChecker <= 0) {
                    loopChecker = 0;
                    isNested = false;
                  }
                }
              ;
logicExpression:  comparisonStatement
                  {}
                  ;

comparisonStatement:  NUMBER  comparisonVaraibles comparison IDENT
                    {
                      struct CodeNode* comparison = $3;
                      cout << comparison->code;
                      printf(" _temp");
                      printf("%d", currTemp);
                      printf(", ");
                      printf("%d", $1);
                      printf(", ");
                      printf($4);
                      printf("\n");
                      if (isWhile) {
                        printf("?:= loopbody");
                        printf("%d", loopNumber);
                        printf(", ");
                        printf("_temp");
                        printf("%d", currTemp);
                        printf("\n");
                        isWhile = false;
                      }
                      ++currTemp;
                      
                    }
                    | IDENT comparisonVaraibles comparison NUMBER
                    {
                      struct CodeNode* comparison = $3;
                      cout << comparison->code;
                      printf(" _temp");
                      printf("%d", currTemp);
                      printf(", ");
                      printf($1);
                      printf(", ");
                      printf("%d", $4);
                      printf("\n");
                      if (isWhile) {
                        printf("?:= loopbody");
                        printf("%d", loopNumber);
                        printf(", ");
                        printf("_temp");
                        printf("%d", currTemp);
                        printf("\n");
                        isWhile = false;
                      }
                      ++currTemp;
                    }
                    | IDENT comparisonVaraibles comparison IDENT
                    {
                      struct CodeNode* comparison = $3;
                      cout << comparison->code;
                      printf(" _temp");
                      printf("%d", currTemp);
                      printf(", ");
                      printf($1);
                      printf(", ");
                      printf($4);
                      printf("\n");
                      if (isWhile) {
                        printf("?:= loopbody");
                        printf("%d", loopNumber);
                        printf(", ");
                        printf("_temp");
                        printf("%d", currTemp);
                        printf("\n");
                        isWhile = false;
                      }
                      ++currTemp;
                    }
                    | expression comparison expression
                    {printf("comparisonStatement->expression comparison expression\n");}
                    | L_PAREN logicExpression R_PAREN
                    {printf("comparisonStatement->L_PAREN logicExpression R_PAREN\n");}
                    ;
comparisonVaraibles: 
{
  printf(". _temp"); 
  printf("%d", currTemp); 
  printf("\n");
}
comparison: EQ
            {
              struct CodeNode* node = new CodeNode;
              node->code = string("==");
              $$ = node;
            }
            | NEQ
            {
              struct CodeNode* node = new CodeNode;
              node->code = string("!=");
              $$ = node;
            }
            | LT
            {
              struct CodeNode* node = new CodeNode;
              node->code = string("<");
              $$ = node;
            }
            | GT
            {
              struct CodeNode* node = new CodeNode;
              node->code = string(">");
              $$ = node;
            }
            | LTE
            {
              struct CodeNode* node = new CodeNode;
              node->code = string("<=");
              $$ = node;
            }
            | GTE
            {
              struct CodeNode* node = new CodeNode;
              node->code = string(">=");
              $$ = node;
            }
            ;
expression: multDivModExpr addSubExpr
            {
        
            }
            | error {yyerrok;}
            ;
multDivModExpr: |
                {}
                |
                term
                {}
                | term MULT multDivModExpr
                {
                  isJustOneTerm = false;
                  printf(". _temp");
                  printf("%d", currTemp);
                  printf("\n");
                  printf("* _temp");
                  printf("%d", currTemp);
                  int twoElements = 2;
                  for(int i = twoElements; i > 0; i--) {
                    printf(", ");
                    cout << expressionQueue.front();
                    expressionQueue.pop();
                  }
                  string tempVariable = makeTempVariable(currTemp);
                  expressionQueue.push(tempVariable);
                  printf("\n");
                  ++currTemp;
                }
                | term DIV multDivModExpr
                {
                  isJustOneTerm = false;
                  printf(". _temp");
                  printf("%d", currTemp);
                  printf("\n");
                  printf("/ _temp");
                  printf("%d", currTemp);
                  int twoElements = 2;
                  for (int i = twoElements; i > 0; i--) {
                    printf(", ");
                    cout << expressionQueue.front();
                    expressionQueue.pop();
                  }
                  string tempVariable = makeTempVariable(currTemp);
                  expressionQueue.push(tempVariable);
                  printf("\n");
                  ++currTemp;
                }
                | term MOD multDivModExpr
                {
                  isJustOneTerm = false;
                  printf(". _temp");
                  printf("%d", currTemp);
                  printf("\n");
                  printf("% _temp");
                  printf("%d", currTemp);
                  int twoElements = 2;
                  for (int i = twoElements; i > 0; i--) {
                    printf(", ");
                    cout << expressionQueue.front();
                    expressionQueue.pop();
                  }
                  string tempVariable = makeTempVariable(currTemp);
                  expressionQueue.push(tempVariable);
                  printf("\n");
                  ++currTemp;
                }
                ;
addSubExpr: |
            {}
            |ADD expression
            {
             isJustOneTerm = false;
             printf(". _temp");
             printf("%d", currTemp); 
             printf("\n");
             printf("+ _temp");
             printf("%d", currTemp);
             int twoElements = 2;
             for(int  i = twoElements; i > 0; i--) {
              printf(", ");
              cout << expressionQueue.front();
              expressionQueue.pop();
             }
             string tempVariable = makeTempVariable(currTemp);
             expressionQueue.push(tempVariable);
             //cout << tempVariable << endl;
             //$$.name = &tempVariable[0];
             printf("\n");
             ++currTemp;

            }
            | SUB expression
            {
              isJustOneTerm = false;
              printf(". _temp");
              printf("%d", currTemp);
              printf("\n");
              printf("- _temp");
              printf("%d", currTemp);
              int twoElements = 2;
              for(int i = twoElements; i > 0; i--) {
                printf(", ");
                cout << expressionQueue.front();
                expressionQueue.pop();
              }
              string tempVariable = makeTempVariable(currTemp);
              expressionQueue.push(tempVariable);
              printf("\n");
              ++currTemp;
            }
            ;
term: term variable
      {printf("term->SUB variable\n");}
      | variable
      {}
      |arr
      {printf("term->arr\n");}
      | functionCall
      {printf("term->functionCall\n");}
      | SUB NUMBER
      {printf("term->SUB NUMBER\n");}
      | NUMBER
      {
        sprintf(buffer, "%d", $1);
        expressionQueue.push(buffer);
        $$.numVal = $1;
      }
      | L_PAREN expression R_PAREN
      {}
      | IDENT L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET
      {
        printf(". _temp");
        printf("%d", currTemp);
        printf("\n");
        printf("=[] _temp");
        printf("%d", currTemp);
        printf(", ");
        printf($1);
        printf(", ");
        printf("%d", $3);
        printf("\n");
        string tempVariable = makeTempVariable(currTemp);
        expressionQueue.push(tempVariable);
        ++currTemp;
      }
      ;
variable: IDENT
        {
          expressionQueue.push($1);
        }
                  
           
%%

int main (int argc, char** argv) {
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


  yyparse();
  //print_symbol_table();

}

void yyerror(const char* s) {
  if (isSemanticsError) {
    printf("Error: %s\n", s);
    isSemanticsError = false;
  }
  else {
    printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", yylineno-1, yycolumn,s);
  }
  exit(1);
  
}