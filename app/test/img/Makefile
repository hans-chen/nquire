
all: anim.gif special.gif

clean:
	-rm -f anim.gif

clobber: clean

anim.gif : anim[12345678].gif Makefile
	gifsicle -l --delay=10 anim[12345678].gif anim7.gif anim6.gif anim5.gif anim4.gif anim3.gif anim2.gif > anim.gif
	
special.gif: special-[12].gif Makefile
	gifsicle -l --delay=100 special-1.gif --delay=50 special-2.gif > special.gif


