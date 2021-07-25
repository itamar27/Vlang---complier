#include <stdio.h>
#include <stdlib.h>

void assignScalarToArray(int *vec, int size, int scl)
{
	for (int i = 0; i < size; i++)
	{
		vec[i] = scl;
	}
}

void assignArrayToArray(int *vec1, int size, int *vec2)
{
	for (int i = 0; i < size; i++)
	{
		vec1[i] = vec2[i];
	}
}
int *indexArray(int *vec1, int *vec2, int size)
{
	int *tmp = malloc(sizeof(int) * size);
	for (int i = 0; i < size; i++)
	{
		tmp[i] = vec1[vec2[i]];
	}
	return tmp;
}

void printArray(int *vec, int size)
{
	printf("[");

	for (int i = 0; i < size - 1; i++)
	{
		printf("%d,", vec[i]);
	}
	printf("%d]", vec[size - 1]);
}

int main(void)
{
	int *tmp;
	int s1;
	int v1[3];
	int v2[3];
	int s2;
	s1 = 2;

	assignScalarToArray(v1, 3, s1);

	assignScalarToArray(v2, 3, 1);
	printf("%d\n", s1);
	printArray(v1, 3);

	return 0;
}