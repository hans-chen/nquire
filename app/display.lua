--
-- Copyright © 2007 All Rights Reserved.
--

--
--- Display driver
--

module("Display", package.seeall)

--
--- Open display
--

local function open(display)

	local mode = config:get("/dev/display/mode")

	require("dpydrv")
	
	display.drv = dpydrv.new()
	local w, h, c = mode:match("(%d+)x(%d+)(.)")
	local update_freq, err = display.drv:open(w, h, c == 'c')

	if not update_freq then
		logf(LG_FTL, "display", "Could not open display: %s", err)
	end

	-- resolution specific display settings

	local dpyinfo = {
		["240x128m"] = {
			native_font_size = 8,
			virtkbd_size = nil,	-- not enabled
		},
		["320x160c"] = {
			native_font_size = 8,
			virtkbd_size = nil,	-- not enabled
		},
		["480x800c"] = {
			native_font_size = 18,
			virtkbd_size = 32,
		},
		["800x480c"] = {
			native_font_size = 18,
			virtkbd_size = 45,
		},
		["800x600c"] = {
			native_font_size = 20,
			virtkbd_size = 50,
		},
		["1024x768c"] = {
			native_font_size = 25,
			virtkbd_size = 64,
		},
		["1280x1024c"] = {
			native_font_size = 30,
			virtkbd_size = 80,
		},
	}

	local i = dpyinfo[mode]
	if i then
		for k,v in pairs(i) do
			display[k] = v
		end
	end

	display.w = w
	display.h = h

	display:set_font("arial.ttf", display.native_font_size)

	
	return update_freq
end


--
--- Close display
--

local function close(display)
	if display.drv then
		display.drv:close()
	end
end


--
--- Show image
--
-- @param fname Filename of the image to display
--

local function draw_image(display, fname, xpos, ypos)
	if not fname then
		logf(LG_WRN, "display", "No image fname given")
		return
	end
	local ok, err = display.drv:draw_image(fname, xpos, ypos)
	if not ok then
		logf(LG_WRN, "display", "draw_image: %s", err)
	end
end


local function draw_video(display, fname, w, h)
	if not fname then
		logf(LG_WRN, "display", "No image fname given")
		return
	end
	local ok, err = display.drv:draw_video(fname, w, h)
	if not ok then
		logf(LG_WRN, "display", "draw_video: %s", err)
	end
end


--
--- Show image data
--
-- @param fname Filename of the image to display
--

local function draw_image_blob(display, blob)
	local ok, err = display.drv:draw_image(nil, blob)
	if not ok then
		logf(LG_WRN, "display", "draw_image: %s", err)
	end
end


--
--- Set pen position for text drawing
--
-- @param x X position 
-- @param y Y position
--

local function gotoxy(display, x, y)
	display.drv:gotoxy(x,y)
end


--
--- Set font
--
-- @param name Filename of font
-- @param size Font size in pixels
--

local function set_font(display, family, size, attr)

	display.font_family = family or display.font_family
	display.font_size = size or display.font_size
	display.font_attr = attr or display.font_attr

	local ok, err = display.drv:set_font(display.font_family, display.font_size, display.font_attr)
	if not ok then
		logf(LG_WRN, "display", "set_font: %s", err)
	end
end



--
--- Draw text
--
-- @param fmt Format string or text to draw
-- @param ... Variables to be expanded if 'fmt' is a printf-like format string

local function draw_text(display, fmt, ...)
	local buf
	if #{...} > 0 then
		buf = fmt % {...}
	else
		buf = fmt
	end

	local w, h = display.drv:draw_text(buf)
	return w, h
end


local function get_text_size(display, fmt, ...)
	local buf
	if #{...} > 0 then
		buf = fmt % {...}
	else
		buf = fmt
	end

	local w, h = display.drv:draw_text(buf, true)
	return w, h
end


--
-- Set color. Given color can be a color name, a HEX color string or
-- three RGB values in the range 0.0 - 1.0. Colors values are cached
--

local colorcache = {}

local function set_color(display, v1, v2, v3, v4)
	
	if v1 and v2 and v3 then
		return display.drv:set_color(v1, v2, v3, v4)
	end
	
	if colorcache[v1] then
		return display.drv:set_color(colorcache[v1].r, colorcache[v1].g, colorcache[v1].b)
	end

	local r, g, b = v1:match("#(%x%x)(%x%x)(%x%x)")
	if r and g and b then
		colorcache[v1] = {}
		colorcache[v1].r = ("0x" .. r) / 256
		colorcache[v1].g = ("0x" .. g) / 256
		colorcache[v1].b = ("0x" .. b) / 256
	else
		local fd = io.open("/etc/X11/rgb.txt", "r")
		if fd then
			for l in fd:lines() do
				local name = v1:gsub(".", function(c)
					return "[" .. string.lower(c) .. string.upper(c) .. "]"
				end)
				local r, g, b = l:match("(%d+)%s+(%d+)%s+(%d+)%s+" .. name .. "$")
				if r and g and b then
					colorcache[v1] = {}
					colorcache[v1].r = r / 256
					colorcache[v1].g = g / 256
					colorcache[v1].b = b / 256
					break
				end
			end
			fd:close()
		end
	end
	
	if colorcache[v1] then
		return display.drv:set_color(colorcache[v1].r, colorcache[v1].g, colorcache[v1].b)
	else
		logf(LG_WRN, "display2", "Color %s not found", tostring(v1))
	end

end



local function draw_box(display, w, h, r)
	display.drv:draw_box(w, h, r)
end


local function draw_filled_box(display, w, h, r)
	display.drv:draw_filled_box(w, h, r)
end


--
--- Clear screen
--
-- @param what What to clear: 't'=text layer, 'i'=image layer, 'ti'=all layers
--

local function clear(display, what)
	display.drv:clear(what)
end


--
-- Update display
--

local function update(display, force)
	display.drv:update(force)
end

--
-- List available fonts
--

local function list_fonts(display)
	return display.drv:list_fonts()
end



--
-- Display update timer callback
--

local function on_display_timer(event, display)
	display:update()
	return true
end


--
--- Constructor. Creates a new display object and calls the 'init()' function
--

function new()

	local display = {

		-- data
		
		drv = nil,
		native_size = 8,  -- will be set by open()
		font_family = "Sans",
		font_size = 8,  
		font_attr = "",

		-- methods

		open = open,
		close = close,
		gotoxy = gotoxy,
		set_color = set_color,
		set_font = set_font,
		draw_image = draw_image,
		draw_video = draw_video,
		draw_image_blob = draw_image_blob,
		draw_text = draw_text,
		get_text_size = get_text_size,
		draw_box = draw_box,
		draw_filled_box = draw_filled_box,
		clear = clear,
		update = update,
		list_fonts = list_fonts,
	}

	local update_freq = display:open()
	logf(LG_DBG, "display", "Display update frequency is %.1f hz", update_freq)

	evq:register("display_timer", on_display_timer, display)
	evq:push("display_timer", display, 1.0 / update_freq)

	config:add_watch("/dev/display/mode", "set", 
		function(node, display)
			display:close()
			display:open()
		end,
	display)

	local function set_contrast()
		local contrast = config:get("/dev/display/contrast")
		contrast = 100 + contrast * 15
		local fd,err = io.open("/sys/class/display/display0/contrast", "w")
		if fd then
			fd:write(contrast)
			fd:close()
		else
			logf(LG_WRN, "Could not open display contrast driver: %s", err)
		end
	end

	config:add_watch("/dev/display/contrast", "set", set_contrast)
	set_contrast()

	return display
end

-- vi: ft=lua ts=3 sw=3
	
