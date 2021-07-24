%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

void cpyTokenVal(char *src, char* dest);
void buildFormat(FILE * out);
void markVector(char *vec, char *size);
int isVector(char * vec);
void printVecs();    //DELETE ME! AND MY IMPLEMENTATION!

/*print to file commands*/
void printAssignment(char * left, char * right); 
void printCommandPrint(char * name);
void printIndexing(char * leftHand, char * rightHand);

 
//Global varibales declartion
extern FILE* yyin;
extern FILE * yyout;
int  cntVec = 0, indice = 0 ;
char buff[256];

int isTmpVecExist[2] = {0,0}; 
 
char vectorSymbol[256][24];
char vectorSize[256][11];
%}

/* Yacc definitions */
%start Line

%token Identifier Number Equal Operator ArrSize
%token Semicolon OpenBracket ClosingBracket Index
%token Scl Vec
%token Loop Print If

%type <id> Identifier
%type <id> Term
%type <num> Number ArrSize
%type <exp> Exp
%type <exp> Declare
%type <exp> Statement
%left <str> Operator
%left <str> Equal 
%left <str> Index

%union {
	char str[1];
	char num[11];
	char exp[24];
	char id[12]; 
	char type[3];
	}         
%%

/* descriptions of expected inputs     corresponding actions (in C) */

Line    : Statement Semicolon				 {;}
		| Assignment Semicolon				 {;}
		| BlockStatement Block	 			 {;}
		| Line Assignment Semicolon			 {;}
		| Line Statement Semicolon			 {;}
		| Line BlockStatement Block 		 {;} 
		;

BlockStatement : Loop Exp 					{fprintf(yyout, "\tfor(int i = 0; i < %s; i++)\n{\n", $2);}
			   | If Exp					    {fprintf(yyout, "if(%s){", $2);}
			   ;	

Block : OpenBracket Line ClosingBracket      {fprintf(yyout,"\t}\n");}
	  ;

Statement : Exp								 {;}
		  |	Declare 						 {;}
		  | Print Exp						 {printCommandPrint($2);}
		  ;

Assignment	: Term Equal Exp			 	 {printAssignment($1,$3);}
		    ;

Declare : Scl Identifier					 {fprintf(yyout,"\tint %s;\n", $2);}
		| Vec Identifier ArrSize	 		 {fprintf(yyout,"\tint %s[%s];\n", $2, $3); markVector($2, $3);}
		;

Exp : Term 									 {;}
	| Exp Operator Term 					 {cpyTokenVal($1, buff);
											cpyTokenVal($2, buff);
											cpyTokenVal($3, buff);
											strcpy($$, buff);
											buff[0] = '\n';
											indice = 0;}	
	;

Term : Identifier 							{;}
	 | Number								{;}
	 | Identifier Index Term    			{printIndexing($1, $3);
											strcpy($$, buff);
											buff[0] = '\n';
											indice = 0;}
     ;

%%                     /* C code */

