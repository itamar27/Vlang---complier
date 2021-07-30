%{
void yyerror (char *s);
int yylex();
#include <stdio.h>     /* C declarations used in actions */
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/*helping functions*/
void cpyTokenVal(char *src, char* dest);
void buildFormat(FILE * out);
void markVector(char *vec, char *size);
int isVector(char * vec);
void nullifyGlobals();
void printFreeVectors();

/*print to file commands*/
void printAssignment(char * left, char * right); 
void printCommandPrint(char * name);
void printIndexing(char * leftHand, char * rightHand, char* dest);
void printConstVector(char *vec, char *dest);
void printOperator(char * left, char * right, char* op, char* dest);
void printDotProduct(char* left, char* right, char *dest);
void printParenthesesExp(char * exp, char *dest);
void printComplex(char *left, char* right,char * dest);
void printMinus(char* op, char*  exp, char *dest);
 
//Global varibales declartion
extern FILE* yyin;
extern FILE * yyout;
int  cntVec = 0, indice = 0 ,cntTmpVec = 0;
char buff[256];

int isTmpVecExist[2] = {0,0}; 
 
char vectorSymbol[256][24];
char vectorSize[256][11];
%}

/* Yacc definitions */
%start Line

%token Identifier Number Equal Operator ArrSize Dot Index
%token Semicolon OpenBracket CloseBracket  OpenParentheses CloseParentheses Comma 
%token Scl Vec TmpVector 
%token Loop Print If

%type <id>  Identifier
%type <id>  Block
%type <num> Number ArrSize
%type <exp> Exp TmpVector Term
%type <exp> Declare
%type <exp> Statement

%right <str> Equal
%left <str>  Comma
%left  <str> OperatorLow  
%left  <str> OperatorHigh 
%left  <str> Index Dot
%left  <str> OpenParentheses CloseParentheses


%union {
	char str[1];
	char num[11];
	char exp[100];
	char id[12]; 
	char type[3];
	}         
%%

/* descriptions of expected inputs     corresponding actions (in C) */

Line    		: Statement Semicolon						{nullifyGlobals();}
				| Assignment Semicolon						{nullifyGlobals();}
				| BlockStatement Block	 					{nullifyGlobals();}
				| Line Assignment Semicolon					{nullifyGlobals();}
				| Line Statement Semicolon					{nullifyGlobals();}
				| Line BlockStatement Block 				{nullifyGlobals();} 
				;

BlockStatement 	: Loop Exp									{fprintf(yyout, "\tfor(int itr_i = 0; itr_i < %s; itr_i++)\n{\n", $2);}
			   	| If Exp					    			{fprintf(yyout, "if(%s){", $2);}
			   	;	

Block 		  	: OpenBracket Line CloseBracket				{fprintf(yyout,"\t}\n");}
				;

Statement 	  	: Exp								 		{;}
		  		| Declare 							 		{;}
		  		| Print Exp						     		{printCommandPrint($2);}
		  		;

Assignment	  	: Term Equal Exp			 	 	  		{printAssignment($1,$3);}
				| Term Equal Block 					  		{;}
		    	;

Declare 		: Scl Identifier					 	 	{fprintf(yyout,"\tint %s;\n", $2);}
				| Vec Identifier ArrSize	 		 	 	{fprintf(yyout,"\tint %s[%s];\n", $2, $3); markVector($2, $3);}
				;

Exp 			: Term 									 	{;}
				| Exp OperatorHigh Exp 					 	{printOperator($1,$3,$2, $$);}
				| Exp OperatorLow Exp 					 	{printOperator($1,$3,$2, $$);}
				| Exp Dot Exp						 		{printDotProduct($1,$3, $$);}
				| OpenParentheses Exp CloseParentheses	  	{printParenthesesExp($2, $$);
															 buff[0] = '\n';
														  	 indice = 0;}
				| Exp Comma Exp								{printComplex($1,$3,  $$);}
				| OperatorLow Exp 							{printMinus($1,$2,$$);}
				;

Term 			: Identifier 								{;}
				| TmpVector									{printConstVector($1, $$);}
	 			| Number									{;}
				| TmpVector Index Exp 						{printConstVector($1, $$);
															printIndexing($$, $3, $$);
															strcpy($$, buff);
															buff[0] = '\0';
															indice = 0;}
	 			| Identifier Index Exp    					{printIndexing($1, $3, $$);
															strcpy($$, buff);
															buff[0] = '\0';
															indice = 0;} 
     			;

%%                     /* C code */

//print Minus
void printMinus(char* op,char*  exp, char *dest){

	if(strcmp("-",op) != 0){
		return;
	}

	int vec = isVector(exp);
	
	if(vec == -1){
		strcpy(dest,"-");
		strcpy(dest,exp);
		return;
	}

	else{
		printOperator(exp, "-1", "*", dest );
	}
	
}

//print complex  Exp

