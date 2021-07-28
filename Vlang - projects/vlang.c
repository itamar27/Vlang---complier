#include <stdio.h>
#include <stdlib.h>

void assignScalarToArray(int * vec,int size, int scl)
{
for(int i=0; i< size; i++){
	vec[i] = scl;
}
}


void assignArrayToArray(int * vec1,int size, int * vec2)
{
for(int i=0; i< size; i++){
	vec1[i] = vec2[i];
}
}
	int* indexArray(int *vec1, int * vec2, int size)
{
	int *tmp = malloc(sizeof(int)*size);
for(int i=0; i< size; i++){
		tmp[i] = vec1[vec2[i]];
}
	return tmp;}


void printArray(int * vec,int size)
{
	printf("[");

	for(int i=0; i< size-1; i++){
	printf("%d," ,vec[i]);
}
	printf("%d]\n", vec[size -1]);
}


int *twoVectorsOperations(int *vec1, int *vec2, int size, char op){
int *res = malloc(sizeof(int) * size);
switch (op)
{	case '+':		for (int i = 0; i < size; i++){			res[i] = vec1[i] + vec2[i];		}	break;

	case '-':		for (int i = 0; i < size; i++){			res[i] = vec1[i] - vec2[i];		}	break;

	case '*':		for (int i = 0; i < size; i++){			res[i] = vec1[i] * vec2[i];		}	break;

	case '/':		for (int i = 0; i < size; i++){			res[i] = vec1[i] / vec2[i];		}	break;}
return res;}

int *vectorScalarOperations(int *vec1, int scl, int size, char op){
int *res = malloc(sizeof(int) * size);
switch (op)
{	case '+':		for (int i = 0; i < size; i++){			res[i] = vec1[i] + scl;		}	break;

	case '-':		for (int i = 0; i < size; i++){			res[i] = vec1[i] - scl;		}	break;

	case '*':		for (int i = 0; i < size; i++){			res[i] = vec1[i] * scl;		}	break;

	case '/':		for (int i = 0; i < size; i++){			res[i] = vec1[i] / scl;		}	break;}
return res;}

int dotProduct(int *vec1,int * vec2, int size, int scl){
int result = 0;
for (int i = 0; i < size; i++){
	if(scl == -1)
result += vec1[i] * vec2[i];
else
result += vec1[i] * scl;
}
return result;
}

int main(void)
{
int *tmp;
	int x;
	int y;
	int i;
	int v1[6];
	int v2[6];
	int v3[6];
	x = 2;

assignScalarToArray(v1, 6, 2*x);
	printArray(v1, 6);
int myTmpVec0[] = {1,1,2,2,3,3  };
assignArrayToArray(v2, 6, myTmpVec0);
	printf("%d\n", dotProduct(v2,v1,6,-1) );
	y = v2[4];
	printf("%d\n", y );
	i = 0;
	for(int itr_i = 0; itr_i < y; itr_i++)
{
	v1[i] = i;
	i = i+1;
	}
	printArray(v1, 6);
	printArray(v2, 6);
int * myTmpVec1 = twoVectorsOperations(v1, v2, 6, '+');

assignArrayToArray(v3, 6, myTmpVec1);
	printArray(v3, 6);
int myTmpVec2[] = {2,1,0,2,2,0  };	printf("%d\n", v2[(dotProduct(v3,myTmpVec2,6,-1)/10)] );
	int a[3];
int myTmpVec3[] = {10,0,20  };
assignArrayToArray(a, 3, myTmpVec3);
	i = 0;
	for(int itr_i = 0; itr_i < 3; itr_i++)
{
int myTmpVec4[] = {1,0,0  };if(dotProduct(myTmpVec4,a,3,-1)){	printf("%d\n", i );
	printArray(a, 3);
int myTmpVec5[] = {2,0,1  };
	tmp = indexArray(a,myTmpVec5,3);
	assignArrayToArray(a, 3, tmp);

	free(tmp);
	}
	i = i+1;
	}
	int z[4];

assignScalarToArray(z, 4, 10);
int myTmpVec6[] = {2,4,6,8  };int * myTmpVec7 = twoVectorsOperations(z, myTmpVec6, 4, '+');
int * myTmpVec8 = vectorScalarOperations(myTmpVec7, 2, 4, '/');

assignArrayToArray(z, 4, myTmpVec8);
int * myTmpVec9 = vectorScalarOperations(z, 3, 4, '-');
int myTmpVec10[] = {2,3,4,5  };int * myTmpVec11 = twoVectorsOperations(myTmpVec9, myTmpVec10, 4, '+');

assignArrayToArray(z, 4, myTmpVec11);
	printArray(z, 4);
int myTmpVec12[] = {1,1,1,1  };	printf("%d\n", dotProduct(myTmpVec12,z,4,-1) );
	printf("%d\n", 1 );
	printArray(v2, 6);
int myTmpVec13[] = {1,1,1  };	printf("%d\n", v2[(1+2)] );
	printArray(myTmpVec13, 3);
	printf("%d\n", dotProduct(v1,v2,6,-1) );

return 0;
}