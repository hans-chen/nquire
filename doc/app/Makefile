
DOCS 	:= $(wildcard *.txt)

HTML 	:= $(subst .txt,.html,$(DOCS))

ALL	:= $(HTML)

.PHONY: img all clean clobber

all: img html nquire-tests.pdf

html: $(HTML)

clean:
	make -C img clean
	-rm -f $(ALL) *.out *.log *.idx *.tex *.aux nquire-tests.pdf

clobber: clean
	make -C img clobber
	-rm -f *~

img: 
	make -C img

nquire-tests.pdf: nquire-tests.odt
	unoconv -f pdf $(@:pdf=odt)

$(HTML): Makefile
%.html: %.txt
	asciidoc --verbose -a toc -a numbered -a icons -a iconsdir=./img $(@:html=txt)

SHELL = /bin/bash
deploy: deploy_root_files = $(shell echo $(wildcard *html) | sed "s/ /,/g"),nquire-tests.pdf
deploy: deploy_img_files = $(shell echo $(wildcard img/*png) | sed "s/ /,/g")
deploy:
	make clean
	make all
	# you need curl compiled with configure option (this is not the default): --with-libssh2
	# To do this: 
	# verify that libssh dev is installed (otherwise: sudo apt-get install libssh2-1 libssh2-1-dev)
	# download curl from http://curl.linux-mirror.org
	# tar xzvf curl-*.tar.gz
	# cd curl*
	# ./configure --with-libssh2
	# make
	# make test    (optional)
	# sudo make prefix=/usr install
	curl -v --user newland-ftp:Secret314 sftp://server.mbarc.nl/home/newland-ftp/nquire/doc/app/ -T "{$(deploy_root_files)}"
	curl -v --user newland-ftp:Secret314 sftp://server.mbarc.nl/home/newland-ftp/nquire/doc/app/img/ -T "{$(deploy_img_files)}"

