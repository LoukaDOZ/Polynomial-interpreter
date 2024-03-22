%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "poly.h"

extern FILE* yyin;
extern int yy_flex_debug;
extern char* yytext;

int LINE_COUNT = 1;
short IS_FILE_MODE = 0;
char* FILE_NAME = NULL;
char* ROOT_FILE_EXTENTION = "md";

typedef struct cumulative_str cumulative_str;

int yyerror(char*);
int yylex();

void print_line_if_file_mode();
void print_header(char* s);
void add_token_to_command(char* s, int len);
void print_command();
void free_command(cumulative_str* s);
void reset_command();
void remove_command_last_spaces();
void print_command_err();

struct cumulative_str {
  cumulative_str* next;
  char* str;
};

cumulative_str* USER_COMMAND = NULL;
%}

%locations
%code requires {
void add_token_to_command();

#define YY_USER_ACTION                        \
  if(strcmp(yytext, "\n") != 0)               \
    add_token_to_command(yytext, yyleng);
}

%union {
  long val;
  long double float_val;
  char var;
  char buff[16];
  char file[257];
  struct polynomial* poly;
  struct tmp_monomial* tmp_mono;
  struct show_cmd* show_cmd;
  struct eval_at* eval_at;
  struct evaluated_polynomial* evaluated_poly;
}

%token <val> NUM
%token <float_val> FLOAT
%token <var> VAR
%token <buff> POLY SYMCONST
%token <file> FILENAME
%token EXIT
%token LET
%token SHOW LIST ASC DESC
%token EVAL AT
%token DERIVE TIMES
%token FIND ROOT FOR BETWEEN AND SAVE AS
%token LPARENT RPARENT LBRACKET RBRACKET EQUALS COMMA DOT POW PLUS MINUS MULTIPLY APOSTROPHE SEMICOLON EOL INVALIDNAME ANY

%type <buff> PolyName
%type <show_cmd> Show
%type <evaluated_poly> Eval Derive
%type <eval_at> At
%type <poly> Let Mono MonoDef Def GetPoly ArithOperation
%type <tmp_mono> ExplicitMono
%type <val> Num PowNum OrderOption DeriveCount
%type <float_val> RootNum Float Root
%type <file> FileName

%left MINUS PLUS
%left MULTIPLY

%start S
%%

S:
    Line
  | Line S
  ;

Line:
    EndOfKeyword          { reset_command(); }
  | Keyword EndOfKeyword  { reset_command(); }
  | error EndOfKeyword    { YYABORT; }
  ;

EndOfKeyword:
    EOL             { LINE_COUNT++; }
  | SEMICOLON
  ;

Keyword:
    EXIT                  { YYACCEPT; }
  | LET Let              {
                            reduce_poly($2);
                            add_poly($2);
                            print_header("LET");
                            printf("Polynôme %s ajouté\n\n", $2->name);
                          }
  | LET Let error        {
                            if($2 != NULL)
                              free_poly($2);
                          }
  | SHOW Show             {
                            print_header("SHOW");

                            if($2->p == NULL)
                              show_all_poly($2->display, $2->order);
                            else {
                              if($2->display == LIST_DISPLAY)
                                  show_poly_list($2->p, $2->order);
                              else
                                  show_poly_var($2->p, $2->p->var, $2->order, NOT_DERIVED);
                            }

                            printf("\n");
                            free_show_cmd($2);
                          }
  | SHOW Show error       {
                            if($2 != NULL)
                              free_show_cmd($2);
                          }
  | EVAL Eval             {
                            print_header("EVAL");
                            show_evaluated_poly($2, NOT_DERIVED);
                            printf("\n");
                            free_evaluated_poly($2);
                          }
  | EVAL Eval error       {
                            if($2 != NULL)
                              free_evaluated_poly($2);
                          }
  | DERIVE Derive         {
                            print_header("DERIVE");
                            show_evaluated_poly($2, DERIVED);
                            printf("\n");
                            free_evaluated_poly($2);
                          }
  | DERIVE Derive error   {
                            if($2 != NULL)
                              free_evaluated_poly($2);
                          }
  | ArithOperation        {
                            print_header("OPERATION");
                            reduce_poly($1);
                            show_def($1, DESCENDING_ORDER);
                            printf("\n\n");
                            free_poly($1);
                          }
  | ArithOperation error  {
                            if($1 != NULL)
                              free_poly($1);
                          }
  | FIND ROOT Root        {
                            print_header("FIND ROOT");
                            printf("%Lf\n\n", $3);
                          }
  | FIND ROOT Root error
  ;

