all = lisp

lisp.tab.c lisp.tab.h: lisp.y
	bison -d lisp.y

lex.yy.c: lisp.l lisp.tab.h
	flex lisp.l

lisp:	lex.yy.c lisp.tab.c lisp.tab.h
	gcc lisp.tab.c lex.yy.c -lm -o lisp

clean:
	rm lisp lisp.tab.c lex.yy.c lisp.tab.h
