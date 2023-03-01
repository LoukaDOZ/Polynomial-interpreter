%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "poly.h"

int yyerror(char*);
int yylex();

%}

%union {
  long val;
  char var;
  char buff[16];
  struct polynomial* poly;
  struct tmp_monomial* tmp_mono;
}

%token <val> NUM
%token <var> VAR
%token <buff> POLY CONST
%token <buff> LET SHOW
%token LPARENT RPARENT LBRACKET RBRACKET EQUALS COMMA DOT POW PLUS MINUS EOL ERR

%type <poly> Mono ExplicitDef Def
%type <tmp_mono> ExplicitMono
%type <val> Num PowNum

%start S
%%

S:
    Line      {}
  | S Line    {}
  ;

Line:
    EOL            { YYACCEPT; }
  | Keyword EOL    { show_all_poly(); }
  | error EOL      {}
  ;

Keyword:
    LET Poly
  | SHOW Show
  ;

Show:
    POLY ListOption OrderOption     { show_poly(get_poly($1), $2, $3); }
  | POLY OrderOption ListOption     { show_poly(get_poly($1), $3, $2); }
  ;

ListOption:
    %empty          { $$ = CLASSIC_DISPLAY_OPTION }
  | LIST            { $$ = LIST_DISPLAY_OPTION }
  ;

OrderOption:
    %empty          { $$ = CLASSIC_ORDER_OPTION }
  | ASC             { $$ = ASCENDING_ORDER_OPTION }
  | DESC            { $$ = DESCENDING_ORDER_OPTION }
   ;

Poly:
   POLY LPARENT VAR RPARENT EQUALS Def  {
                                            if(poly_name_exists($1)) {
                                                yyerror("Ce nom de polynôme est déjà pris");
                                                YYERROR;
                                            }

                                            if(!check_and_replace_var($6, $3)) {
                                                yyerror("La variable dans la définition doit être la même que celle déclarée précédemment");
                                                YYERROR;
                                            }

                                            set_poly_name($6, $1);
                                            add_poly($6);
                                        }
  | POLY LPARENT VAR RPARENT EQUALS Def error { printf("ERR \n"); YYERROR; }
  | ERR   { yyerror("Ce nom de polynôme est trop long"); YYERROR; }
  ;

Def:
    LBRACKET Mono RBRACKET  {
                              $$ = $2;
                            }
  | ExplicitDef             {
                              $$ = $1;
                            }
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
  | MINUS NUM         { yyerror("Le degré de la puissance ne peut pas être négatif"); YYERROR; }
  ;

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
                                            yyerror("La variable dans la définition doit être la même que celle déclarée précédemment");
                                            YYERROR;
                                        }

                                        $$ = $1;
                                        add_mono($$, $3->mono);
                                        free_tmp_mono($3);
                                      }
  | ExplicitDef MINUS ExplicitMono    {
                                        if(!check_and_replace_var($1, $3->var)) {
                                            yyerror("La variable dans la définition doit être la même que celle déclarée précédemment");
                                            YYERROR;
                                        }

                                        $$ = $1;
                                        inverse_mono($3->mono);
                                        add_mono($$, $3->mono);
                                        free_tmp_mono($3);
                                      }
  ;

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
  printf("\n%s %s\n\n", ERR_MSG, s);
  return 0;
}

int main(void) {
  yyparse();
  free_all_poly();
}