%{
#include "vlang.tab.h"
#include <string.h>
#include <stdio.h>
void yyerror (char *s);
int yylex();
%}


ids             [a-zA-Z]([a-zA-Z0-9]+)?
number          [0-9]+
operators       [ -+*/=;]

%%
"print"				   {return print;}
"loop"                 {return Loop;}
"exit"				   {return exit_command;}
"scl"                  {return scl;}
"vec"                  {return vec;}
{ids}		           {
                        char tmp[2] = {'s', '2'};
                        strcpy(yylval.id,tmp);
                        printf("%s",yylval.id );
                         return identifier;}
{number}               {yylval.num = atoi(yytext); return number;}
[ \t\n]                ;
{operators}            {return yytext[0];}
.                      {ECHO; yyerror ("unexpected character");}

%%
int yywrap (void) {return 1;}

