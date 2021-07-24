%{
#include "ifYacc.tab.h"
void yyerror (char *s);
int yylex();
%}
ALPHA [A-Za-z]
DIGIT [0-9]
%%
if                    return IF;
then                 return THEN;
else                 return ELSE;
{ALPHA}({ALPHA}|{DIGIT})*    return ID;
{DIGIT}+             {yylval=atoi(yytext); return NUM;}
[ \t]                 ;
\n                yyterminate();
.                 return yytext[0];
%%
int yywrap (void) {return 1;}