parser: bflatlexer.lex
	bison -v -d --file-prefix=y bflatparser.y
	flex bflatlexer.lex
	g++ -o parser y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser