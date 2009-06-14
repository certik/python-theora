LIBTHEORA_PREFIX=/home/ondrej/usr

all: test theora.so

test: test.c
	gcc -I$(LIBTHEORA_PREFIX)/include -g -c -o test.o test.c
	gcc -L$(LIBTHEORA_PREFIX)/lib -o test test.o -ltheoradec -logg

theora.so: theora.pyx
	cython theora.pyx
	gcc -I$(LIBTHEORA_PREFIX)/include -I/usr/include/python2.5 -I/usr/include/numpy -g -fPIC -c -o theora.o theora.c
	gcc -L$(LIBTHEORA_PREFIX)/lib -shared -o theora.so theora.o -ltheoradec -ltheoraenc -logg

clean:
	rm -f test.o test
	rm -f theora.c theora.so theora.o
