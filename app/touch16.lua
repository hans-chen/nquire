--
-- Copyright © 2007 All Rights Reserved.
--

--
-- This module spawns "touch16" events with event.data = 
-- {type=="key", key="%x", tag="<tag>"} => a key is pressed
-- {type=="activated"}      => the touch16 'keypad' is activated
-- {type=="deactivated"}    => the touch16 'keypad' is deactivated
-- {type=="deactivated", cause="timeout"}    => the touch16 'keypad' is deactivated because to prolonged inactivity
--

module("Touch16", package.seeall)

local lgid = "touch16"

-- only 1 touch keyboard possible; so we use a 'singleton':
local fd_touch16 = nil
local last_touch_timeout = 0

-- array [n] of keys coupled to an image:
-- 0  1  2  3
-- 4  5  6  7
-- 8  9  a  b
-- c  d  e  f
-- key_to_tag[<key num>] = <tag>
local key_to_tag = {}

-- tag_to_image[<tag>].layer
-- tag_to_image[<tag>].released_img
-- tag_to_image[<tag>].pressed_img
-- tag_to_image[<tag>].inverted
local tag_to_image = {}

local function on_fd_touch16(event, self)

	if not fd_touch16 or event.data.fd ~= fd_touch16 then
		return
	end

	local value, code_touch, value_type = sys.read_input_event( fd_touch16 )
	logf(LG_DMP,lgid,"on_fd_touch16(): value=%d, code(touch)=%d, type=%d", value or 0, code_touch or 0, value_type or 0)
	
	-- code: key [1..16], value: 0=release, 1=pressed
	if code_touch and value and code_touch > 0 and value == 1 then

		if sys.hirestime() < self.last_key_click_time + tonumber(config:get("/dev/touch16/minimum_click_delay")) then
			logf(LG_DBG,lgid,"prevented double click")
			return
		end

		self.last_key_click_time = sys.hirestime()

		-- change code because internal sorting is different form touch16 display
		local code = 16 - code_touch 
		
		local tag = key_to_tag[code]

		if tag then
			beeper:play(config:get("/dev/touch16/" .. config:get("/dev/touch16/keyclick")))
			-- TODO: show pressed image of key a short while
			
			if not tag_to_image[tag].inverted then
				tag_to_image[tag].inverted = true
				if config:get("/dev/touch16/invert") == "true" then
					display:invert( tag_to_image[tag].layer )
					display:update( true )
					evq:push("touch_invert", { image_tag = tag } , 0.1)
				end
			end
			
		end

		if tag or config:get("/dev/touch16/send_active_keys_only") == "false" then
			logf(LG_DBG,lgid,"tag='%s', send_active_keys_only=%s", (tag or "nil"), config:get("/dev/touch16/send_active_keys_only"))
			local keytag = { type="key", key = string.format("%1x",code) }
			if tag then keytag.tag = tag end
			evq:push("touch16", keytag )
			last_touch_timeout = sys.hirestime()
			evq:push("touch_timeout", nil, config:get("/dev/touch16/timeout"))
		end
	end
	
end

function table_size(t)
	local c = 0
	for _,_ in pairs(t) do c = c + 1 end
	return c
end

-- display an image and associate to a touch-key
-- event.data.search_path
-- event.data.gif_released
-- event.data.gif_pressed
-- event.data.key_pos
-- event.data.keys
local function on_display_touch_image( event, touch16 )
	if event.data == nil then return end
	
	logf(LG_DBG,lgid,"on_display_touch_image( searchpath='%s', gif_released='%s', key_pos='%s', keys='%s' )", 
			(event.data.search_path or "nil"),
			(event.data.gif_released or "nil"),
			(event.data.key_pos or "nil"),
			(event.data.keys or "nil"))
	
	local tag = event.data.tag or event.data.gif_released
	local released_img = find_file(event.data.gif_released,event.data.search_path)
	if not released_img then
		logf(LG_WRN,lgid,"Released image '%s' not found", event.data.gif_released or "nil")
	end
		
	local pressed_img = "" -- find_file(event.data.gif_pressed,event.data.search_path)
	local pos_n = tonumber("0x" .. event.data.key_pos)
	local spec = event.data.keys:match( "^(%x+)$" )
	
	logf(LG_DBG,lgid,"release_img='%s', pressed_img='%s', pos_n=%x, spec=%s", (released_img or "nil"), (pressed_img or "nil"), (pos_n or "nil"), (spec or "nil"))

	if released_img == nil or pressed_img == nil or pos_n==nil or spec==nil then
		logf(LG_WRN,lgid,"Incorrect data for display touch image. Command: '%s'", event.data.spec or "nil" )
		return
	end
	
	local x = pos_n % 4
	local y = (pos_n - x)/4
	--logf(LG_DBG,lgid,"pos_n=%d, pos_x=%d, pos_y=%d", pos_n, x, y)
	
	local img_file = released_img
	local img_layer, err = display:draw_image( img_file, x*60, y*32 )
	if img_layer == nil then
		logf(LG_WRN, lgid, "Could not draw %s: %s", img_file, err)
	elseif img_file and img_layer then
		tag_to_image[tag] = {}
		tag_to_image[tag].layer = img_layer
		tag_to_image[tag].released_img = released_img
		tag_to_image[tag].pressed_img = pressed_img
		local nr_of_images = table_size(tag_to_image)
		logf(LG_DBG,lgid,"tag_to_image['%s'].released_img='%s' (#table_size(tag_to_image)=%d)", tag, tag_to_image[tag].released_img, nr_of_images)

		-- and couple image to key(s):
		for i=1,#spec do
			local key = tonumber("0x" .. spec:sub(i,i))
			key_to_tag[key] = tag
			
			logf(LG_DBG,lgid,"key_to_tag[0x%x]='%s' (#table_size(key_to_tag)=%d)", key, key_to_tag[key], table_size(key_to_tag))
		end
	
		if nr_of_images == 1 then
			evq:push("touch16", { type="activated" })
		end
	
		-- touch16 idle timeout handling:
		evq:push("touch_timeout", nil, config:get("/dev/touch16/timeout"))
		last_touch_timeout = sys.hirestime()

	end
