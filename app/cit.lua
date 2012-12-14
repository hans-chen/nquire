--
-- Copyright © 2007. All Rights Reserved.
--

module("CIT", package.seeall)

require "cit-codepages"

local dpy_w = 240
local dpy_h = 128

local font = "arial.ttf"
-- local font = "arialuni.ttf"
-- local font = "wqy-zenhei.ttf"
-- local font = "wt011.ttf"
-- local font = "wt028.ttf"

local fontsize_small = 24
local fontsize_big = 32

local fontsize = fontsize_small

local pixel_x = 0
local pixel_y = 0

local align_h = "l"
local align_v = "t"

local message_received = false

local t_lastcmd = 0

--
-- Translate string to given codepage
--

local function to_utf8(text, page)

	local xlat = codepage_to_utf8[page]

	if xlat then
		local out = {}
		for _, c in ipairs( { string.byte(text, 1, #text) } ) do
			if c ~= 0 then
				out[#out+1] = xlat[c] or c
			end
		end
		local out = table.concat(out, "")
		return out
	else
		return text
	end
end


---------------------------------------------------------------------------
-- Formatted text to display
---------------------------------------------------------------------------

local function format_text(text, xpos, ypos, align_h, align_v, size)

	align_h = align_h:sub(1, 1)
	align_v = align_v:sub(1, 1)
	if size == "small" then size = fontsize_small end
	if size == "large" then size = fontsize_big end

	if align_h == "c" then xpos = dpy_w/2 end
	if align_h == "r" then xpos = dpy_w end
	if align_v == "m" then ypos = dpy_h / 2 end
	if align_v == "b" then ypos = dpy_h end

	display:set_font(font, size)
	local text_w, text_h = display:get_text_size(text)

	if align_h == "c" then xpos = xpos - text_w / 2 end
	if align_h == "r" then xpos = xpos - text_w end
	if align_v == "m" then ypos = ypos - (text_h+2) / 2 end
	if align_v == "b" then ypos = ypos - (text_h+2) end

	display:gotoxy(xpos, ypos)
	display:draw_text(text)

end


local function show_configuration()

	local keys = {
		"/dev/name",
		"/dev/version",
		"/dev/build",
		"/network/current_ip",
		"/network/interface",
		"/network/macaddress",
		"/dev/display/contrast",
		"/dev/beeper/beeptype",
		"/dev/beeper/volume",
	}

	display:gotoxy(0, 0);
	display:set_color("black")
	display:clear()
	display:set_color("white")

	y = 1
	for _, key in ipairs(keys) do
		local node = config:lookup(key)
		format_text(node.label .. ": " .. node:get(), 1, y, "", "", 13)
		y = y + 14
	end

	logf(LG_DMP,"cit","Initiating cit_idle_msg in 10 seconds")
	evq:push("cit_idle_msg", nil, 10.0)
end


---------------------------------------------------------------------------
-- CIT protocol handling
---------------------------------------------------------------------------


local function handle_barcode_normal(barcode, prefix)

	-- Send to UDP remote server

	local sock = net.socket("udp")
	local addr = config:get("/cit/remote_ip")
	local port = config:get("/cit/udp_port")
	net.sendto(sock, prefix .. barcode .. "\n", addr, port)
	net.close(sock)

	-- Send to all connected TCP clients
	
	for client,_ in pairs(cit.client_list) do
		local enable_prefix = config:get("/dev/scanner/enable_barcode_id")
		if enable_prefix == "true" then
			net.send(client.sock, prefix .. barcode .. "\n")
		else
			net.send(client.sock, barcode .. "\n")
		end
	end

	-- Register timer to show error message if no data received in time

	message_received = false
	local timeout = tonumber(config:get("/cit/messages/error/timeout"))
	evq:push("cit_error_msg", nil, timeout)

end


local next_barcode_is_serial = false

local function handle_barcode_programming(barcode, prefix)

	if next_barcode_is_serial then
		if barcode then
			logf(LG_INF, "cit", "Programming product serial number: %s", barcode)
			config:lookup("/dev/serial"):set(barcode)
		end
		next_barcode_is_serial = false
	end

	-- Barcodes 020300 to 020305 set the beeper volume

	local tmp = barcode:match("^0203(..)")
	if tmp then 
		logf(LG_INF, "cit", "Scanned 'beeper volume' barcode, set volume to %s", tmp)
		config:set("/dev/beeper/volume", tonumber(tmp), true)
	end

	-- Barcodes 020401 to 020403 set the beeper sound type

	local tmp = barcode:match("^0204(..)")
	if tmp then 
		logf(LG_INF, "cit", "Scanned 'beeper sound type' barcode, set sound type to %s", tmp)
		config:set("/dev/beeper/beeptype", tonumber(tmp) + 1, true) 
	end
	
	-- Barcodes 020501 to 020504 set the display contrast

	local tmp = barcode:match("^0205(..)")
	if tmp then 
		logf(LG_INF, "cit", "Scanned 'display contrast' barcode, set contrast to %s", tmp)
		config:set("/dev/display/contrast", tonumber(tmp), true) 
	end

	-- Extra codes for reboot and factory defaults
	
	local tmp = barcode:match("^0207(..)")
	if tmp then 
		if tmp == "00" then
			logf(LG_INF, "cit", "Scanned 'reboot' barcode, rebooting system");
			os.execute("reboot")
		end
		if tmp == "01" then
			logf(LG_INF, "cit", "Scanned 'factory defaults' barcode, restoring and rebooting system");
			os.execute("rm -f cit.conf")
			os.execute("reboot")
		end
		if tmp == "02" then
			show_configuration()
		end
		if tmp == "04" then
			next_barcode_is_serial = true
		end
	end
	
end


--
-- Handle scanned barcode. This is a 2-state statemachine for switching between
-- normal 'operational' mode and 'programming' mode
--

local barcode_mode = "normal"


local function on_barcode(event, cit)

	local barcode = event.data.barcode or "?"
	local prefix = event.data.prefix or "?"

	led:set("yellow", "off")

	if barcode_mode == "normal" then
		if barcode == "%#$^*%" then
			logf(LG_INF, "cit", "Scanned 'programming mode' barcode")
			barcode_mode = "programming"
		else
			handle_barcode_normal(barcode, prefix)
		end
	elseif barcode_mode == "programming" then
		if barcode == "%*^$#%" then
			barcode_mode = "normal"
			logf(LG_INF, "cit", "Scanned 'normal mode' barcode")
		else
			handle_barcode_programming(barcode, prefix)
		end
	end
		
	local tune = config:get("/dev/beeper/beeptype") or "1"
	local tune = config:get("/dev/beeper/tune_" .. tune)
	beeper:play(tune)
	
	led:set("yellow", "on")

end



-- Note. The booklet with CIT protocol description is ambigious on the 'clear
-- display' command. The examples use command 0x24, but the command list uses
-- command 0x25. To be sure, both are implemented here

local command_list = {
	
	[0x24] = {
		name = "clear screen",
		nparam = 0,
		fn = function(cit)
			display:gotoxy(0, 0);
			display:set_color("black")
			display:clear()
			display:set_color("white")
			pixel_x = 0
			pixel_y = 0
			align_h = "l"
			align_v = "t"
		end
	},

	[0x25] = {
		name = "clear screen",
		nparam = 0,
		fn = function(cit)
			display:gotoxy(0, 0);
			display:set_color("black")
			display:clear()
			display:set_color("white")
			pixel_x = 0
			pixel_y = 0
			align_h = "l"
			align_v = "t"
		end
	},

	[0x27] = {
		name = "set cursor position",
		nparam = 2,
		fn = function(cit, x, y)
			pixel_x = (x - 0x30) * 8
			pixel_y = (y - 0x30) * fontsize
		end
	},

	[0x2c] = {
		name = "set pixel position",
		nparam = 2,
		fn = function(cit, x, y)
			pixel_x = x - 0x30
			pixel_y = y - 0x30
		end
	},

	[0x2e] = {
		name = "align string of text",
		nparam = 26,
		fn = function(cit, pos, ...)
		
			local align = {
				[0x30] = { 0,       0,       "l", "t" },
				[0x31] = { dpy_w/2, 0,       "c", "t" },
				[0x32] = { dpy_w,   0,       "r", "t" },
				[0x33] = { 0,       dpy_h/2, "l", "m" },
				[0x34] = { dpy_w/2, dpy_h/2, "c", "m" },
				[0x35] = { dpy_w,   dpy_h/2, "r", "m" },
				[0x36] = { 0,       dpy_h,   "l", "b" },
				[0x37] = { dpy_w/2, dpy_h,   "c", "b" },
				[0x38] = { dpy_w,   dpy_h,   "r", "b" },
				[0x39] = { 0,       nil,     "l", nil },
				[0x3a] = { dpy_w/2, nil,     "c", nil },
				[0x3b] = { dpy_w,   nil,     "r", nil },
				[0x3c] = { nil,     0,       nil, "t" },
				[0x3d] = { nil,     dpy_h/2, nil, "m" },
				[0x3e] = { nil,     dpy_h,   nil, "b" },
			}
	
			if align[pos] then
				align_h = align[pos][3] or align_h
				align_v = align[pos][4] or align_v
			end

			local text = string.char(...)
			text = to_utf8(text, cit.codepage)
			format_text(text, pixel_x, pixel_y, align_h, align_v, fontsize)
		end
	},

	[0x40] = {
		name = "sleep",
		nparam = 0,
		fn = function(cit)
		end
	},

	[0x41] = {
		name = "wakeup",
		nparam = 0,
		fn = function(cit)
		end
	},

	[0x42] = {
		name = "select font set",
		nparam = 1,
		fn = function(cit, f)
			if f == 0x30 then
				fontsize = fontsize_small
			end
			if f == 0x31 then
				fontsize = fontsize_big
			end
			display:set_font(font, fontsize)
		end
	},

	[0x5a] = {
		name = "soft reset",
		nparam = 0,
		fn = function(cit)
			logf(LG_WRN, "cit", "Reset not implemented")
			os.execute("reboot")
		end
	},

	[0x5b] = {
		name = "enable/disable scanning",
		nparam = 1,
		fn = function(cit, onoff)
			if onoff == 0x30 then
				scanner:disable()
			end
			if onoff == 0x31 then
				scanner:enable()
			end
		end
	},

	[0x5c] = {
		name = "enable/disable backlight",
		nparam = 1,
		fn = function(cit, onoff)
			logf(LG_WRN, "cit", "Backlight enable/disable not implemneted")
		end
	},

	[0x5d] = {
		name = "slaap/wakeup barcode scanner",
		nparam = 1,
		fn = function(cit, onoff)
			if onoff == 0x30 then
				scanner:disable()
			end
			if onoff == 0x31 then
				scanner:enable()
			end
		end
	},

	[0x5e] = {
		name = "beep",
		nparam = 0,
		fn = function(cit)
			beeper:play("o3c16g16")
		end
	},

	[0x5f] = {
		name = "get firmware version",
		nparam = 0,
		fn = function(cit)
			logf(LG_WRN, "cit", "Returning data not yet implmenented")
			return config:get("/info/version/version")
		end
	},

	[0x7E] = {
		name = "Set GPIO output",
		nparam = 2,
		fn = function(cit, nr, state)
			nr = nr - 0x30 
			state = state - 0x30
			logf(LG_INF, "cit", "Setting GPIO port %q to %q", nr, state)
			local ok, err = sys.gpio_set(nr, state)
			if not ok then
				logf(LG_WRN, "cit", "Error performing GPIO command: %s", err)
			end
		end
	},

	-- This one is not in the original protocol: show configuration on display
	
	[0xfe] = {
		name = "show configuration",
		nparam = 0,
		fn = function(cit, n)
			show_configuration()
		end
	},

	-- This one is not in the original protocol: it fakes a scanned barcode
	
	[0xff] = {
		name = "fake scan",
		nparam = 1,
		fn = function(cit, n)
			local barcode
			if n == 1 then
				barcode = "4918734981"
			else
				barcode = "9869087697"
			end
			on_barcode( {data={barcode=barcode}}, cit)
		end
	}

}


-- 
-- Handle incoming byte to decode escape sequence and paramters
--

local function handle_byte(cit, c)

	-- Small state machine for keeping track of what we are doing.

	if cit.n == 0 then

		-- 1st byte: detect start of escape code

		if c == 0 then
			local nop = 0 -- noop to ignore 0x00, C1000 bug
		elseif c == 27 then
			logf(LG_DBG, "cit", "Start of escape sequence")
			cit.n = 1
		elseif c == 10 or c == 13 then
			pixel_x = 0
			pixel_y = pixel_y + fontsize
			if pixel_y > dpy_h - fontsize then pixel_y = 0 end
			display:gotoxy(pixel_x, pixel_y)
		else
			local text = to_utf8(string.char(c), cit.codepage)
			display:set_color("white")
			display:set_font(font, fontsize)
			display:gotoxy(pixel_x, pixel_y)
			local w = display:draw_text(text)
			pixel_x = pixel_x + w
		end

	elseif cit.n == 1 then

		-- 2nd byte: command identifier

		if command_list[c] then
			cit.cmd = command_list[c]
			if cit.cmd.nparam == 0 then
				logf(LG_DBG, "cit", "Handling command %q", cit.cmd.name)
				cit.cmd.fn(cit)
				cit.n = 0
			else
				cit.param = {}
				cit.n = 2
			end
		else
			logf(LG_WRN, "cit", "Unknown/unhandled escape command %02x received", c)
			cit.n = 0
		end

	else
		
		-- rest of bytes: 1 or more parameters

		if c ~= 0x03 then
			table.insert(cit.param, c)
		end

		if c == 0x03 or #cit.param == cit.cmd.nparam then
			logf(LG_DBG, "cit", "Handling command %q", cit.cmd.name)
			cit.cmd.fn(cit, unpack( cit.param ) )
			cit.n = 0
		end
	end
	
end



local function handle_bytes(cit, command)
	
	message_received = true

	for _, c in ipairs( { command:byte(1, #command) } ) do
		handle_byte(cit, c)
	end
	
	local timeout = tonumber(config:get("/cit/messages/idle/timeout"))
	logf(LG_DMP,"cit","Initiating cit_idle_msg with timeout")
	evq:push("cit_idle_msg", nil, timeout)
	t_lastcmd = sys.hirestime()

end


---------------------------------------------------------------------------
-- Network handling
---------------------------------------------------------------------------

--
-- Receive CIT command on udp port
--

local function on_udp(event, cit)

	local fd = event.data.fd
	if fd ~= cit.sock_udp then return end

	local command = net.recv(cit.sock_udp, 1024)

	if command and #command > 0 then
		handle_bytes(cit, command)
	end
	

end


--
-- Receive data from TCP client
--

local function on_tcp_client(event, client)

	local cit = client.cit
	local fd = event.data.fd
	if fd ~= client.sock then return end

	local command = net.recv(fd, 1024)
	
	if command and #command > 0 then
		handle_bytes(cit, command)
	else
		client:close()
	end

end


--
-- Create new client
--

local function client_new(cit, sock, addr, port)

	local client = {

		-- data
		
		cit = cit,
		sock = sock,
		addr = addr,
		port = port,

		-- methods
		
		close = function(client)
			net.close(client.sock)
			evq:fd_del(client.sock)
			evq:unregister("fd", on_tcp_client, client)
			cit.client_list[client] = nil
			logf(LG_INF, "cit", "Closed TCP connection from %s:%d", client.addr, client.port)
			cit.client_connected = false
		end
	}

	cit.client_list[client] = client
	cit.client_connected = true
	evq:fd_add(sock)
	evq:register("fd", on_tcp_client, client)
	logf(LG_INF, "cit", "Connected to %s:%d", addr, port)
	
end




-- 
-- Accept new client on TCP server
--

local function on_tcp_server(event, cit)

	local fd = event.data.fd
	if fd ~= cit.sock_tcp then return end

	local sock, addr, port = net.accept(fd)

	if not sock then
		err = addr
		logf(LG_WRN, "cit", "Error accepting client: %s", err)
		return
	end

	local client = client_new(cit, sock, addr, port)

end


--
-- Draw idle message
--

local function draw_idle_msg(cit)
	logf(LG_DBG,"cit", "draw_idle_msg")

	local idletime = sys.hirestime() - t_lastcmd
	if idletime < config:get("/cit/messages/idle/timeout") - 1 then
		return
	end

	display:set_color("black")
	display:clear()
	display:set_color("white")

	-- first draw the 'background' image:
	if config:lookup("/cit/messages/idle/show_idle_picture"):get() == "true" then
		local files, err = sys.readdir("/cit200/img")
		if files then
			for _, file in ipairs(files) do
				if file == "welcome.gif" then
					local image_path = "/cit200/img/" .. file
					logf(LG_DMP,"cit", "using welcome image %s", image_path)
					display:draw_image(image_path)
				end
			end
		end
	end

	-- then draw the text:
	for row = 1, 3 do
		local msg     = config:get("/cit/messages/idle/%s/text" % row)
		local xpos    = config:get("/cit/messages/idle/%s/xpos" % row)
		local ypos    = config:get("/cit/messages/idle/%s/ypos" % row)
		local align_h = config:get("/cit/messages/idle/%s/halign" % row)
		local align_v = config:get("/cit/messages/idle/%s/valign" % row)
		local size    = config:get("/cit/messages/idle/%s/size" % row)
		format_text(msg, xpos, ypos, align_h, align_v, size)
	end

end


--
-- Draw error message
--

local function draw_error_msg(cit)

	if message_received then return end

	display:set_color("black")
	display:clear()
	display:set_color("white")

	for row = 1, 2 do
		local msg     = config:get("/cit/messages/error/%s/text" % row)
		local xpos    = config:get("/cit/messages/error/%s/xpos" % row)
		local ypos    = config:get("/cit/messages/error/%s/ypos" % row)
		local align_h = config:get("/cit/messages/error/%s/halign" % row)
		local align_v = config:get("/cit/messages/error/%s/valign" % row)
		local size    = config:get("/cit/messages/error/%s/size" % row)
		format_text(msg, xpos, ypos, align_h, align_v, size)
	end

	logf(LG_DMP,"cit","Initiating cit_idle_msg in 5 seconds")
	evq:push("cit_idle_msg", nil, 5.0)
end


local function on_connect_timer(event, cit)

	-- Nothing to do in server mode
	
	local mode = config:get("/cit/mode")
	if mode == "server" then
		return true
	end

	-- if connected, nothing to do

	if cit.client_connected then
		return true
	end

	-- Try to connect
	
	local addr = config:get("/cit/remote_ip")
	local port = config:get("/cit/tcp_port")
	local sock = net.socket("tcp")
	local ok, err = net.connect(sock, addr, port)

	if not ok then
		local fds_in = { r={}, w={[sock]=true}, e={} }
		local fds_out = sys.select(fds_in, 0.5)
		if not fds_out then
			ok = false
			err = "timeout"
		else
			ok, err = net.getsockopt(sock, "SO_ERROR")
			ok = (ok == 0)
		end
	end

	if ok then
		client_new(cit, sock, addr, port)
	else
		net.close(sock)
		logf(LG_DBG, "cit", "Could not connect: %s", err)
	end

	return true
end

local function on_draw_idle_msg(event, cit) 
	cit:draw_idle_msg() 
end

local function on_draw_error_msg(event, cit) 
	cit:draw_error_msg() 
end

--
-- Start CIT server process
--

local function start(cit)

	logf(LG_INF, "cit", "Starting CIT server")

	local mode = config:get("/cit/mode")
		
	-- Open UDP port
		
	local udp_port = config:get("/cit/udp_port")
	local sock = net.socket("udp")
	net.bind(sock, "0.0.0.0", udp_port);
	evq:fd_add(sock)
	evq:register("fd", on_udp, cit)
	cit.sock_udp = sock
	logf(LG_INF, "cit", "Listening on UDP port %d", udp_port)

	-- Open TCP port

	if mode == "server" then
		local tcp_port = config:get("/cit/tcp_port")
		local sock = net.socket("tcp")
		net.bind(sock, "0.0.0.0", tcp_port)
		net.listen(sock, 5)
		evq:fd_add(sock)
		evq:register("fd", on_tcp_server, cit)
		cit.sock_tcp = sock
		logf(LG_INF, "cit", "Listening on TCP port %d", tcp_port)
	end


	-- Get codepage
	
	cit.codepage = config:get("/cit/codepage") 
	config:add_watch("/cit/codepage", "set", function() 
		cit.codepage = config:get("/cit/codepage") 
	end, scanner)

	-- Register to scanner events
	
	evq:register("scanner", on_barcode, cit)

	-- Event handlers for showing idle and error message
	
	evq:register("cit_idle_msg", on_draw_idle_msg, cit)
	evq:register("cit_error_msg", on_draw_error_msg, cit)

	-- Show version info on display, and schedule idle message in 3 seconds

	message_received = false

	local keys = {
		"/dev/name",
		"/dev/version",
		"/dev/build",
		"/dev/date",
	}

	display:gotoxy(0, 0);
	display:set_color("black")
	display:clear()
	display:set_color("white")

	y = 1
	for _, key in ipairs(keys) do
		local node = config:lookup(key)
		format_text(node.label .. ": " .. node:get(), 1, y, "", "", 13)
		y = y + 14
	end

	logf(LG_DMP,"cit","Initiating cit_idle_msg in 2 seconds")
	evq:push("cit_idle_msg", nil, 2.0)

	-- Led on, we're ready to scan
	
	led:set("yellow", "on")

end


--
-- Stop CIT and cleanup
--

local function stop(cit)
	
	logf(LG_INF, "cit", "Stopping CIT server")

	if cit.sock_udp then
		net.close(cit.sock_udp)
		evq:fd_del(cit.sock_udp)
	end
	evq:unregister("fd", on_udp, cit)

	if cit.sock_tcp then
		net.close(cit.sock_tcp)
		evq:fd_del(cit.sock_tcp)
		evq:unregister("fd", on_tcp_server, cit)
	end

	for client,_ in pairs(cit.client_list) do
		net.close(client.sock)
		evq:fd_del(client.sock)
		evq:unregister("fd", on_tcp_client, client)
		cit.client_list[client] = nil
	end
	cit.client_connected = false

	evq:unregister("scanner", on_barcode, cit)
	evq:unregister("cit_idle_msg", on_draw_idle_msg, cit)
	evq:unregister("cit_error_msg", on_draw_error_msg, cit)

end


local function show_message(cit, msg1, msg2)
	display:gotoxy(0, 0);
	display:set_color("black")
	display:clear()
	display:set_color("white")
	local y = 10
	if msg1 then
		format_text(msg1, 0, y, "c", "", fontsize_small)
		y = y + fontsize_small
	end
	if msg2 then
		format_text(msg2, 0, y, "c", "", fontsize_small)
		y = y + fontsize_small
	end
end


--
-- Create cit
--

function new()

	local cit = {

		-- data

		n = 0,						-- receiving byte index
		cmd = nil,					-- current command being handled,
		param = {},					-- command paramters
		codepage = "utf-8",		-- Default code page
		client_list = {},			-- List of connected TCP clients for server mode
		client_connected = false,

		-- methods

		start = start,
		stop = stop,
		draw_idle_msg = draw_idle_msg,
		draw_error_msg = draw_error_msg,
		show_message = show_message,
	}
	
	config:add_watch("/cit", "set", function() 
		cit:stop()
		cit:start()
	end)

	-- Check if there are any fonts on the sd card we can use
	
	local files = sys.readdir("/mnt")
	if files then
		for _, file in ipairs(files) do
			local tmp = file:match(".+\.ttf$")
			if tmp then
				font = "/mnt/" .. tmp
				break
			end
		end
	end
	
	-- Start connect timer for client mode

	evq:register("connect_timer", on_connect_timer, cit)
	evq:push("connect_timer", cit, 3.0)
			
	logf(LG_INF, "cit", "Using font file %q", font)

	return cit

end

-- vi: ft=lua ts=3 sw=3

