%{
  #include <stdlib.h>
  #include "parser.tab.h"

  #define MAX_LEN 15
  #define MAX_FILE_NAME_LEN 512

%}

eol         \n
operator    [.^]
sign        [+-]
digit       [0-9]
number      {digit}+
float       {number}\.{number}

variable    [a-z]
polynome    [A-Z][a-zA-Z0-9_]*
symbolic_constant    [a-z][a-zA-Z0-9_]+

%option yylineno
%option noyywrap
%%

(?i:EXIT)     { return EXIT; }
(?i:LET)      { return LET; }
(?i:SHOW)     { return SHOW; }
(?i:LIST)     { return LIST; }
(?i:ASC)      { return ASC; }
(?i:DESC)     { return DESC; }
(?i:EVAL)     { return EVAL; }
(?i:AT)       { return AT; }
(?i:DERIVE)   { return DERIVE; }
(?i:TIMES)    { return TIMES; }
(?i:FIND)     { return FIND; }
(?i:ROOT)     { return ROOT; }
(?i:FOR)      { return FOR; }
(?i:BETWEEN)  { return BETWEEN; }
(?i:AND)      { return AND; }
(?i:SAVE)     { return SAVE; }
(?i:AS)       { return AS; }

{polynome}  {
              int len = strlen(yytext);

              if(len > MAX_FILE_NAME_LEN)
                return INVALIDNAME;

              if(len <= MAX_LEN) {
                strncpy(yylval.buff, yytext, MAX_LEN);
                yylval.buff[MAX_LEN] = '\0';
                return POLY;
              }

              strncpy(yylval.file, yytext, MAX_FILE_NAME_LEN);
              yylval.file[MAX_FILE_NAME_LEN] = '\0';
              return FILENAME;
            }

{variable}  {
              yylval.var = yytext[0];
              return VAR;
            }

{symbolic_constant} {
                      int len = strlen(yytext);

                      if(len > MAX_FILE_NAME_LEN)
                        return INVALIDNAME;

                      if(len <= MAX_LEN) {
                        strncpy(yylval.buff, yytext, MAX_LEN);
                        yylval.buff[MAX_LEN] = '\0';
                        return SYMCONST;
                      }

                      strncpy(yylval.file, yytext, MAX_FILE_NAME_LEN);
                      yylval.file[MAX_FILE_NAME_LEN] = '\0';
                      return FILENAME;
                    }

{number}  {
            yylval.val = strtol(yytext, NULL, 10);
            return NUM;
          }

{float}  {
            yylval.float_val = strtold(yytext, NULL);
            return FLOAT;
          }

"(" { return LPARENT; }

")" { return RPARENT; }

"[" { return LBRACKET; }

"]" { return RBRACKET; }

"=" { return EQUALS; }

"," { return COMMA; }

"." { return DOT; }

"^" { return POW; }

"+" { return PLUS; }

"-" { return MINUS; }

"*" { return MULTIPLY; }

"'" { return APOSTROPHE; }

";" { return SEMICOLON; }

{eol}  { return EOL; }

" "     { /* On ignore */ }

"\t"     { /* On ignore */ }

.     { return ANY; }

%%