--
-- Copyright © 2007. All Rights Reserved.
--

module("SG15", package.seeall)

require "sg15-codepages"

local dpy_w = 240
local dpy_h = 128

local fontsize = 13

local pixel_x = 0
local pixel_y = 0

local align_h = "l"
local align_v = "t"

local message_received = false
local error_occured = false

--
-- Translate string to given codepage
--

local function to_utf8(text, page)

	local xlat = codepage_to_utf8[page]

	if xlat then
		local out = {}
		for _, c in ipairs( { string.byte(text, 1, #text) } ) do
			out[#out+1] = xlat[c] or c
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

local function format_text(msg, xpos, ypos, align_h, align_v, size)

	local text = to_utf8(msg, sg15.codepage)

	align_h = align_h:sub(1, 1)
	align_v = align_v:sub(1, 1)
	if size == "small" then size = 24 end
	if size == "large" then size = 32 end

	if align_h == "c" then xpos = dpy_w/2 end
	if align_h == "r" then xpos = dpy_w end
	if align_v == "m" then ypos = dpy_h / 2 end
	if align_v == "b" then ypos = dpy_h end

	display:set_font("arial.ttf", size)
	local text_w, text_h = display:get_text_size(text)

	if align_h == "c" then xpos = xpos - text_w / 2 end
	if align_h == "r" then xpos = xpos - text_w end
	if align_v == "m" then ypos = ypos - text_h / 2 end
	if align_v == "b" then ypos = ypos - text_h end

	display:gotoxy(xpos, ypos)
	display:draw_text(text)

end


---------------------------------------------------------------------------
-- SG-15 protocol handling
---------------------------------------------------------------------------

--
-- Handle scanned barcode
--

local function on_barcode(event, sg15)

	local barcode = event.barcode

	-- Send to UDP remote server

	local sock = net.socket("udp")
	local addr = config:get("/sg15/remote_ip")
	local port = config:get("/sg15/udp_port")
	net.sendto(sock, barcode .. "\n", addr, port)
	net.close(sock)

	-- Send to all connected TCP clients
	
	for client,_ in pairs(sg15.client_list) do
		net.send(client.sock, barcode .. "\n")
	end

	-- Register timer to show error message if no data received in time

	message_received = false
	local timeout = tonumber(config:get("/sg15/messages/error/timeout"))
	evq:push("sg15_error_msg", nil, timeout)

end



-- Note. The booklet with SG15 protocol description is ambigious on the 'clear
-- display' command. The examples use command 0x24, but the command list uses
-- command 0x25. To be sure, both are implemented here

local command_list = {
	
	[0x24] = {
		name = "clear screen",
		nparam = 0,
		fn = function(sg15)
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
		fn = function(sg15)
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
		fn = function(sg15, x, y)
			x = x - 0x30
			y = y - 0x30
		end
	},

	[0x2c] = {
		name = "set pixel position",
		nparam = 2,
		fn = function(sg15, x, y)
			pixel_x = x - 0x30
			pixel_y = y - 0x30
		end
	},

	[0x2e] = {
		name = "align string of text",
		nparam = 26,
		fn = function(sg15, pos, ...)
		
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

			format_text(text, pixel_x, pixel_y, align_h, align_v, fontsize)
		end
	},

	[0x40] = {
		name = "sleep",
		nparam = 0,
		fn = function(sg15)
		end
	},

	[0x41] = {
		name = "wakeup",
		nparam = 0,
		fn = function(sg15)
		end
	},

	[0x42] = {
		name = "select font set",
		nparam = 1,
		fn = function(sg15, font)
			if font == 0x30 then
				fontsize = 24
			end
			if font == 0x31 then
				fontsize = 32
			end
			display:set_font("arial.ttf", fontsize)
		end
	},

	[0x5a] = {
		name = "soft reset",
		nparam = 0,
		fn = function(sg15)
			logf(LG_WRN, "sg15", "Reset not implemented")
		end
	},

	[0x5b] = {
		name = "enable/disable scanning",
		nparam = 1,
		fn = function(sg15, onoff)
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
		fn = function(sg15, onoff)
			logf(LG_WRN, "sg15", "Backlight enable/disable not implemneted")
		end
	},

	[0x5d] = {
		name = "slaap/wakeup barcode scanner",
		nparam = 1,
		fn = function(sg15, onoff)
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
		fn = function(sg15)
			beeper:play("o3c8")
		end
	},

	[0x5f] = {
		name = "get firmware version",
		nparam = 0,
		fn = function(sg15)
			logf(LG_WRN, "sg15", "Returning data not yet implmenented")
			return config:get("/info/version/version")
		end
	},

	-- This one is not in the original protocol: it fakes a scanned barcode
	
	[0xff] = {
		name = "fake scan",
		nparam = 1,
		fn = function(sg15, n)
			local barcode
			if n == 1 then
				barcode = "4918734981"
			else
				barcode = "9869087697"
			end
			on_barcode( { barcode=barcode }, sg15)
		end
	}

}


-- 
-- Handle incoming byte to decode escape sequence and paramters
--

local function handle_byte(sg15, c)
		
	-- Small state machine for keeping track of what we are doing.

	if sg15.n == 0 then

		-- 1st byte: detect start of escape code

		if c == 27 then
			logf(LG_DBG, "sg15", "Start of escape sequence")
			sg15.n = 1
		elseif c == 0x0d then
			pixel_x = 0
			pixel_y = pixel_y + fontsize
			display:gotoxy(pixel_x, pixel_y)
		else
			local text = to_utf8(string.char(c), sg15.codepage)
			display:draw_text(text)
		end

	elseif sg15.n == 1 then

		-- 2nd byte: command identifier

		if command_list[c] then
			sg15.cmd = command_list[c]
			if sg15.cmd.nparam == 0 then
				logf(LG_DBG, "sg15", "Handling command %q", sg15.cmd.name)
				sg15.cmd.fn(sg15)
				sg15.n = 0
			else
				sg15.param = {}
				sg15.n = 2
			end
		else
			logf(LG_WRN, "sg15", "Unknown/unhandled escape command %02x received", c)
			sg15.n = 0
		end

	else
		
		-- rest of bytes: 1 or more parameters

		if c ~= 0x03 then
			table.insert(sg15.param, c)
		end

		if c == 0x03 or #sg15.param == sg15.cmd.nparam then
			logf(LG_DBG, "sg15", "Handling command %q", sg15.cmd.name)
			sg15.cmd.fn(sg15, unpack( sg15.param ) )
			sg15.n = 0
		end
	end
	
end



local function handle_bytes(sg15, command)
	
	message_received = true
	error_occured = false

	for _, c in ipairs( { command:byte(1, #command) } ) do
		handle_byte(sg15, c)
	end
	
	local timeout = tonumber(config:get("/sg15/messages/idle/timeout"))
	evq:push("sg15_idle_msg", nil, timeout)

end


---------------------------------------------------------------------------
-- Network handling
---------------------------------------------------------------------------

--
-- Receive SG15 command on udp port
--

local function on_udp(event, sg15)

	local fd = event.data.fd
	if fd ~= sg15.sock_udp then return end

	local command = net.recv(sg15.sock_udp, 1024)

	if command and #command > 0 then
		handle_bytes(sg15, command)
	end
	

end


--
-- Receive data from TCP client
--

local function on_tcp_client(event, client)

	local sg15 = client.sg15
	local fd = event.data.fd
	if fd ~= client.sock then return end

	local command = net.recv(fd, 1024)
	
	if command and #command > 0 then
		handle_bytes(sg15, command)
	else
		net.close(fd)
		evq:fd_del(fd)
		evq:unregister("fd", on_tcp_client, client)
		sg15.client_list[client] = nil
		logf(LG_INF, "sg15", "Closed TCP connection from %s:%d", client.addr, client.port)
	end

end


-- 
-- Accept new client on TCP server
--

local function on_tcp_server(event, sg15)

	local fd = event.data.fd
	if fd ~= sg15.sock_tcp then return end

	local sock, addr, port = net.accept(fd)

	if not sock then
		err = addr
		logf(LG_WRN, "sg15", "Error accepting client: %s", err)
		return
	end

	local client = {
		sg15 = sg15,
		sock = sock,
		addr = addr,
		port = port,
	}

	evq:fd_add(sock)
	evq:register("fd", on_tcp_client, client)
	sg15.client_list[client] = true

	logf(LG_INF, "sg15", "New TCP connection from %s:%d", client.addr, client.port)

end


--
-- Draw idle message
--

local function draw_idle_msg(sg15)

	if error_occured then return end

	display:set_color("black")
	display:clear()
	display:set_color("white")

	for row = 1, 3 do
		local msg     = config:get("/sg15/messages/idle/%s/text" % row)
		local xpos    = config:get("/sg15/messages/idle/%s/xpos" % row)
		local ypos    = config:get("/sg15/messages/idle/%s/ypos" % row)
		local align_h = config:get("/sg15/messages/idle/%s/halign" % row)
		local align_v = config:get("/sg15/messages/idle/%s/valign" % row)
		local size    = config:get("/sg15/messages/idle/%s/size" % row)
		format_text(msg, xpos, ypos, align_h, align_v, size)
	end

end


--
-- Draw error message
--

local function draw_error_msg(sg15)

	if message_received then return end

	display:set_color("black")
	display:clear()
	display:set_color("white")

	for row = 1, 2 do
		local msg     = config:get("/sg15/messages/error/%s/text" % row)
		local xpos    = config:get("/sg15/messages/error/%s/xpos" % row)
		local ypos    = config:get("/sg15/messages/error/%s/ypos" % row)
		local align_h = config:get("/sg15/messages/error/%s/halign" % row)
		local align_v = config:get("/sg15/messages/error/%s/valign" % row)
		local size    = config:get("/sg15/messages/error/%s/size" % row)
		format_text(msg, xpos, ypos, align_h, align_v, size)
	end

	error_occured = true
end


--
-- Start SG15 server process
--

local function start(sg15)

	logf(LG_INF, "sg15", "Starting SG15 server")

	-- Open UDP port
	
	local udp_port = config:get("/sg15/udp_port")
	local sock = net.socket("udp")
	net.bind(sock, "0.0.0.0", udp_port);
	evq:fd_add(sock)
	evq:register("fd", on_udp, sg15)
	sg15.sock_udp = sock
	logf(LG_INF, "sg15", "Listening on UDP port %d", udp_port)

	-- Open TCP port
	
	local tcp_port = config:get("/sg15/tcp_port")
	local sock = net.socket("tcp")
	net.bind(sock, "0.0.0.0", tcp_port)
	net.listen(sock, 5)
	evq:fd_add(sock)
	evq:register("fd", on_tcp_server, sg15)
	sg15.sock_tcp = sock
	logf(LG_INF, "sg15", "Listening on TCP port %d", tcp_port)

	-- Get codepage
	
	sg15.codepage = config:get("/sg15/codepage") 
	config:add_watch("/sg15/codepage", "set", function() 
		sg15.codepage = config:get("/sg15/codepage") 
	end, scanner)

	-- Register to scanner events
	
	evq:register("scanner", on_barcode, sg15)

	-- Event handlers for showing idle and error message
	
	evq:register("sg15_idle_msg", function(event, sg15) sg15:draw_idle_msg() end, sg15)
	evq:register("sg15_error_msg", function(event, sg15) sg15:draw_error_msg() end, sg15)

	-- Start with idle message

	message_received = false
	error_occured = false
	sg15:draw_idle_msg()

end


--
-- Stop SG15 and cleanup
--

local function stop(sg15)
	
	logf(LG_INF, "sg15", "Stopping SG15 server")

	if sg15.sock_udp then
		net.close(sg15.sock_udp)
		evq:fd_del(sg15.sock_udp)
		evq:unregister("fd", on_udp, sg15)
	end

	if sg15.sock_tcp then
		net.close(sg15.sock_tcp)
		evq:fd_del(sg15.sock_tcp)
		evq:unregister("fd", on_tcp_server, sg15)
	end

	for client,_ in pairs(sg15.client_list) do
		net.close(client.sock)
		evq:fd_del(client.sock)
		evq:unregister("fd", on_tcp_client, client)
		sg15.client_list[client] = nil
	end

	evq:unregister("scanner", on_barcode, sg15)

end


--
-- Create sg15
--

function new()

	local sg15 = {

		-- data

		n = 0,						-- receiving byte index
		cmd = nil,					-- current command being handled,
		param = {},					-- command paramters
		codepage = "utf-8",		-- Default code page
		client_list = {},			-- List of connected TCP clients

		-- methods

		start = start,
		stop = stop,
		draw_idle_msg = draw_idle_msg,
		draw_error_msg = draw_error_msg,
	}
	
	config:add_watch("/sg15", "set", function() 
		sg15:stop()
		sg15:start()
	end)

	return sg15

end

-- vi: ft=lua ts=3 sw=3

