%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    void yyerror (char *s);
    void lab1(void);
    void lab2(void);
    void lab3(void);
    void codegen_assign(void);
    void codegen_umin(void);
    void codegen(void);
    void push(void);

%}
%token ID NUM IF THEN ELSE
%right '='
%left '+' '-'
%left '*' '/'
%left UMINUS
%%

S : IF '(' E ')'{lab1();} THEN E ';'{lab2();} ELSE E ';'{lab3();}
  ;
E : V '='{push();} E{codegen_assign();}
  | E '+'{push();} E{codegen();}
  | E '-'{push();} E{codegen();}
  | E '*'{push();} E{codegen();}
  | E '/'{push();} E{codegen();}
  | '(' E ')'
  | '-'{push();} E{codegen_umin();} %prec UMINUS
  | V
  | NUM{push();}
  ;
V : ID {push();}
  ;
%%

#include "lex.yy.c"
#include<ctype.h>
char st[100][10];
int top=0;
char i_[2]="0";
char temp[2]="t";

int label[20];
int lnum=0;
int ltop=0;

int main()
 {
    printf("Enter the expression : ");
    yyparse();
    return 0;
 }

void push(void)
 {
  strcpy(st[++top],yytext);
 }

void codegen(void)
 {
    strcpy(temp,"t");
    strcat(temp,i_);
    printf("%s = %s %s %s\n",temp,st[top-2],st[top-1],st[top]);
    top-=2;
    strcpy(st[top],temp);
    i_[0]++;
 }

void codegen_umin(void)
{
    strcpy(temp,"t");
    strcat(temp,i_);
    printf("%s = -%s\n",temp,st[top]);
    top--;
    strcpy(st[top],temp);
    i_[0]++;
}

void codegen_assign(void)
 {
    printf("%s = %s\n",st[top-2],st[top]);
    top-=2;
 }

void lab1(void)
{
    lnum++;
    strcpy(temp,"t");
    strcat(temp,i_);
    printf("%s = not %s\n",temp,st[top]);
    printf("if %s goto L%d\n",temp,lnum);
    i_[0]++;
    label[++ltop]=lnum;
}

void lab2(void)
{
    int x;
    lnum++;
    x=label[ltop--];
    printf("goto L%d\n",lnum);
    printf("L%d: \n",x);
    label[++ltop]=lnum;
}

void lab3(void)
{
    int y;
    y=label[ltop--];
    printf("L%d: \n",y);
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);}
