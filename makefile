calc.exe: lex.yy.c calc.tab.c
	gcc lex.yy.c calc.tab.c -o calc.exe

lex.yy.c: calc.tab.c calc.l
	flex calc.l

calc.tab.c: calc.y
	bison -d calc.y

clean: 
	del lex.yy.c calc.tab.c calc.tab.h calc.exe