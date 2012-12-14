--
-- Copyright © 2007 All Rights Reserved.
--

--
--- Display driver
--

module("Display", package.seeall)

local lgid="display"

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
		logf(LG_FTL, lgid, "Could not open display: %s", err)
	end

	-- resolution specific display settings

	local dpyinfo = {
		["128x64m"] = {
			native_font_size = 12,
			virtkbd_size = nil,	-- not enabled
		},
		["240x128m"] = {
			native_font_size = 12,
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
			logf(LG_DBG,lgid,"mode %s: display[%s]=%d",mode, k,v)
			display[k] = v
		end
	end

	display.w = w
	display.h = h

	display:set_font("arial.ttf", display["native_font_size"])

	-- sensible defaults:
	display:set_color("white")
	display:set_background_color("black")

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
		logf(LG_WRN, lgid, "No image fname given")
		return false
	end
	logf(LG_DBG,lgid,"draw_image(%s,%d,%d)", fname, xpos, ypos)
	local image_index, err = display.drv:draw_image(fname, xpos, ypos)
	if image_index == nil then
		logf(LG_WRN, lgid, "draw_image: %s", err)
		return nil
	end
	return image_index
end

local function invert( display, image_index )
	display.drv:invert( image_index )
end

local function draw_video(display, fname, w, h)
	if not fname then
		logf(LG_WRN, lgid, "No image fname given")
		return
	end
	local ok, err = display.drv:draw_video(fname, w, h)
	if not ok then
		logf(LG_WRN, lgid, "draw_video: %s", err)
	end
end


--
--- Show image data
--
-- @param fname Filename of the image to display
--

local function draw_image_blob(display, blob)
	local image_index, err = display.drv:draw_image(nil, blob)
	if image_index == nil then
		logf(LG_WRN, lgid, "draw_image: %s", err)
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
	logf(LG_DBG, lgid, "set_font( family=%s, size=%d )", family or "nil", size or 0 )
	display.font_family = family or display.font_family
	display.font_size = size or display.font_size
	display.font_attr = attr or display.font_attr

	local ok, err = display.drv:set_font(display.font_family, display.font_size, display.font_attr)
	if not ok then
		logf(LG_WRN, lgid, "set_font: %s", err)
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

	local w, h, x, y = display.drv:draw_text(buf)
	logf(LG_DBG,lgid,"txt='%s':w=%d,h=%d,x=%d,y=%d", buf,w,h,x,y)
	return w, h, x, y
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

local function get_rgb( v1, v2, v3 )
	if v1 and v2 and v3 then
		return v1, v2, v3
	end
	
	if colorcache[v1] == nil then

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
		
	end
	
	if colorcache[v1] then
		return colorcache[v1].r, colorcache[v1].g, colorcache[v1].b
	else
		logf(LG_WRN, lgid, "Color %s not found", tostring(v1))
		return nil,nil,nil
	end
	
end


-- set foreground color using rgb values or color string (eg "white")
local function set_color(display, v1, v2, v3)
	
	local r,g,b = get_rgb( v1, v2, v3 )
	logf(LG_DBG,lgid,"r=%d, g=%d, b=%d", (r or -1),(g or -1),(b or -1))
	if r ~= nil then
		display.drv:set_color(r,g,b)
	end

end


-- set background color using rgb values or color string (eg "black")
local function set_background_color(display, v1, v2, v3)
	
	local r,g,b = get_rgb( v1, v2, v3 )
	if r ~= nil then
		display.drv:set_background_color(r,g,b)
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
-- when layer == nil: clear all layers
--               0: clear text layer
--               1..17: image layer
--
local function clear(display, layer)
	logf(LG_DBG, lgid, "clear(layer=%d)", layer or -1)
	display.drv:clear(layer)
	if layer==nil then
		-- watch out: event is handled direct (as a function call, not queued)
		evq:push("display_clear",nil,-1)
	else
		evq:push("layer_clear", {layer=layer},-1)
	end
end


--
-- Update display
--

local function update(display, force)
	display.drv:update(force)
end

--
-- Format ia line of text (used by show message)
-- text        - the text
-- xpos,ypos   - the position in pixel coordinates
-- align_h     - 'l'|'c'|'r'|nil  this overrules xpos in case of 'c' or 'r'
-- align_v     - 't'|'m'|'b'|nil  this overrules ypos in case of 'm' or 'b'
-- size        - n,nil            font size in pixels, nil=use current
--
local function format_text(display, text, xpos, ypos, align_h, align_v, size)

	logf(LG_DBG,lgid,"format_text( xpos=%d, ypos=%d, align_h=%s, align_v=%s, size=%d )",xpos or 0, ypos or 0, align_h or 'nil', align_v or 'nil', size or display.font_size )
	if size then
		display.font_size = size;
		display.drv:set_font_size(display.font_size)
	end

	align_h = (align_h or "l"):sub(1, 1)
	align_v = (align_v or "t"):sub(1, 1)

	-- and now for each line in text
	local w=0
	local h=0
	local x=0
	local y=0
	local ll = string.split( text, "\n" )
	local n = #ll
	for i, l in pairs(ll) do

		local text_w, text_h = display:get_text_size(l)
		-- weird correction neccessary for right aligning text 
		-- (something to do with truncation errors????)
		text_w = (text_w or 0) + 1
		text_h = (text_h or 0)

		if align_h == "c" then xpos = display.w/2 - text_w / 2 end
		if align_h == "r" then xpos = display.w - text_w end
		if align_v == "m" then ypos = display.h/2 - n*text_h/2 + (i-1)*text_h end
		if align_v == "b" then ypos = display.h   - n*text_h   + (i-1)*text_h end

		logf(LG_DBG,lgid, "gotoxy(%d,%d)", xpos,ypos )
		display:gotoxy(xpos, ypos)
		local lw, lh
		lw, lh , x, y = display:draw_text(l)
		if lw>w then w = lw end
		h = h + lh

		if i ~= n and align_v ~= "m" and align_v ~= "b" then ypos = ypos + lh end
		
	end
	return w, h, x, y
end


--
-- display a message of (max) 6 lines (actual possible lines depends on the 
-- size of the font). All lines will be centered
--
local function show_message(display, msg1, msg2, msg3, msg4, msg5, msg6)
	display:gotoxy(0, 0);
	display:clear()
	local y = 10
	if msg1 then
		display:format_text(msg1, 0, y, "c", "")
		y = y + display.font_size
	end
	if msg2 then
		display:format_text(msg2, 0, y, "c", "")
		y = y + display.font_size
	end
	if msg3 then
		display:format_text(msg3, 0, y, "c", "")
		y = y + display.font_size
	end
	if msg4 then
		display:format_text(msg4, 0, y, "c", "")
		y = y + display.font_size
	end
	if msg5 then
		display:format_text(msg5, 0, y, "c", "")
		y = y + display.font_size
	end
	if msg6 then
		display:format_text(msg6, 0, y, "c", "")
		y = y + display.font_size
	end
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
		set_background_color = set_background_color,
		set_font = set_font,
		draw_image = draw_image,
		invert = invert,
		draw_video = draw_video,
		draw_image_blob = draw_image_blob,
		draw_text = draw_text,
		get_text_size = get_text_size,
		draw_box = draw_box,
		draw_filled_box = draw_filled_box,
		clear = clear,
		update = update,
	
		format_text = format_text,
		show_message = show_message,
	}

	local update_freq = display:open()
	logf(LG_DBG, lgid, "Display update frequency is %.1f hz", update_freq)

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
		local min = config:get("/dev/display/contrast_min")
		local max = config:get("/dev/display/contrast_max")
		contrast = min + contrast * (max-min)/4
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
	