Root:
    FOR GetPoly BETWEEN RootNum AND RootNum
                {
                  if($4 >= $6) {
                    yyerror("a doit être inférieur à b");
                    YYERROR;
                  }

                  evaluated_polynomial* ep1 = eval_poly($2, new_eval_at_float($4));
                  evaluated_polynomial* ep2 = eval_poly($2, new_eval_at_float($6));

                  if(ep1->res_float * ep2->res_float > 0) {
                    yyerror("P(a) * P(b) doit être inférieur ou égal à 0");
                    free_evaluated_poly(ep1);
                    free_evaluated_poly(ep2);
                    YYERROR;
                  }

                  $$ = find_poly_root($2, $4, $6, NULL);
                  free_evaluated_poly(ep1);
                  free_evaluated_poly(ep2);
                }
  | FOR GetPoly BETWEEN RootNum AND RootNum SAVE AS FileName
                {
                  if($4 >= $6) {
                    yyerror("<valeur1> doit être inférieur à <valeur2>");
                    YYABORT;
                  }

                  evaluated_polynomial* ep1 = eval_poly($2, new_eval_at_float($4));
                  evaluated_polynomial* ep2 = eval_poly($2, new_eval_at_float($6));

                  if(ep1->res_float * ep2->res_float > 0) {
                    yyerror("P(<valeur1>) * P(<valeur2>) doit être inférieur ou égal à 0");
                    free_evaluated_poly(ep1);
                    free_evaluated_poly(ep2);
                    YYERROR;
                  }

                  char name[MAX_FILE_NAME_LEN + 5];
                  sprintf(name, "%s.%s", $9, ROOT_FILE_EXTENTION);
                  FILE* file = fopen(name, "w+");

                  if(file == NULL) {
                    yyerror("Impossible d'écrire le fichier");
                    fclose(file);
                    free_evaluated_poly(ep1);
                    free_evaluated_poly(ep2);
                    YYERROR;
                  }

                  $$ = find_poly_root($2, $4, $6, file);
                  fprintf(file, "## Résultat trouvé\n");
                  fprintf(file, "%c = %Lf", $2->var, $$);

                  fclose(file);
                  free_evaluated_poly(ep1);
                  free_evaluated_poly(ep2);
                }
  ;

FileName:
    FILENAME    { strcpy($$, $1); }
  | POLY        { strcpy($$, $1); }
  | SYMCONST    { strcpy($$, $1); }
  ;

RootNum:
    Num         { $$ = (long double) $1; }
  | Float       { $$ = $1; }
  ;

ArithOperation:
    LPARENT MonoDef RPARENT                     { $$ = $2; }
  | ExplicitMono                                {
                                                  $$ = new_poly($1->var);
                                                  add_mono($$, $1->mono);
                                                  reduce_poly($$);
                                                  free_tmp_mono($1);
                                                }
  | ArithOperation MULTIPLY ArithOperation      {
                                                  $$ = $1;

                                                  if(!check_and_replace_var($$, $3->var)) {
                                                    yyerror("Un polynôme ne peut avoir qu'une seule variable");
                                                    free_poly($$);
                                                    free_poly($3);
                                                    YYERROR;
                                                  }

                                                  poly_multiplication($1, $3);
                                                  free_poly($3);
                                                }
  | ArithOperation MINUS ArithOperation         {
                                                  $$ = $1;

                                                  if(!check_and_replace_var($$, $3->var)) {
                                                    yyerror("Un polynôme ne peut avoir qu'une seule variable");
                                                    free_poly($$);
                                                    free_poly($3);
                                                    YYERROR;
                                                  }

                                                  poly_substraction($1, $3);
                                                  free_poly($3);
                                                }
  | ArithOperation PLUS ArithOperation          {
                                                  $$ = $1;

                                                  if(!check_and_replace_var($$, $3->var)) {
                                                    yyerror("Un polynôme ne peut avoir qu'une seule variable");
                                                    free_poly($$);
                                                    free_poly($3);
                                                    YYERROR;
                                                  }

                                                  poly_addition($1, $3);
                                                  free_poly($3);
                                                }
  | LPARENT ArithOperation RPARENT              { $$ = $2; }
  | LPARENT ArithOperation RPARENT POW PowNum   {
                                                  $$ = $2;
                                                  poly_pow($$, $5);
                                                }
  | GetPoly DeriveCount LPARENT VAR RPARENT     {
                                                  $$ = copy_poly($1);
                                                  $$->var = $4;
                                                  derive_poly($$, $2);
                                                }
  | GetPoly DeriveCount LPARENT Num RPARENT     {
                                                  polynomial* p = copy_poly($1);
                                                  derive_poly(p, $2);

                                                  evaluated_polynomial* ep = eval_poly(p, new_eval_at_num($4));

                                                  $$ = new_poly(UNKNOWN_VAR);
                                                  add_mono($$, new_mono(ep->res_num, 0));

                                                  free_evaluated_poly(ep);
                                                  free_poly(p);
                                                }
  | PLUS ArithOperation                         { $$ = $2; }
  | MINUS ArithOperation                        {
                                                  $$ = $2;
                                                  inverse_poly($$);
                                                }
  ;


