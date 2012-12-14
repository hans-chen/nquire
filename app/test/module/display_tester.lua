#!/usr/bin/lua

package.path = "../?.lua;./?.lua;module/?.lua"

require "dpydrv"
require "sys"

require "tester"
th = Tester.new()

-- helper functions


local function open(width,height, font)
	if not width then width = 10 end
	if not height then height = 10 end

	print("Open driver")
	drv = dpydrv.new()
	local update_freq, err = drv:open(width,height, false)
	drv:set_font(font or "../arial.ttf", 12, "")
	drv:set_color(1,1,1)
	drv:set_background_color(0,0,0)
	drv:update(true)

end


local function update( n, delay )
	while n>0 do
		drv:update(true)
		sys.sleep(delay)
		n=n-1
	end
end


local function dump( )
	return drv:dump():gsub("000000ff", "."):gsub("ffffffff","X")
end


local function close()
	print("Close driver")
	drv:close()
	drv=nil
end


-- test functions:

local function test_dpydrv_new()
	local drv = dpydrv.new()
end


local function test_dpydrv_open_close()
	local drv = dpydrv.new()
	local update_freq, err = drv:open(10,10, false)
	drv:close()
end

local function test_set_font_color_background()
	local drv = dpydrv.new()
	local update_freq, err = drv:open(10,10, false)
	drv:set_font(font or "../arial.ttf", 12, "")
	drv:set_color(1,1,1)
	drv:set_background_color(0,0,0)
	drv:close()
end

local function test_clear_screen_1()
	open(2,2)
	drv:clear()
	close()
end

local function test_clear_screen()

	open(2,2)
	drv:set_color(1,1,1)
	drv:set_background_color(0,0,0)
	drv:clear()
	drv:update(true)
	print(dump())
	
	drv:set_background_color(1,1,1)
	drv:set_color(0,0,0)
	drv:clear()
	drv:update(true)
	print(dump())

	close()
	
end



function test_image_clipping_and_transparency()

	print("Show an image just outside screen")
	open(8,8)
	drv:draw_image("img/black_and_white4x4.gif", 2,2)
	drv:draw_image("img/white4x4.gif", -2,-2)
	drv:draw_image("img/white4x4.gif", 6,-2)
	drv:draw_image("img/white4x4.gif", 6,6)
	drv:draw_image("img/white4x4.gif", -2,6)
	drv:draw_image("img/transparent-blue4x4.gif", 2,2)
	drv:update(true)
	print(dump())
	close()

end


function test_image_clipping_for_image_too_big()

	print("Load an image that is too big for the screen")
	open(2,2)
	drv:draw_image("img/white4x4.gif", 0,0 )
	drv:update(true)
	print(dump())
	drv:clear()
	drv:draw_image("img/black4x4.gif", 0,0 )
	drv:update(true)
	print(dump())
	drv:clear()
	drv:draw_image("img/white4x4.gif", -1,-1 )
	drv:update(true)
	print(dump())
	drv:clear()
	drv:draw_image("img/white4x4.gif", 1,1 )
	drv:update(true)
	print(dump())
	close()

end


function test_text()

	open(12,12)
	
	drv:set_font_size(12)
	drv:gotoxy(0,0)
	w,h,x,y = drv:draw_text("Hi")
	print("w=" .. w, "h=" .. h, "x=" .. x, "y=" ..y)
	drv:update(true)
	print(dump())

	drv:clear()
	drv:set_font_size(6)
	drv:gotoxy(0,0)
	w,h,x,y = drv:draw_text("Hi\nthere")
	print("w=" .. w, "h=" .. h, "x=" .. x, "y=" ..y)
	drv:update(true)
	print(dump())

	close()

end


function test_fonts()
	
	for fontnr=1,4 do
		local fontsize = 6 * fontnr
		open(fontsize*1.5,fontsize+2, "../arialuni.ttf")
	
		drv:set_font_size(fontsize)
		drv:gotoxy(0,0)
		w,h,x,y = drv:draw_text("欲Ih")
		print("w=" .. w, "h=" .. h, "x=" .. x, "y=" ..y)
		drv:update(true)
		print(dump())

		close()
	end
end

function test_welcome_gif()

	open( 220, 100 )

	drv:clear()
	drv:draw_image("img/welcome-please-scan.gif", -1,-1 )
	for j=1,20 do
		drv:update(true)
		os.execute("sleep .5")
	end	

	drv:clear()
	drv:draw_image("img/welcome-bij-dio.gif", -1,-1 )
	for j=1,20 do
		drv:update(true)
		os.execute("sleep .5")
	end	

	drv:clear()
	drv:draw_image("img/welcome-bij-mooi.gif", -1,-1 )
	for j=1,20 do
		drv:update(true)
		os.execute("sleep .5")
	end	
	drv:clear()
	drv:draw_image("img/welcome-touch.gif", -1,-1 )
	for j=1,20 do
		drv:update(true)
		os.execute("sleep .5")
	end	
	
	close()

end


function test_invert()

	open(8,8)

	local l1 = drv:draw_image("img/white4x4.gif", 0,0 )
	local l2 = drv:draw_image("img/black4x4.gif", 4,4 )
	print("layer(image1)=" .. l1 )
	print("layer(image2)=" .. l2 )
	drv:update(true)
	print(dump())

	drv:invert(l1)
	drv:update(true)
	print(dump())

	drv:invert(l2)
	drv:update(true)
	print(dump())

	drv:invert(l1)
	drv:update(true)
	print(dump())

	drv:invert(l2)
	drv:update(true)
	print(dump())

	close()

end

th:run( test_dpydrv_new, "test_dpydrv_new" )
th:run( test_dpydrv_open_close, "test_dpydrv_open_close" )
if arg[1] ~= "--min" then
	th:run( test_set_font_color_background, "test_set_font_color_background" )
	th:run( test_clear_screen_1, "test_clear_screen_1" )

	th:run( test_clear_screen, "test_clear_screen" )
	th:run( test_image_clipping_and_transparency, "test_image_clipping_and_transparency" )
	th:run( test_text, "test_text" )
	th:run( test_fonts, "test_fonts" )
	th:run( test_image_clipping_for_image_too_big, "image_too_big" )
	th:run( test_invert, "invert" )
end
--th:run( test_welcome_gif, "test_welcome_gif" )

print("End")