void printComplex(char * left,char* right,  char * dest){
		
	printCommandPrint(left);
	strcpy(dest, right);

}
//Print dot product between 2 vectors or between scalar and vector
void printDotProduct(char* left, char* right, char *dest){

	int lVal = isVector(left);
	int rVal = isVector(right);

	if(lVal != -1 && rVal != -1)
	{
		cpyTokenVal("dotProduct(", buff);
		cpyTokenVal(right, buff);
		cpyTokenVal("," , buff);
		cpyTokenVal(left, buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(vectorSize[rVal], buff);
		cpyTokenVal(",-1)", buff);
		strcpy(dest, buff);
		buff[0] =  '\0';
		indice = 0;
	}
	else if(rVal == -1){		
		
		cpyTokenVal("dotProduct(", buff);
		cpyTokenVal(left, buff);
		cpyTokenVal("," , buff);
		cpyTokenVal("NULL", buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(vectorSize[lVal], buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(right, buff);
		cpyTokenVal(")", buff);
		strcpy(dest, buff);
		buff[0] =  '\0';
		indice = 0;
	}
	else if(lVal == -1){		
		cpyTokenVal("dotProduct(", buff);
		cpyTokenVal(right, buff);
		cpyTokenVal("," , buff);
		cpyTokenVal("NULL", buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(vectorSize[rVal], buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(left, buff);
		cpyTokenVal(")", buff);
		strcpy(dest, buff);
		buff[0] =  '\0';
		indice = 0;
	}

}

//print parentheses accodring to the exp in them
void printParenthesesExp(char* exp, char * dest){
	
	int vec = isVector(exp);

	if(vec == -1){
		cpyTokenVal("(", buff);
		cpyTokenVal(exp, buff);
		cpyTokenVal(")", buff);
		strcpy(dest, buff);
	}
	else
	{
			strcpy(dest, exp);
	}

}

//print the actions preformed with vXv | vXs | sXv | sxs
void printOperator(char * left, char * right, char* op, char * dest){

	int lVal = isVector(left);
	int rVal = isVector(right);

	//check if the right or left side of the operator is a vector 
	if(lVal != -1 || rVal != -1){
		
		int counter = 0;
		char num[11];
		itoa(cntTmpVec++,num, 10);
		strcpy(dest, "myTmpVec");
		strcat(dest,num);
		num[0] = '\0';
		
		if(lVal >= 0 && rVal >= 0)
		{
			fprintf(yyout,"\n\tint * %s = twoVectorsOperations(%s, %s, %s, \'%s\');\n", dest,left, right,vectorSize[lVal],  op);
			counter = atoi(vectorSize[lVal]);
			itoa(counter, num , 10);

		}
		else if(lVal >= 0 && rVal <= 0){
			fprintf(yyout,"\n\tint * %s = vectorScalarOperations(%s, %s, %s, \'%s\');\n", dest,left, right,vectorSize[lVal],  op);
			counter = atoi(vectorSize[lVal]);
			itoa(counter, num , 10);
		}
		else if(lVal <= 0 && rVal >= 0){
			fprintf(yyout,"\n\tint * %s = vectorScalarOperations(%s, %s, %s, \'%s\');\n", dest, right,left,vectorSize[rVal],  op);
			counter = atoi(vectorSize[rVal]);
			itoa(counter, num , 10);
		}
		markVector(dest,num);
	}
	else
	{
		cpyTokenVal(left, buff);
		cpyTokenVal(op, buff);
		cpyTokenVal(right, buff);
		strcpy(dest,buff);
		buff[0] = '\0';
		indice = 0;
	}

}  

//print Const vector
void printConstVector(char *vec, char* dest )
{
	//get only outer parts of vector
	const int size = strlen(vec);

	char *tmp = malloc(size*sizeof(char));
		for(int i = 0; i < size; i++){
		tmp[i] = ' ';
	}
	tmp[size] = '\0'; 

	int counter = 1;
	
	for(int i=1; i < size - 1; i++)
	{
		tmp[i-1] = vec[i];
		if(vec[i] == ',')
			counter++;
	}
	char num[11];
	itoa(cntTmpVec++,num, 10);
	strcpy(dest, "tmpVec");
	strcat(dest,num);
	num[0] = '\0';

	fprintf(yyout, "int %s[] = {%s};",dest, tmp);
	
	itoa(counter, num , 10);
	markVector(dest,num);
}


//print Indexing 
void printIndexing(char * leftHand, char * rightHand, char* dest)
{
	int right = isVector(rightHand);
	int left = isVector(leftHand);

	if(right == -1 && isTmpVecExist[0] == 0)
	{
		cpyTokenVal(leftHand, buff);
		cpyTokenVal("[", buff);
		cpyTokenVal(rightHand, buff);
		cpyTokenVal("]", buff);
	}
	else if(right != -1 || isTmpVecExist[0] == 1)
	{
		char * tmp = "indexArray(";
		cpyTokenVal(tmp, buff);
		cpyTokenVal(leftHand, buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(rightHand, buff);
		cpyTokenVal(",", buff);
		cpyTokenVal(vectorSize[left], buff);
		cpyTokenVal(")", buff);
		isTmpVecExist[0] = 1;
		isTmpVecExist[1] = atoi(vectorSize[left]);		
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
			fprintf(yyout, "\n\ttmp = %s;", rightHand);
			fprintf(yyout, "\n\tassignArrayToArray(%s, %d, tmp);\n", leftHand, isTmpVecExist[1]);
			fprintf(yyout, "\n\tfree(tmp);\n");

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
		
		fprintf(yyout, "\t\ttmp = %s;", name);
		fprintf(yyout, "\t\tprintArray(tmp, %d);\n", isTmpVecExist[1]);
		fprintf(yyout, "\t\tfree(tmp);\n");		
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

//nullify all global varible values after every line
void nullifyGlobals(){
	buff[0] = '\0';
	indice = 0;

	isTmpVecExist[0] = 0;
	isTmpVecExist[1] = 0;
	
}

//print free for all dynamic cast vectors
void printFreeVectors(){

	for(int i = 0; i < 256; i++){
		if(strncmp(vectorSymbol[i],"myTmpVec",8) == 0)
			fprintf(yyout, "\nfree(%s);\n", vectorSymbol[i]);
	}
}
//build C output building blocks
void buildFormat(FILE * out){

	fprintf(out, "#include <stdio.h>\n#include <stdlib.h>\n");

	//Modifying scalar to arrays assigment handling functions
	fprintf(out, "\nvoid assignScalarToArray(int * vec,int size, int scl)\n");
	fprintf(out , "{\nfor(int i=0; i< size; i++){\n\tvec[i] = scl;\n}\n}\n\n");
	
	//Modifing arrays to array assigment handling functions
	fprintf(out, "\nvoid assignArrayToArray(int * vec1,int size, int * vec2)\n");
	fprintf(out , "{\nfor(int i=0; i< size; i++){\n\tvec1[i] = vec2[i];\n}\n}\n");

	//Indexing vectors(arrays) handling functions
	fprintf(out, "\tint* indexArray(int *vec1, int * vec2, int size)\n{\n");
	fprintf(out, "\tint *tmp = malloc(sizeof(int)*size);\nfor(int i=0; i< size; i++){\n");
	fprintf(out , "\t\ttmp[i] = vec1[vec2[i]];\n}\n\treturn tmp;}\n\n");
	
	//Printing arrays handlind function
	fprintf(out, "\nvoid printArray(int * vec,int size)\n{\n");
	fprintf(out, "\tprintf(\"[\");\n");
	fprintf(out , "\n\tfor(int i=0; i< size-1; i++){\n\tprintf(\"%%d,\" ,vec[i]);\n}\n");
	fprintf(out, "\tprintf(\"%%d]\\n\", vec[size -1]);\n}\n\n");


	//Vector - vector handling function 
	fprintf(out,"\nint *twoVectorsOperations(int *vec1, int *vec2, int size, char op){\n");
	fprintf(out, "int *res = malloc(sizeof(int) * size);\nswitch (op)");
	fprintf(out,"\n{\tcase '+':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] + vec2[i];\t\t}\tbreak;\n");
	fprintf(out,"\n\tcase '-':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] - vec2[i];\t\t}\tbreak;\n");
	fprintf(out,"\n\tcase '*':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] * vec2[i];\t\t}\tbreak;\n");
	fprintf(out,"\n\tcase '/':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] / vec2[i];\t\t}\tbreak;}\nreturn res;}\n");

	//Vector - scalar handling function
	fprintf(out,"\nint *vectorScalarOperations(int *vec1, int scl, int size, char op){\n");
	fprintf(out, "int *res = malloc(sizeof(int) * size);\nswitch (op)");
	fprintf(out,"\n{\tcase '+':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] + scl;\t\t}\tbreak;\n");
	fprintf(out,"\n\tcase '-':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] - scl;\t\t}\tbreak;\n");
	fprintf(out,"\n\tcase '*':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] * scl;\t\t}\tbreak;\n");
	fprintf(out,"\n\tcase '/':\t\tfor (int i = 0; i < size; i++){\t\t\tres[i] = vec1[i] / scl;\t\t}\tbreak;}\nreturn res;}\n");

	//Dot product operation between  2 vectors or vector and scaalar handling function
	fprintf(out,"\nint dotProduct(int *vec1,int * vec2, int size, int scl){\n");
	fprintf(out, "int result = 0;\nfor (int i = 0; i < size; i++){\n");
	fprintf(out, "\tif(scl == -1)\nresult += vec1[i] * vec2[i];\nelse\nresult += vec1[i] * scl;\n}\nreturn result;\n}\n");
	


	fprintf(out , "\nint main(void)\n{\nint *tmp;\n");
	} 

// Main func
int main (int argc,char **argv) {

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
	printFreeVectors();
	fprintf(yyout, "\nreturn 0;\n}");
	return 0;
}

void yyerror (char *s) {fprintf (stderr, "%s\n", s);} 
