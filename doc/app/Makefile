
DOCS 	:= $(wildcard *.txt)

HTML 	:= $(subst .txt,.html,$(DOCS))

ALL	:= $(HTML)

.PHONY: img all clean clobber

all: img html

html: $(HTML)

clean:
	make -C img clean
	-rm -f $(ALL) *.out *.log *.idx *.tex *.aux

clobber: clean
	make -C img clobber
	-rm -f *~

img:
	make -C img

%.html: %.txt 
	asciidoc -a toc -a numbered $^

