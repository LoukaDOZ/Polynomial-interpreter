%{
  #include <stdlib.h>
  #include "parser.tab.h"

  #define MAX_LEN 15
%}

eol         \n
operator    [.^]
sign        [+-]
digit       [0-9]
number      {digit}+

variable    [a-z]
polynome    [A-Z][a-zA-Z0-9_]*
constant    [a-z][a-zA-Z0-9_]+

%option noyywrap
%%

(?i:LET) { return(LET); }
(?i:SHOW) { return(SHOW); }

{polynome} {
            if(strlen(yytext) > MAX_LEN)
              return(ERR);

            strncpy(yylval.buff, yytext, MAX_LEN);
            yylval.buff[MAX_LEN] = '\0';
            return(POLY);
          }

{variable} {
            yylval.var = yytext[0];
            return(VAR);
          }

{constant} {
            if(strlen(yytext) > MAX_LEN)
              return(ERR);
            
            strncpy(yylval.buff, yytext, MAX_LEN);
            yylval.buff[MAX_LEN] = '\0';
            return(CONST);
          }

"(" { return(LPARENT); }

")" { return(RPARENT); }

"[" { return(LBRACKET); }

"]" { return(RBRACKET); }

"=" { return(EQUALS); }

"," { return(COMMA); }

"." { return(DOT); }

"^" { return(POW); }

"+" { return(PLUS); }

"-" { return(MINUS); }

{number} {
            yylval.val = strtol(yytext, NULL, 10);
            return(NUM);
          }

{eol}  { return(EOL); }

" "     { /* On ignore */ }

.     { /* On ignore */ }

%%