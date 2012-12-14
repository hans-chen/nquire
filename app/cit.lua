--
-- Copyright © 2007. All Rights Reserved.
--

module("CIT", package.seeall)

require "cit-codepages"

local lgid="cit"

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

local next_barcode_type = ""
local barcode_mode = "normal"


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
	display:clear()

	y = 1
	for _, key in ipairs(keys) do
		local node = config:lookup(key)
		display:format_text(node.label .. ": " .. node:get(), 1, y, "", "", 13)
		y = y + 14
	end

	evq:push("cit_idle_msg", nil, 10.0)
end


---------------------------------------------------------------------------
-- CIT protocol handling
---------------------------------------------------------------------------


local function handle_barcode_normal(barcode, prefix)
	logf(LG_DBG,lgid,"handle_barcode_normal")
	local success = true

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

	return success
end


local function handle_barcode_cit_conf( barcode )
	logf(LG_DBG,lgid,"handle_barcode_cit_conf()")
	-- barcode is same format as configfile
	local ll = string.split( barcode, "\n" )

	for i, l in pairs(ll) do
		logf(LG_DBG,lgid,"Processing line from barcode: " .. l )
		l=l:gsub("\r$","")
		config:set_config_item( l )
	end

end

local function authorized_exec( fnc, next_bc_type )
	logf(LG_DBG,lgid,"authorized_exec()")
	if config:get("/dev/barcode_auth/enable") == "true" then
		display:set_font( nil, 18, nil )
		display:show_message( "Programming", "", "Scan security", "barcode" )
		next_barcode_type = "security:" .. next_bc_type
	else
		fnc()
		next_barcode_type = next_bc_type
	end
end

local function restore_defaults()
	logf(LG_INF, lgid, "Scanned 'factory defaults' barcode, restoring and rebooting system");
	os.execute("rm -f cit.conf")
	os.execute("reboot")
end

local function prepare_for_settings_barcode()
	display:set_font( nil, 18, nil )
	display:show_message( "Programming", "", "Scan settings" )
	scanner:barcode_on_off( "DataMatrix", "on", true )
	scanner:barcode_on_off( "QR_Code", "on", true )
end

local function handle_barcode_programming(cit, barcode, prefix)
	logf(LG_DBG,lgid," handle_barcode_programming(barcode=%s)", (barcode or "nil"))
	local success = true

	if not barcode then

		success = false

	elseif string.match( next_barcode_type, "^security:" ) then
		-- handling authorized_exec()

		next_barcode_type = string.match(next_barcode_type,"^security:(.*)") or ""
		if barcode ~= config:get("/dev/barcode_auth/security_code") then
			display:set_font( nil, 18, nil )
			display:show_message( "Programming", "", "Incorrect", "security", "code" )
			evq:push("cit_idle_msg", nil, 2.0)
			success = false
			next_barcode_type = ""
		else
			if next_barcode_type == "defaults" then
				restore_defaults()
			elseif next_barcode_type == "config" then
				prepare_for_settings_barcode()
			else
				-- bug, should not happen
				evq:push("cit_idle_msg", nil, 0)
				success = false
				next_barcode_type = ""
			end
		end

	elseif next_barcode_type == "serial" then

		logf(LG_INF, lgid, "Programming product serial number: %s", barcode)
		config:lookup("/dev/serial"):set(barcode)
		next_barcode_type = ""
		evq:push("cit_idle_msg", nil, 0)

	elseif next_barcode_type == "config" then

		if prefix == find_prefix_def("DataMatrix").prefix_out or 
			prefix == find_prefix_def("QR_Code").prefix_out or
			prefix == find_prefix_def("Code128").prefix_out 
		then
			handle_barcode_cit_conf( barcode )
		else
			success=false
			logf(LG_WRN, lgid, "Programming setting via barcode failed.")
		end
		next_barcode_type = ""
	
		local tf2onoff = { ["true"] = "on", ["false"] = "off" }
		scanner:barcode_on_off( "DataMatrix", tf2onoff[config:get("/dev/scanner/enable-disable/DataMatrix")] , true )
		scanner:barcode_on_off( "QR_Code", tf2onoff[config:get("/dev/scanner/enable-disable/QR_Code")] , true )

		evq:push("cit_idle_msg", nil, 0)

	else

		local cmd, par = barcode:match("^02(0[3457])(%x%x)")

		if cmd==nil or par==nil then

			success = false
			logf(LG_WRN, lgid, "No command or parameter recognized in barcode")

		elseif cmd=="03" then

			-- Barcodes 020300 to 020305 set the beeper volume
			logf(LG_INF, lgid, "Scanned 'beeper volume' barcode, set volume to %s", par)
			config:set("/dev/beeper/volume", tonumber(par), true)

		elseif cmd=="04" then

			-- Barcodes 020401 to 020403 set the beeper sound type
			logf(LG_INF, lgid, "Scanned 'beeper sound type' barcode, set sound type to %s", par)
			config:set("/dev/beeper/beeptype", tonumber(par) + 1, true)
	
		elseif cmd=="05" then

			-- Barcodes 020501 to 020504 set the display contrast
			logf(LG_INF, lgid, "Scanned 'display contrast' barcode, set contrast to %s", par)
			config:set("/dev/display/contrast", tonumber(par), true) 

		elseif cmd=="07" then

			-- Extra codes for reboot and factory defaults, barcode config settings
			if par == "00" then
				logf(LG_INF, lgid, "Scanned 'reboot' barcode, rebooting system");
				os.execute("reboot")
			elseif par == "01" then
				authorized_exec( restore_defaults, "defaults" )
			elseif par == "02" then
				show_configuration()
			elseif par == "04" then
				next_barcode_type = "serial"
				display:set_font( nil, 18, nil )
				display:show_message( "Programming", "", "Scan serial number" )
			elseif par == "05" then
				authorized_exec( prepare_for_settings_barcode, "config" )
			else
				display:set_font( nil, 18, nil )
				display:show_message( "Programming", "", "Unknown code" )
				evq:push("cit_idle_msg", nil, 2.0)
				success = false
			end
		else
			success = false
		end
	end
	return success
