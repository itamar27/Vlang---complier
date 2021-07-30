%{
#include "vlang.tab.h"
#include <string.h>
#include <stdio.h>
void yyerror (char *s);
int yylex();
void copyInnerText(char * s, char * d);
void copyTmpVectorText(char* src, char *dest);
%}


identifier         [a-zA-Z]([a-zA-Z0-9]+)?
number             [0-9]+
operators_high     [*/]
operators_low      [+-]
size               [{][0-9]+[}]
tmpVector          \[[ ]*-?[ ]*[0-9]+([ ]*,[ ]*-?[ ]*[0-9]+[ ]*)*\]
                   
%%
"scl"                  {return Scl;}
"vec"                  {return Vec;}
"print"                {return Print;}
"if"                   {return If;}
"loop"                 {return Loop;}
"="                    {sscanf(yytext, "%s",yylval.str); return Equal;}
":"                    {return Index;}
"{"                    {return OpenBracket;}
"}"                    {return CloseBracket;}
"("                    {sscanf(yytext, "%s", yylval.str); return OpenParentheses;}
")"                    {sscanf(yytext, "%s", yylval.str);return CloseParentheses;}
","                    {return Comma;}
";"                    {return Semicolon;}
"."                    {return Dot;}
{identifier}		   {sscanf(yytext, "%s", yylval.id);return Identifier;}
{number}               {sscanf(yytext, "%s", yylval.num); return Number;}
{operators_high}       {sscanf(yytext, "%s", yylval.str); return OperatorHigh;}
{operators_low}        {sscanf(yytext, "%s", yylval.str); return OperatorLow;}

{size}                 {copyInnerText(yytext, yylval.num); return ArrSize;}
{tmpVector}            {copyTmpVectorText(yytext,yylval.exp); return TmpVector;}
[ \t\n]                {;}
.                      {ECHO; yyerror ("unexpected character");}

%%
int yywrap (void) {return 1;}


//Copy the text that specifies tmp vector creation
void copyTmpVectorText(char* src, char *dest) {

    int size = strlen(src);

    for(int i = 0; i < size; i++) {
       dest[i] = src[i]; 
    }    
    dest[size] = '\0';
} 

//Copy the text that specifies the size of array 
void copyInnerText(char *src, char *dest){
    int size = strlen(src);

    for(int i = 1; i < size - 1; i++){
        dest[i - 1]  = src[i];
    }
    dest[size  - 2] = '\0';
}

