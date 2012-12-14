all: kitty.gif

clean:
	-rm -f kitty.gif

clobber: clean

kitty.gif : kitty[01].gif
	gifsicle -l --delay=5 kitty1.gif kitty2.gif > $@