DeriveCount:
    %empty                    { $$ = 0; }
  | APOSTROPHE DeriveCount    { $$ = $2 + 1; }
  ;

Derive:
    GetPoly               {
                            polynomial* derive = copy_poly($1);
                            derive_poly(derive, 1);
                            $$ = eval_poly(derive, new_eval_at_var($1->var));
                            free_poly(derive);
                          }
  | GetPoly At            {
                            polynomial* derive = copy_poly($1);
                            derive_poly(derive, 1);
                            $$ = eval_poly(derive, $2);
                            free_poly(derive);
                          }
  | Num TIMES GetPoly     {
                            if($1 < 0) {
                              yyerror("Il est impossible de dériver moins de fois que 0");
                              YYERROR;
                            }

                            polynomial* derive = copy_poly($3);
                            derive_poly(derive, $1);
                            $$ = eval_poly(derive, new_eval_at_var($3->var));
                            free_poly(derive);
                          }
  | Num TIMES GetPoly At  {
                            if($1 < 0) {
                              yyerror("Il est impossible de dériver moins de fois que 0");
                              YYERROR;
                            }
                            
                            polynomial* derive = copy_poly($3);
                            derive_poly(derive, $1);
                            $$ = eval_poly(derive, $4);
                            free_poly(derive);
                          }
  ;

Eval:
    GetPoly At      { $$ = eval_poly($1, $2); }
  ;

At:
    AT VAR          { $$ = new_eval_at_var($2); }
  | AT SYMCONST     { $$ = new_eval_at_symconst($2); }
  | AT Num          { $$ = new_eval_at_num($2); }
  | AT Float        { $$ = new_eval_at_float($2); }
  | AT FILENAME     { yyerror("Ce nom de constante symbolique est trop long"); YYERROR; }
  | AT INVALIDNAME  { yyerror("Ce nom de constante symbolique est trop long"); YYERROR; }
  ;

Float:
    FLOAT             { $$ = $1; }
  | PLUS FLOAT        { $$ = $2; }
  | MINUS FLOAT       { $$ = -1 * $2; }
  ;

Show:
    %empty                    { $$ = new_show_cmd(NULL, CLASSIC_DISPLAY, CLASSIC_ORDER); }
  | LIST                      { $$ = new_show_cmd(NULL, LIST_DISPLAY, CLASSIC_ORDER); }
  | LIST OrderOption          { $$ = new_show_cmd(NULL, LIST_DISPLAY, $2); }
  | OrderOption               { $$ = new_show_cmd(NULL, CLASSIC_DISPLAY, $1); }
  | OrderOption LIST          { $$ = new_show_cmd(NULL, LIST_DISPLAY, $1); }
  | GetPoly                   { $$ = new_show_cmd($1, CLASSIC_DISPLAY, CLASSIC_ORDER); }
  | GetPoly LIST              { $$ = new_show_cmd($1, LIST_DISPLAY, CLASSIC_ORDER); }
  | GetPoly LIST OrderOption  { $$ = new_show_cmd($1, LIST_DISPLAY, $3); }
  | GetPoly OrderOption       { $$ = new_show_cmd($1, CLASSIC_DISPLAY, $2); }
  | GetPoly OrderOption LIST  { $$ = new_show_cmd($1, LIST_DISPLAY, $2); }
  ;