end


local function on_touch_timeout( event, touch16 )
	if sys.hirestime() - last_touch_timeout > tonumber(config:get("/dev/touch16/timeout")) 
			and table_size(key_to_tag)>0 then
		logf(LG_DBG,lgid,"Touch timeout. Returning to idle display.")

		-- prevent 'deactivated' message in on_display_clear():
		key_to_tag = {}
		tag_to_image = {}

		display:clear() -- will result in on_display_clear()
		evq:push("touch16", { type="deactivated", cause="timeout" }, -1)
	end
end


local function on_display_clear( event, touch16 )
	if table_size(key_to_tag) > 0 then
		logf(LG_DBG,lgid,"End of keyboard input due to clear display.")
		key_to_tag = {}
		tag_to_image = {}
		evq:push("touch16", { type="deactivated" }, -1 )
	end
end



local function on_touch_invert( event, touch16 )
	local image_data = tag_to_image[event.data.image_tag]
	
	if image_data and image_data.inverted then
			
		display:invert(image_data.layer)
		image_data.inverted = nil
		display:update( true )
		
	end
end


--
-- Open the touch16 device
--
local function open(self)

	if not Touch16.is_available() then
		return false
	end
	
	if fd_touch16 then
		-- already open
		return true
	end

	local dev = config:get("/dev/touch16/device")
	local fd = sys.open( dev, "r" )

	if fd == nil then
		logf(LG_WRN,lgid,"No touch keyboard device found.")
		return false
	end
	
	fd_touch16 = fd

	-- turn off /dev/tty0 event spawning.
	sys.ioctl_keypad(fd_touch16, 1)

	evq:fd_add(fd_touch16)
	evq:register("fd", on_fd_touch16, self)

	evq:register("display_touch_image", on_display_touch_image, self)
	evq:register("display_clear", on_display_clear, self)
	evq:register("touch_timeout", on_touch_timeout, self)
	evq:register("touch_invert", on_touch_invert, self)

	-- not required: just boot when this changed!
	-- config:add_watch("/dev/touch16/device", "set", function(n,s) s:close() s:open() end, self)

	return true

end


--
-- Close touch16 keypad
--
local function close(self)
	if fd_touch16 ~= nil then
		evq:unregister("touch_invert", on_touch_invert, self)
		evq:unregister("touch_timeout", on_touch_timeout, self)
		evq:unregister("display_clear", on_display_clear, self)
		evq:unregister("display_touch_image", on_display_touch_image, self)

		-- turn on /dev/tty0 event spawning
		sys.ioctl_keypad(fd_touch16, 0)

		evq:unregister("fd", on_fd_touch16, self)
		evq:fd_del( fd_touch16 )
		sys.close( fd_touch16 )
		fd_touch16 = nil
	end
end


--
-- is hardware available
--
function is_available()

	return config:get("/dev/touch16/name") ~= ""
	
end


--
-- event function handling a get of "/dev/touch16/name"
--
local function on_get_touch16_name(node)
	local name = ""
	
	local fd = io.open("/sys/class/input/event0/device/name","r")
	if fd then
		name = fd:read("*l")
		if name:find( "AT42QT2160" ) then
			logf(LG_DBG,lgid,"/sys/class/input/event0/device/name = '%s'", name)
		else
			name = ""
		end
		fd:close()
	end
	
	node:setraw(name)
end


--
-- Constructor
--
function new()

	local self = {

		open = open,
		close = close,
		
		is_active = function () return table_size(key_to_tag)>0 end,

		last_key_click_time = 0,

	}

	config:add_watch( "/dev/touch16/name", "get", on_get_touch16_name, self)

	if not is_available() then
		return nil
	end

	logf(LG_INF, lgid, "HW found: %s", config:get("/dev/touch16/name"))

	return self
end

-- vi: ft=lua ts=3 sw=3

