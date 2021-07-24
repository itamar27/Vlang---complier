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
	printf("%d]", vec[size -1]);
}

int main(void)
{
int *tmp;
	int v1[4];
	int v2[4];
	int v3[4];
	int s1;
	s1 = 1;
	v1[0] = 2;
	v1[1] = 4;
	v1[2] = 6;
	v1[3] = 8;
	v2[0] = 1;
	v2[1] = 1;
	v2[2] = 3;
	v2[3] = 2;
	printf("%d\n", v1[s1] );
	printArray(v2, 4);

tmp = indexArray(v1,v2,4);	printArray(tmp, 4);

free(tmp);
tmp = indexArray(v1,v2,4);
assignArrayToArray(v3, 4, tmp);

free(tmp);	printArray(v3, 4);

return 0;
}