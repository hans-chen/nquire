
SVG = 

ALL	:= $(SVG:.svg=.png)

all: $(ALL)

%.png: %.svg
	inkscape --export-png=$@ $^

clean:
	rm -f $(ALL)

clobber: clean