GetPoly:
    PolyName      {
                    $$ = get_poly($1);

                    if($$ == NULL) {
                      yyerror("Aucun polynôme ne possède ce nom");
                      YYERROR;
                    }
                  }
  ;

PolyName:
    POLY          { strcpy($$, $1); }
  | FILENAME      { yyerror("Ce nom de polynôme est trop long"); YYERROR; }
  | INVALIDNAME   { yyerror("Ce nom de polynôme est trop long"); YYERROR; }
  ;

OrderOption:
    ASC             { $$ = ASCENDING_ORDER; }
  | DESC            { $$ = DESCENDING_ORDER; }
  ;

Let:
   PolyName LPARENT VAR RPARENT EQUALS Def  
                      {
                        if(poly_name_exists($1)) {
                            yyerror("Ce nom de polynôme est déjà pris");
                            free_poly($6);
                            YYERROR;
                        }

                        if(!check_and_replace_var($6, $3)) {
                            yyerror("La variable doit être la même que celle déclarée");
                            free_poly($6);
                            YYERROR;
                        }

                        $$ = $6;
                        set_poly_name($$, $1);
                    }
  ;

Def:
    MonoDef                 { $$ = $1; }
  | ArithOperation          { $$ = $1; }
  /* (Question 1, plus utilisé)
  | ExplicitDef             { $$ = $1; }*/
  ;

MonoDef:
    LBRACKET Mono RBRACKET          { $$ = $2; }
  ;

Mono:
    LPARENT Num COMMA PowNum RPARENT            {
                                                    $$ = new_poly(UNKNOWN_VAR);
                                                    add_mono($$, new_mono($2, $4));
                                                }
  | Mono COMMA LPARENT Num COMMA PowNum RPARENT { 
                                                    $$ = $1;
                                                    add_mono($$, new_mono($4, $6));
                                                }
  ;

Num:
    NUM               { $$ = $1; }
  | PLUS NUM          { $$ = $2; }
  | MINUS NUM         { $$ = -1 * $2; }
  ;

PowNum:
    NUM               { $$ = $1; }
  | PLUS NUM          { $$ = $2; }
  | MINUS NUM         {
                        if($2 != 0) {
                          yyerror("Le degré de la puissance ne peut pas être négatif");
                          YYERROR;
                        }

                        $$ = 0;
                      }
  ;

/* Question 1 (plus utilisé)
ExplicitDef:
    ExplicitMono                      {
                                        $$ = new_poly($1->var);
                                        add_mono($$, $1->mono);
                                        free_tmp_mono($1);
                                      }
  | PLUS ExplicitMono                 {
                                        $$ = new_poly($2->var);
                                        add_mono($$, $2->mono);
                                        free_tmp_mono($2);
                                      }
  | MINUS ExplicitMono                {
                                        $$ = new_poly($2->var);
                                        inverse_mono($2->mono);
                                        add_mono($$, $2->mono);
                                        free_tmp_mono($2);
                                      }
  | ExplicitDef PLUS ExplicitMono     {
                                        if(!check_and_replace_var($1, $3->var)) {
                                            yyerror("Un polynôme ne peut avoir qu'une seule variable");
                                            free_poly($1);
                                            free_def($3->mono);
                                            free_tmp_mono($3);
                                            YYERROR;
                                        }

                                        $$ = $1;
                                        add_mono($$, $3->mono);
                                        free_tmp_mono($3);
                                      }
  | ExplicitDef MINUS ExplicitMono    {
                                        if(!check_and_replace_var($1, $3->var)) {
                                            yyerror("Un polynôme ne peut avoir qu'une seule variable");
                                            free_poly($1);
                                            free_def($3->mono);
                                            free_tmp_mono($3);
                                            YYERROR;
                                        }

                                        $$ = $1;
                                        inverse_mono($3->mono);
                                        add_mono($$, $3->mono);
                                        free_tmp_mono($3);
                                      }
  ;*/

