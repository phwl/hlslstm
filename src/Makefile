
CFLAGS= -p  

simple:	gen.h simple.cpp 
	g++ $(CFLAGS) -o simple simple.cpp -lm

test:	simple
	grep pred xsimple.out > /tmp/xsimple.out
	echo "testing simple ..."
	-(./simple | grep pred | sdiff -w80 /tmp/xsimple.out -)
	-rm -f /tmp/xsimple.out

gen.h:	xsimple.py lstmgen.py 
	python xsimple.py >xsimple.out

clean:
	-rm -rf *.o *.dSYM *.pyc gen xsimple.out gen.h gen_w.h gen_dotp.h gen_streamx.h gen_streamy.h gen_io.h simple.o simple __pycache__ *.data gen.cpp
