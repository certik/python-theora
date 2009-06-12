LIBTHEORA_PREFIX=/home/ondrej/usr

test: test.c
	gcc -I$(LIBTHEORA_PREFIX)/include -g -c -o test.o test.c
	gcc -L$(LIBTHEORA_PREFIX)/lib -o test test.o -ltheoradec -logg

clean:
	rm -f test.o test