ExplicitMono:
    NUM                               { $$ = new_tmp_mono(new_mono($1, 0), UNKNOWN_VAR); }
  | NUM VAR                           { $$ = new_tmp_mono(new_mono($1, 1), $2); }
  | NUM VAR POW PowNum                { $$ = new_tmp_mono(new_mono($1, $4), $2); }
  | NUM DOT VAR                       { $$ = new_tmp_mono(new_mono($1, 1), $3); }
  | NUM DOT VAR POW PowNum            { $$ = new_tmp_mono(new_mono($1, $5), $3); }
  | VAR                               { $$ = new_tmp_mono(new_mono(1, 1), $1); }
  | VAR POW PowNum                    { $$ = new_tmp_mono(new_mono(1, $3), $1); }
  ;

%%

int yyerror(char* s) {
  fprintf(stderr, "[\033[0;31mERREUR\033[0m] ");
  print_line_if_file_mode(stderr);
  fprintf(stderr, "\n");
  print_command_err();
  fprintf(stderr, "%s\n\n", s);

  return 0;
}

void print_line_if_file_mode(FILE* f) {
  if(IS_FILE_MODE)
    fprintf(f, "[%s, Ligne %d]", FILE_NAME, LINE_COUNT);
  else
    fprintf(f, "[Mode interactif]");
}

void print_header(char* s) {
  printf("[\033[0;36m%s\033[0m] ", s);
  print_line_if_file_mode(stdout);
  printf("\n");
}

void add_token_to_command(char* s, int len) {
  cumulative_str* str = (cumulative_str*) malloc(sizeof(cumulative_str));

  str->next = NULL;
  str->str = (char*) malloc(sizeof(char) * len + 1);
  strcpy(str->str, s);

  if(USER_COMMAND == NULL)
    USER_COMMAND = str;
  else {
    cumulative_str* s = USER_COMMAND;

    while(s->next != NULL)
      s = s->next;

      s->next = str;
  }
}

void print_command() {
  cumulative_str* s = USER_COMMAND;

  while(s != NULL) {
    fprintf(stderr, "%s", s->str);
    s = s->next;
  }

  fprintf(stderr, "\n");
}

void free_command(cumulative_str* s) {
  cumulative_str* next;

  while(s != NULL) {
    next = s->next;
    free(s->str);
    free(s);
    s = next;
  }
}

void reset_command() {
  free_command(USER_COMMAND);
  USER_COMMAND = NULL;
}

void remove_command_last_spaces() {
  cumulative_str* s = USER_COMMAND;
  cumulative_str* last;

  while(s != NULL) {
    if(strcmp(s->str, " ") != 0 && strcmp(s->str, "\t") != 0)
      last = s;

    s = s->next;
  }

  if(last->next != NULL) {
    free_command(last->next);
    last->next = NULL;
  }
}

void print_command_err() {
  remove_command_last_spaces();

  cumulative_str* s = USER_COMMAND;
  char* last_token;
  while(s != NULL) {
    fprintf(stderr, "%s", s->str);
    last_token = s->str;
    s = s->next;
  }

  fprintf(stderr, "\n");
  s = USER_COMMAND;
  int count = 0;
  while(s->next != NULL) {
    if(strcmp(s->str, "\t") == 0) {
      fprintf(stderr, "\t");
      count += 4 - (count % 4);
    } else {
      int spaces = strlen(s->str);

      for(int i = 0; i < spaces; i++)
        fprintf(stderr, " ");

      count += spaces;
    }

    s = s->next;
  }
  count += 1;

  fprintf(stderr, "\033[0;31m^\033[0m\n");
  fprintf(stderr, "[\033[0;31mPrès du token \"%s\" à la position %d\033[0m]: ", last_token, count);
}

int main(int argc, char* argv[]) {
  FILE* file = NULL;
  yy_flex_debug = 0;

  if(argc > 1) {
    IS_FILE_MODE = 1;
    FILE_NAME = argv[1];
    file = fopen(argv[1], "r");

    if(file == NULL) {
      yyerror("Fichier introuvable ou inaccessible");
      return EXIT_FAILURE;
    }

    yyin = file;
  }

  while(1) {
    if(yyparse() == 0 || IS_FILE_MODE)
      break;
    reset_command();
  }

  reset_command();
  free_all_poly();
  if(file != NULL)
    fclose(file);

  return EXIT_SUCCESS;
}