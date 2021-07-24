%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
int symbols[52];
int symbolVal(char symbol);
void updateSymbolVal(char symbol, int val);
int tcounter=0, ecounter=0;
%}

%union {int num; char* id; char *type;}         /* Yacc definitions */
%start line

%token print
%token exit_command
%token <num> number
%token <id> identifier
%token <type> scl vec

%type <num> line exp term 
%type <id> assignment dec


%%

/* descriptions of expected inputs     corresponding actions (in C) */

line    : assignment ';'				{printf("line : \n");ecounter=tcounter=0;}
		| dec ';'						{;}
		| exit_command ';'				{exit(EXIT_SUCCESS);}
		| print exp ';'					{printf("\tprintf(\"%%d\\n\", e%d );\n", $2);}
		| line dec ';'					{;}
		| line assignment ';'			{printf("line assignment : \n");}
		| line print exp ';'			{printf("\tprintf(\"%%d\\n\", e%d );\n", $3);}
		| line exit_command ';'			{exit(EXIT_SUCCESS);}
        ;

dec		: scl identifier				{ printf("\tint %s;\n" ,$2);}
		| vec identifier				{ printf("\tint %s[size];\n", $2);}
		;

assignment : identifier '=' exp  		{ printf("assignment : %s\n", $1);}
		   ;

exp    	: term                  {$$ = ++ecounter; }
       	| exp '+' term          {$$ = ++ecounter; }
       	| exp '-' term          {$$ = $1 - $3;}
		| exp '*' term			{$$ = $1}
		| exp '/' term
       	;
term   	: number                {$$ = ++tcounter; }
		| identifier			{$$ = ++tcounter;} 
        ;



%%                     /* C code */

int computeSymbolIndex(char token)
{
	int idx = -1;
	if(islower(token)) {
		idx = token - 'a' + 26;
	} else if(isupper(token)) {
		idx = token - 'A';
	}
	return idx;
} 

/* returns the value of a given symbol */
int symbolVal(char symbol)
{
	int bucket = computeSymbolIndex(symbol);
	return symbols[bucket];
}

/* updates the value of a given symbol */
void updateSymbolVal(char symbol, int val)
{
	int bucket = computeSymbolIndex(symbol);
	symbols[bucket] = val;
}

int main (void) {
	/* init symbol table */
	int i;
	for(i=0; i<52; i++) {
		symbols[i] = 0;
	}

	return yyparse ( );
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
