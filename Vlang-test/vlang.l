%{
#include "vlang.tab.h"
#include <string.h>
#include <stdio.h>
void yyerror (char *s);
int yylex();
void copyText(char * s, char * d);
%}


identifier      [a-zA-Z]([a-zA-Z0-9]+)?
number          (\-)?[0-9]+
operators       [-+*/]
size            [{][0-9]+[}]

%%
"scl"                  {return Scl;}
"vec"                  {return Vec;}
"print"                {return Print;}
"if"                   {return If;}
"loop"                 {return Loop;}
"="                    {sscanf(yytext, "%s",yylval.str); return Equal;}
":"                    {return Index;}
"{"                    {return OpenBracket;}
"}"                    {return ClosingBracket;}
";"                    {return Semicolon;}
{identifier}		   {sscanf(yytext, "%s", yylval.id);return Identifier;}
{number}               {sscanf(yytext, "%s", yylval.num); return Number;}
{operators}            {sscanf(yytext, "%s", yylval.str); return Operator;}
{size}                 {copyText(yytext, yylval.num); return ArrSize;}
[ \t\n]                {;}
.                      {ECHO; yyerror ("unexpected character");}

%%
int yywrap (void) {return 1;}

void copyText(char *src, char *dest){
    int size = strlen(src);

    for(int i = 1; i < size - 1; i++){
        dest[i - 1]  = src[i];
    }
    dest[size  - 2] = '\0';
}

