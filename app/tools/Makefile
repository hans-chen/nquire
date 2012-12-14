
all: batchcode.gif net.so sys.so

%.so: ../%.c
	gcc -shared $^ -o $@ `pkg-config --cflags --libs lua5.1` -DVERSION=\"\" -DBUILD=\"\" -lrt -lutil

batchcode.gif:
	../../app/tools/gen-batchcode

clean: 
	rm -f cit-discover batchcode.gif *.so