//print Indexing 
void printIndexing(char * leftHand, char * rightHand)
{
	int right = isVector(rightHand);

	if(right == -1)
	{
		cpyTokenVal(leftHand, buff);
		cpyTokenVal("[", buff);
		cpyTokenVal(rightHand, buff);
		cpyTokenVal("]", buff);
	}
	else
	{
		char * tmp = "indexArray(";
		cpyTokenVal(tmp, buff);
		cpyTokenVal(leftHand, buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(rightHand, buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(vectorSize[right], buff);
		cpyTokenVal(")", buff);
		isTmpVecExist[0] = 1;
		isTmpVecExist[1] = atoi(vectorSize[right]);
	}

}


//Print assignment according to varible type
void printAssignment(char * leftHand, char * rightHand) 
{
	int left = isVector(leftHand);
	int right = isVector(rightHand);

	//if left side of assignment is vector
	if(left != -1)
	{
		if(isTmpVecExist[0])
		{
			fprintf(yyout, "\ntmp = %s;", rightHand);
			fprintf(yyout, "\nassignArrayToArray(%s, %d, tmp);\n", leftHand, isTmpVecExist[1]);
			fprintf(yyout, "\nfree(tmp);");

			//nullify tmp vector array bytes
			isTmpVecExist[0] = 0;
			isTmpVecExist[1] = 0;
		}
		else if(right == -1)
		{
			fprintf(yyout, "\nassignScalarToArray(%s, %s, %s);\n", leftHand, vectorSize[left], rightHand);
		}
		else
		{
			fprintf(yyout, "\nassignArrayToArray(%s, %s, %s);\n", leftHand, vectorSize[left], rightHand);
		}
	}
	else
		fprintf(yyout,"\t%s = %s;\n", leftHand,rightHand);
}

//Print print command according to varible type
void printCommandPrint(char * name)
{
	int type = isVector(name);

	if(isTmpVecExist[0]){
		
		fprintf(yyout, "\ntmp = %s;", name);
		fprintf(yyout, "\tprintArray(tmp, %d);\n", isTmpVecExist[1]);
		fprintf(yyout, "\nfree(tmp);");		
		//nullify tmp vector array bytes
		isTmpVecExist[0] = 0;
		isTmpVecExist[1] = 0;
	}
	else if(type == -1){
		
			fprintf(yyout, "\tprintf(\"%%d\\n\", %s );\n", name);
	}
	else
		fprintf(yyout, "\tprintArray(%s, %s);\n", name, vectorSize[type]);

}

//copy to buffer all token value needed to build output
void cpyTokenVal(char * src, char * dest)
{
	int size = strlen(src);
	int offset = indice;
	for(int i = 0; i < size; i++)
	{
		dest[i + offset] = src[i];
		++(indice);
	}

	dest[indice] = '\0';	
}

//Push new vector name into the vector symbol array
void markVector(char *vec, char* size)
{
	strcpy(vectorSymbol[cntVec], vec);
	strcpy(vectorSize[cntVec], size);
	(cntVec)++;
}

//print vectors array
void printVecs(){
	for(int i=0; i<cntVec; i++){
		printf("vec - %s : %s\n", vectorSymbol[i], vectorSize[i]);
	}
}

//Check if name of Identifier is vector representation

int isVector(char * name)
{
	//if name is not vector return -1; 
	int vec  = -1;
	
	for(int i=0; i < cntVec; i++)
	{
		int eq =  strcmp(name, vectorSymbol[i]);
		if(!eq){
			//return vec index if exists
			vec = i;
		}
	}

	return vec;
}

//build C output building blocks
void buildFormat(FILE * out){

	fprintf(out, "#include <stdio.h>\n#include <stdlib.h>\n");

	fprintf(out, "\nvoid assignScalarToArray(int * vec,int size, int scl)\n");
	fprintf(out , "{\nfor(int i=0; i< size; i++){\n\tvec[i] = scl;\n}\n}\n");

	fprintf(out, "\nvoid assignArrayToArray(int * vec1,int size, int * vec2)\n");
	fprintf(out , "{\nfor(int i=0; i< size; i++){\n\tvec1[i] = vec2[i];\n}\n}\n");

	fprintf(out, "\tint* indexArray(int *vec1, int * vec2, int size)\n{\n");
	fprintf(out, "\tint *tmp = malloc(sizeof(int)*size);\nfor(int i=0; i< size; i++){\n");
	fprintf(out , "\t\ttmp[i] = vec1[vec2[i]];\n}\n\treturn tmp;}\n");
	
	fprintf(out, "\nvoid printArray(int * vec,int size)\n{\n");
	fprintf(out, "\tprintf(\"[\");\n");
	fprintf(out , "\n\tfor(int i=0; i< size-1; i++){\n\tprintf(\"%%d,\" ,vec[i]);\n}\n");
	fprintf(out, "\tprintf(\"%%d]\", vec[size -1]);\n}\n");

	fprintf(out , "\nint main(void)\n{\nint *tmp;\n");
	} 

// Main func
int main (int argc,char **argv) {
	//#ifdef YYDEBUG
	//yydebug = 1;
	//#endif

	if(argc==2 || argc == 3)
     {
   		yyin = fopen(argv[1], "r");
   		if(!yyin)
   		{
   		 	fprintf(stderr, "can't read file %s\n", argv[1]);
   		 	return 1;
   		}

		 if(argc == 3){
		 	yyout = fopen(argv[2], "w");
         	if(!yyout)
         	{
         	    fprintf(stderr, "can't read file %s\n", argv[2]);
         	    return 1;
         	}
		}
     
     }
	buildFormat(yyout);
	yyparse ( );
	fprintf(yyout, "\nreturn 0;\n}");
	return 0;
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
