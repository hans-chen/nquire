--
-- Copyright © 2007 All Rights Reserved.
--

module("Touch16", package.seeall)

local lgid = "touch16"

-- only 1 touch keyboard possible; so we use a 'singleton':
local fd_touch16 = nil
local last_touch_timeout = 0

-- array [n] of released images:
-- 0  1  2  3
-- 4  5  6  7
-- 8  9  a  b
-- c  d  e  f
local key_image = {}

local function on_fd_touch16(event, self)

	if not fd_touch16 or event.data.fd ~= fd_touch16 then
		return
	end

	local value, code_touch, value_type = sys.read_input_event( fd_touch16 )
	--logf(LG_DMP,lgid,"on_fd_touch16(): value=%d, code(touch)=%d, type=%d", value or 0, code_touch or 0, value_type or 0)
	
	-- code: key [1..16], value: 0=release, 1=pressed
	if code_touch and value and code_touch > 0 and value == 1 then

		if sys.hirestime() < self.last_key_click_time + tonumber(config:get("/dev/touch16/minimum_click_delay")) then
			logf(LG_DMP,lgid,"prevented double click")
			return
		end

		self.last_key_click_time = sys.hirestime()

		-- change code because internal sorting is different form touch16 display
		local code = 16 - code_touch 
		
		local img = key_image[code] or ""

		if #img > 0 then
			beeper:play(config:get("/dev/touch16/" .. config:get("/dev/touch16/keyclick") ) )
			-- TODO: show pressed image of key a short while
		end

		if #img > 0 or config:get("/dev/touch16/send_active_keys_only") == "false" then
			logf(LG_DMP,lgid,"img='%s', send_active_keys_only=%s", img, config:get("/dev/touch16/send_active_keys_only"))
			cit:send_to_clients( config:get("/dev/touch16/prefix") .. string.format("%1x",code) .. img )
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

local function on_display_touch_image( event, touch16 )
	if event.data.spec == nil then return end
	logf(LG_DBG,lgid,"on_display_touch_image(data='%s')", event.data.spec)
	
	local released_img, pressed_img, pos, spec = event.data.spec:match( "^([%w-_]+.gif)\r([%w-_.]*)\r(%x)(%x+)$" )
	logf(LG_DBG,lgid,"release_img='%s', pressed_img='%s', pos=%s, spec=%s", (released_img or "nil"), (pressed_img or "nil"), (pos or "nil"), (spec or "nil"))

	if released_img == nil then
		logf(LG_WRN,lgid,"Incorrect data for display touch image. Command: '%s'", event.data.spec )
		return
	end
	
	local pos_n = tonumber("0x" .. pos)
	local x = pos_n % 4
	local y = (pos_n - x)/4
	--logf(LG_DBG,lgid,"pos_n=%d, pos_x=%d, pos_y=%d", pos_n, x, y)
	
	-- direct dependency from here to cit is allowed:
	if cit:display_image( released_img, x*60,y*32 ) then

		-- and couple image to key(s):
		for i=1,#spec do
			local key = tonumber("0x" .. spec:sub(i,i))
			key_image[key] = released_img
			logf(LG_DMP,lgid,"key_image[0x%x]='%s' (#table_size(key_image)=%d)", key, key_image[key], table_size(key_image))
		end
	
		-- disable idle message so it won't clear the screen
		cit.idle_message_is_disabled = true
	
		-- add touch16 idle timeout handling:
		evq:push("touch_timeout", nil, config:get("/dev/touch16/timeout"))
		last_touch_timeout = sys.hirestime()

	end
end


local function on_touch_timeout( event, touch16 )
	if sys.hirestime() - last_touch_timeout > tonumber(config:get("/dev/touch16/timeout")) and table_size(key_image)>0 then
		logf(LG_DBG,lgid,"Touch timeout. Returning to idle display.")
		
		display:clear() -- will result in on_display_clear()
		evq:push("cit_idle_msg", nil, 2)
		
		-- send timeout to server
		cit:send_to_clients( config:get("/dev/touch16/prefix") .. "T" )
	end
end


local function on_display_clear( event, touch16 )
	if table_size(key_image) > 0 then
		logf(LG_DBG,lgid,"End of keyboard input due to clear display.")
		key_image = {}
		cit.idle_message_is_disabled = false
	end
end

local function on_touch_break( event, touch16 )
	if table_size(key_image) > 0 then
		logf(LG_INF,lgid,"End of keyboard input due 'apply settings'.")
		-- send touch16-quit-event to server
		cit:send_to_clients( config:get("/dev/touch16/prefix") .. "Q" )
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
	evq:register("apply_settings", on_touch_break, self)

	-- not required: just boot when this changed!
	-- config:add_watch("/dev/touch16/device", "set", function(n,s) s:close() s:open() end, self)

	return true

end


--
-- Close touch16 keypad
--
local function close(self)
	if fd_touch16 ~= nil then
		evq:unregister("apply_settings", on_touch_break, self)
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
			logf(LG_DMP,lgid,"/sys/class/input/event0/device/name = '%s'", name)
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