end

local function end_barcode_programming()
	barcode_mode = "normal"
	evq:push( "cit_idle_msg", nil, 0 )
	next_barcode_type = ""
end
--
-- Implement a programmingmode timeout
--
local last_programming_mode_time = 0

local function on_programming_mode_timeout(event, cit)
	local now = sys.hirestime()
	local diff = now - last_programming_mode_time
	logf(LG_DBG,lgid,"on_programming_mode_timeout( ) now=%d, last=%d, now-last=%d", now, last_programming_mode_time, diff )
	if diff >= tonumber(config:get("/cit/programming_mode_timeout")) and barcode_mode ~= "normal" then
		logf(LG_INF,lgid,"Exit programming mode because of timeout")
		end_barcode_programming()
		beeper:beep_error()
	end
end

local function set_programming_mode_timeout()
	last_programming_mode_time = sys.hirestime()
	local timeout = tonumber(config:get("/cit/programming_mode_timeout"))
	logf(LG_DBG,lgid,"set_programming_mode_timeout() timeout=%d", timeout)
	evq:push("programming_mode_timeout",nil,timeout+1)
end


--
-- Handle scanned barcode. This is a 2-state statemachine for switching between
-- normal 'operational' mode and 'programming' mode
--

local function on_barcode(event, cit)

	local barcode = event.data.barcode
	local prefix = event.data.prefix or "?"
	local success = true

	logf(LG_DMP, lgid, "on_barcode(prefix='%s', barcode='%s')", prefix, barcode)

	-- TODO: or should scanning really be disabled
	led:set("yellow", "off")

	if barcode == nil then
		success = false
	elseif barcode_mode == "normal" then
		if barcode == "%#$^*%" then
			logf(LG_INF, lgid, "Scanned 'programming mode' barcode")
			barcode_mode = "programming"
			evq:push( "cit_idle_msg", nil, 0 )
			set_programming_mode_timeout()
		else
			success = handle_barcode_normal(barcode, prefix)
		end
	else -- barcode_mode == programming
		if barcode == "%*^$#%" then
			logf(LG_INF, lgid, "Scanned 'normal mode' barcode")
			end_barcode_programming()
		else
			set_programming_mode_timeout()
			success = handle_barcode_programming(cit, barcode, prefix)
		end
	end
	
	if not success then
		beeper:beep_error()
	end
	
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
			display:clear()
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
			display:clear()
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
		nparam = 1000,
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
				pixel_x = align[pos][1] or pixel_x
				pixel_y = align[pos][2] or pixel_y
				align_h = align[pos][3] or "l"
				align_v = align[pos][4] or "t"
			end

			local text = string.char(...)
			text = to_utf8(text, cit.codepage)
			logf(LG_DBG,lgid,"text=%s", text)
			-- transform such that the display handles CR (0x0d) the same as NL (0x0a=\n)
			-- this is for SG15 compatebility!
			text = string.gsub( text, string.char(0x0d), "\n" )
			w, h , pixel_x, pixel_y = display:format_text(text, pixel_x, pixel_y, align_h, align_v, fontsize)
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
			elseif f == 0x31 then
				fontsize = fontsize_big
			elseif f > 0x31 and f<=0x40 then
				fontsize = (f-0x30)*6
			end
			display:set_font(font, fontsize)
		end
	},

	[0x5a] = {
		name = "soft reset",
		nparam = 0,
		fn = function(cit)
			logf(LG_WRN, lgid, "Reset not implemented")
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

	[0x5d] = {
		name = "sleep/wakeup barcode scanner",
		nparam = 1,
		fn = function(cit, onoff)
			logf(LG_INF, lgid, "Putting scanner to " .. (onoff==0x30 and "sleep" or "wakeup"))
			if onoff == 0x30 then
				led:set("yellow","off")
				local ok, err = sys.gpio_set(18, 0)
				cit.power_saving_on = true
			end
			if onoff == 0x31 then
				local ok, err = sys.gpio_set(18, 1)
				evq:push("reinit_scanner", scanner, 3 )
				cit.power_saving_on = false
			end
		end
	},

	[0x5e] = {
		name = "beep",
		nparam = 0,
		fn = function(cit)
			beeper:beep_ok( true )
		end
	},

	[0x5f] = {
		name = "get firmware version",
		nparam = 0,
		fn = function(cit)
			return config:get("/dev/version")
		end
	},


	[0x60] = {
		name = "get firmware version in SG15 format",
		nparam = 0,
		fn = function(cit)
			local major, minor = string.match( config:get("/dev/version"), "^(%d+).(%d+)" )
			return "SG15V" .. string.format( "%02d.%02d", major, minor );
		end
	},


	[0x7E] = {
		name = "Set GPIO output",
		nparam = 2,
		fn = function(cit, nr, state)
			if (nr == 0x30 or nr == 0x31) and (state == 0x30 or state==0x31) then
				port = nr == 0x30 and 1 or 3
				state = state - 0x30
				logf(LG_INF, lgid, "Setting GPIO port %q to %q", port, state)
				local ok, err = sys.gpio_set(port, state)
				if not ok then
					logf(LG_WRN, lgid, "Error performing GPIO command: %s", err)
				end
			else
				logf(LG_WRN, lgid, "Incorrect port number or state value for gpio(%%x,%x)", port,state)
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
   -- The instruction is meant for testing purposes only
   -- Barcodes can be of arbitrary length but too long barcodes are not recommended
   -- All charracters are allowed, except 0x03 which indicates eos
   -- The prefix parameter is the outging prefix (1 charracter)
	
	[0xff] = {
		name = "fake scan",
		nparam = 255,
		fn = function(cit, prefix, ...)
			local barcode = string.char(...)
			prefix = string.char(prefix)
			logf( LG_DBG, lgid, "Faking barcode '%s%s'", prefix, barcode)
			if barcode == nil then
				logf( LG_WRN, lgid, "No fake barcode data received")
			else
				evq:push("scanner", { result = "ok", barcode = barcode, prefix=prefix })
			end
		end
	},

}

--
-- flush the content of the parameter buffer to the display
--

local function force_flush( cit )

	local text = string.char(unpack( cit.param ))
	
-- transform such that the display handles CR (0x0d) the same as NL (0x0a='\n')
	-- this is for SG15 compatebility!
	text = string.gsub( text, string.char(0x0d), "\n" )
			
	cit.param = {}
	text = to_utf8(text, cit.codepage)

	display:set_font(font, fontsize)
	display:gotoxy(pixel_x, pixel_y)
	local w, h
	w, h , pixel_x, pixel_y = display:draw_text(text)

end

-- 
-- Handle incoming byte to decode escape sequence and parameters
--

local function handle_byte(cit, c)

	-- Small state machine for keeping track of what we are doing.

	local answer

	if cit.n == 0 then

		-- 1st byte: detect start of escape code

		if c == 0 then
			local nop = 0 -- noop to ignore 0x00, C1000 bug
		elseif c == 27 then
			if #cit.param ~= 0 then
				force_flush( cit )
			end
			logf(LG_DBG, lgid, "Start of escape sequence")
			cit.n = 1
		else
			if c == 0x03 then
				force_flush( cit )
			else
				table.insert(cit.param, c)
			end
		end

	elseif cit.n == 1 then

		-- 2nd byte: command identifier

		if command_list[c] then
			cit.cmd = command_list[c]
			if cit.cmd.nparam == 0 then
				logf(LG_DBG, lgid, "Handling command %q", cit.cmd.name)
				answer = cit.cmd.fn(cit)
				cit.n = 0
			else
				cit.param = {}
				cit.n = 2
			end
		else
			logf(LG_WRN, lgid, "Unknown/unhandled escape command %02x received", c)
			cit.n = 0
		end

	else
		
		-- rest of bytes: 1 or more parameters

		if c ~= 0x03 then
			table.insert(cit.param, c)
		end

		if c == 0x03 or #cit.param == cit.cmd.nparam then
			logf(LG_DBG, lgid, "#cit.param=%d, cit.cmd.nparam=%s", #cit.param , cit.cmd.nparam)
			logf(LG_DBG, lgid, "Handling command %q", cit.cmd.name)
			answer = cit.cmd.fn(cit, unpack( cit.param ) )
			cit.param = {}
			cit.n = 0
		end
	end

	return answer
	
end



local function handle_bytes(cit, command)
	
	message_received = true
	local answer=""
	for i, c in ipairs( { command:byte(1, #command) } ) do
		local current_answer = handle_byte(cit, c)
		if current_answer then
			logf( LG_DMP, lgid, "Current answer \"" .. current_answer .. "\"" )
			answer = answer .. current_answer
		end
	end
	
	local timeout = tonumber(config:get("/cit/messages/idle/timeout"))
	evq:push("cit_idle_msg", nil, timeout)
	t_lastcmd = sys.hirestime()

	return answer
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
	logf(LG_DBG,lgid,"on_udp()")

	local command, destaddr, destport = net.recvfrom(cit.sock_udp, 1024)

	if command and #command > 0 then
		local answer = handle_bytes(cit, command)
		if answer then
			if net.sendto( cit.sock_udp, answer, destaddr, destport ) ~= #answer then
				logf( LG_WRN, lgid, "Error sending back data in response to an ESC code" )
			end
		end
	end

end


--
-- Receive data from TCP client
--

local function on_tcp_client(event, client)
	local fd = event.data.fd
	if fd ~= client.sock then return end
	logf(LG_DBG,lgid,"on_tcp_client()")

	local cit = client.cit
	local command = net.recv(fd, 1024)
	
	if command and #command > 0 then
		local answer = handle_bytes(cit, command)
		if answer then
			logf( LG_DBG, lgid, "Sending back \"" .. answer .. "\"" )
			if net.send(fd, answer) ~= #answer then
				logf( LG_WRN, lgid, "Error sending back data in response to an ESC code" )
			end
		end
	else
		client:close()
	end

end


--
-- Create new client
--

local function client_new(cit, sock, addr, port)
	logf(LG_DBG,lgid,"client_new()")
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
			logf(LG_INF, lgid, "Closed TCP connection from %s:%d", client.addr, client.port)
			cit.client_connected = false
		end
	}

	cit.client_list[client] = client
	cit.client_connected = true
	evq:fd_add(sock)
	evq:register("fd", on_tcp_client, client)
	logf(LG_INF, lgid, "Connected to %s:%d", addr, port)
	
end




-- 
-- Accept new client on TCP server
--

local function on_tcp_server(event, cit)
	local fd = event.data.fd
	if fd ~= cit.sock_tcp then return end
	logf(LG_DBG,lgid,"on_tcp_server()")

	local sock, addr, port = net.accept(fd)

	if not sock then
		err = addr
		logf(LG_WRN, lgid, "Error accepting client: %s", err)
		return
	end

	local client = client_new(cit, sock, addr, port)

end


--
-- Draw idle message
--

local function draw_idle_msg(cit)
	logf(LG_DBG,lgid, "draw_idle_msg()")

	local idletime = sys.hirestime() - t_lastcmd
	if idletime < config:get("/cit/messages/idle/timeout") - 1 then
		return
	end

	display:clear()

	if barcode_mode == "programming" then

		display:set_font( nil, 18, nil )
		display:show_message( "Programming" )

	else

		-- first draw the 'background' image:
		if config:lookup("/cit/messages/idle/picture/show"):get() == "true" then
			local files, err = sys.readdir("/cit200/img")
			if files then
				for _, file in ipairs(files) do
					if file == "welcome.gif" then
						local image_path = "/cit200/img/" .. file
						logf(LG_DMP,lgid, "using welcome image %s", image_path)
						local xpos = config:lookup("/cit/messages/idle/picture/xpos"):get()
						local ypos = config:lookup("/cit/messages/idle/picture/ypos"):get()
						logf(LG_DBG,lgid,"image xpos=%d, ypos=%d", xpos, ypos)
						display:draw_image(image_path, xpos, ypos)
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
			local size    = config:get("/cit/messages/idle/%s/size" % row) == "large" and fontsize_big or fontsize_small
			display:format_text(msg, xpos, ypos, align_h, align_v, size)
		end
	end

end


--
-- Draw error message
--

local function draw_error_msg(cit)

	if message_received then return end

	display:clear()

	for row = 1, 2 do
		local msg     = config:get("/cit/messages/error/%s/text" % row)
		local xpos    = config:get("/cit/messages/error/%s/xpos" % row)
		local ypos    = config:get("/cit/messages/error/%s/ypos" % row)
		local align_h = config:get("/cit/messages/error/%s/halign" % row)
		local align_v = config:get("/cit/messages/error/%s/valign" % row)
		local size    = config:get("/cit/messages/error/%s/size" % row) == "large" and fontsize_big or fontsize_small

		display:format_text(msg, xpos, ypos, align_h, align_v, size)
	end

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

	logf(LG_DBG,lgid,"on_connect_timer()")

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
		logf(LG_DBG, lgid, "Could not connect: %s", err)
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
	logf(LG_DBG,lgid,"start()")
	logf(LG_INF, lgid, "Starting CIT server")

	local mode = config:get("/cit/mode")
		
	-- Open UDP port
		
	local udp_port = config:get("/cit/udp_port")
	local sock = net.socket("udp")
	net.bind(sock, "0.0.0.0", udp_port);
	evq:fd_add(sock)
	evq:register("fd", on_udp, cit)
	cit.sock_udp = sock
	logf(LG_INF, lgid, "Listening on UDP port %d", udp_port)

	-- Open TCP port

	if mode == "server" then
		local tcp_port = config:get("/cit/tcp_port")
		local sock = net.socket("tcp")
		net.bind(sock, "0.0.0.0", tcp_port)
		net.listen(sock, 5)
		evq:fd_add(sock)
		evq:register("fd", on_tcp_server, cit)
		cit.sock_tcp = sock
		logf(LG_INF, lgid, "Listening on TCP port %d", tcp_port)
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
	display:clear()

	y = 1
	for _, key in ipairs(keys) do
		local node = config:lookup(key)
		display:format_text(node.label .. ": " .. node:get(), 1, y, "", "", 13)
		y = y + 14
	end

	evq:push("cit_idle_msg", nil, 2.0)

	-- Led on, we're ready to scan
	
	led:set("yellow", "on")

end


--
-- Stop CIT and cleanup
--

local function stop(cit)
	logf(LG_DBG,lgid,"stop()")	
	logf(LG_INF, lgid, "Stopping CIT server")

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


function set_fontsize() 
	fontsize_small = config:lookup("/cit/messages/fontsize/small"):get()
	fontsize_big = config:lookup("/cit/messages/fontsize/large"):get()
end

--
-- Create cit
--

function new()
	logf(LG_DBG,lgid,"new()")
	local cit = {

		-- data

		n = 0,						-- receiving byte index
		cmd = nil,					-- current command being handled,
		param = {},					-- command paramters
		codepage = "utf-8",		-- Default code page
		client_list = {},			-- List of connected TCP clients for server mode
		client_connected = false,
		power_saving_on = false,

		-- methods

		start = start,
		stop = stop,
		draw_idle_msg = draw_idle_msg,
		draw_error_msg = draw_error_msg,
	}
	
	config:add_watch("/cit", "set", function() 
		cit:stop()
		cit:start()
	end)

	config:add_watch("/cit/messages/fontsize", "set", set_fontsize ) 
	set_fontsize()

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
	
	display:set_font( font, fontsize_small )
	
	-- Start connect timer for client mode

	evq:register("connect_timer", on_connect_timer, cit)
	evq:push("connect_timer", cit, 3.0)

	evq:register("programming_mode_timeout", on_programming_mode_timeout, cit)
			
	logf(LG_INF, lgid, "Using font file %q", font)

	return cit

end

-- vi: ft=lua ts=3 sw=3

