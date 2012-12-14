
all: batchcode.gif net.so sys.so sim300com

%.so: ../%.c
	gcc -shared $^ -o $@ `pkg-config --cflags --libs lua5.1` -DVERSION=\"\" -DBUILD=\"\" -lrt -lutil

batchcode.gif:
	../../app/tools/gen-batchcode

clean: 
	rm -f cit-discover batchcode.gif *.so sim300com


sim300com: sim300com.c
	/opt/toolchain-newland/bin/arm-softfloat-linux-gnueabi-gcc -g -Wall -O3 -Werror  -fPIC -I../toolchain/usr/include -I../toolchain/usr/include/SDL -I../toolchain/usr/include/freetype2 sim300com.c -o sim300com
