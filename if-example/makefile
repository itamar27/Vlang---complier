ifYacc.exe: lex.yy.c ifYacc.tab.c
	gcc -Wimplicit-function-declaration ifYacc.tab.c -o ifYacc.exe

lex.yy.c: ifYacc.tab.c ifYacc.l
	flex ifYacc.l

ifYacc.tab.c: ifYacc.y
	bison -d ifYacc.y

clean: 
	del lex.yy.c ifYacc.tab.c ifYacc.tab.h ifYacc.exe