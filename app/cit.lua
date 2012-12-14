--
-- Copyright © 2007. All Rights Reserved.
--

module("CIT", package.seeall)

require "cit-codepages"

local password_salt = "W2aq.4jM"

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

-- next_barcode_type can be one of "", "default", "config", "serial", "security:barcode"
-- This indicates what the next barcode means.
-- The security barcode is a delayed handling of barcode: first a security code must be read,
-- only then the barcode can be handled.
local next_barcode_type = ""
local barcode_mode = "normal"

local translate_NL = { ["LF"] = "\n", ["CR"] = "\r", ["CRLF"] = "\r\n" }

local function show_configuration()

	local name = config:get("/dev/name")
	local version = config:get("/dev/version")
	local build = config:get("/dev/build")
	local date = config:get("/dev/date")
	local serial = config:get("/dev/serial")
	local hardware = config:get("/dev/hardware")
	
	display:clear()
	display:gotoxy(0, 0)
	display:set_font( nil, display["native_font_size"]*1.5)
	display:draw_text("%s\n", name)
	display:set_font( nil, display["native_font_size"])
	display:draw_text("Contrast=%s, beeptype=%s, volume=%s\n", config:get("/dev/display/contrast"), config:get("/dev/beeper/beeptype"), config:get("/dev/beeper/volume") )
	display:draw_text("Application: %s, build %s, %s\n", version, build, date)
	display:draw_text("Root fs: %s, firmware: %s\n", config:get("/dev/rfs_version"), config:get("/dev/firmware") )
	display:draw_text("Serial: %s, HW version: %s\n", serial, hardware)
	display:draw_text("%s: %s\n", config:get("/network/interface"), config:get("/network/current_ip") )
	
	-- HWaddr:
	local mac_eth0 = sys.get_macaddr("eth0")
	local mac_wlan0 = sys.get_macaddr("wlan0")
	display:draw_text("eth %s", mac_eth0)
	if mac_wlan0 and mac_wlan0 ~= "??:??:??:??:??:??" then
		display:draw_text(", wifi %s", mac_wlan0)
	end
	display:draw_text("\n")
	
	-- scanner:
	local scanner_fw = config:get("/dev/scanner/version")
	if scanner_fw and #scanner_fw>0 then
		display:draw_text("%s\n", scanner_fw)
	end

	-- touch screen
	local touch16_name = config:get("/dev/touch16/name")
	if name ~= "" then
		display:draw_text(touch16_name .. "\n")
	end

	local sep = ""
	
	-- mifare:
	local mifare_model = config:get("/dev/mifare/modeltype")
	if mifare_model and #mifare_model>0 then
		display:draw_text(sep .. "mifare " .. mifare_model)
		sep = ", "
	end

	-- sd card:
	local fd = io.popen("mount | grep mmcblk0p1")
	local data = fd:read("*a")
	fd:close()
	if #data > 0 then
		display:draw_text(sep .. "sd card")
		sep = ", "
	end
		
	-- TODO: also show other hardware options:
	-- gprs

end



-- public function for sending data to all clients
local function send_to_clients(self, data)
	local nl = translate_NL[config:get("/cit/message_separator")]
	local s = data .. nl

	local mode = config:get("/cit/mode")
	logf(LG_DMP,lgid,"Sending packet with mode='%s'",mode)
	if mode=="UDP" or mode=="client" or mode=="server" then
		-- Send to UDP remote server
		local sock = net.socket("udp")
		local addr = config:get("/cit/remote_ip")
		local port = config:get("/cit/udp_port")
		logf(LG_DBG,lgid,"sendto(addr=%s,port=%d)", addr, port)
		if net.sendto(sock, s, addr, port)~=#s then
			logf(LG_WRN,lgid,"Error sending data to addr=%s,port=%d using UDP", addr, port )
		end
		net.close(sock)
	end
	
	-- connect to server when "TCP client on scan"
	if config:get("/cit/mode") == "TCP client on scan" then
		cit:connect_to_server( )
	end
	
	-- Send to all connected TCP clients
	for client,_ in pairs(self.client_list) do
		if net.send(client.sock, s)~=#s then
			logf(LG_WRN,lgid,"Error sending data to addr=%s,port=%d using TCP", addr, port )
		end
	end
end


---------------------------------------------------------------------------
-- CIT protocol handling
---------------------------------------------------------------------------


local function handle_barcode_normal(self, barcode, prefix)
	logf(LG_DBG,lgid,"handle_barcode_normal")
	local success = true

	if config:get("/dev/scanner/enable_barcode_id")=="true" then
		self:send_to_clients(prefix .. barcode)
	else
		self:send_to_clients(barcode)
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
		logf(LG_DBG,lgid,"Processing line from barcode: %s", l )
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

local function restore_ftp_defaults()
	os.execute("cp /etc/passwd.org /etc/passwd");
	os.execute("cp /etc/shadow.org /etc/shadow");
	os.execute("cp /etc/group.org /etc/group");
	os.execute("cp /etc/gshadow.org /etc/gshadow");
	os.execute("cd /etc && ln -sf vsftpd.conf.anonymous vsftpd.conf");
end

local function restore_defaults()
	logf(LG_INF, lgid, "Scanned 'factory defaults' barcode, restoring and rebooting system");
	os.execute("rm -f /cit200/cit.conf /etc/nowatchdog /mnt/img/* /mnt/fonts/*")
	restore_ftp_defaults()
	os.execute("reboot")
end

local function prepare_for_settings_barcode()
	display:set_font( nil, 18, nil )
	display:show_message( "Programming", "", "Scan settings" )
	if scanner.enable_citical_2d then
		scanner:enable_citical_2d()
	end
end

local function handle_barcode_programming(cit, barcode, prefix)
	logf(LG_DBG,lgid," handle_barcode_programming()")
	local success = true

	if not barcode then

		success = false

	elseif string.match( next_barcode_type, "^security:" ) then
		-- handling authorized_exec()

		next_barcode_type = string.match(next_barcode_type,"^security:(.*)") or ""
		if barcode ~= config:get("/dev/barcode_auth/security_code") then
			display:set_font( nil, 18, nil )
			display:show_message( "Programming", "", "Incorrect", "security", "code" )
			evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout") ) )
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

		if scanner.reinit_2d then
			scanner:reinit_2d()
		end

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
				evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout") ) )
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
		if scanner.reinit_2d then
			scanner:reinit_2d()
		end

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

	if event.data.result == "ok" then

		local barcode = event.data.barcode
		local prefix = event.data.prefix or "?"
		local success = true

		logf(LG_DMP, lgid, "on_barcode()")

		-- TODO: or should scanning really be disabled
		led:set("yellow", "off")

		if barcode == nil then
			success = false
		else
			logf(LG_INF, lgid, "Scanned barcode: '%s%s'", 
					prefix or "", ((#barcode <= 255) and barcode or (barcode:sub(1,255) .. "...")) )

			if barcode_mode == "normal" then
				if barcode == "%#$^*%" then
					logf(LG_INF, lgid, "Scanned 'programming mode' barcode")
					barcode_mode = "programming"
					cit.idle_message_is_disabled = false
					evq:push( "cit_idle_msg", {force=true}, 0 )
					set_programming_mode_timeout()
				else
					success = handle_barcode_normal(cit, barcode, prefix)
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
		end
	
		if not success then
			beeper:beep_error()
		end
	
		led:set("yellow", "on")
	elseif event.data.result == "error" then
		display:clear()
		display:format_text(event.data.msg or "Unspecified error", 1, 1, "c", "m", 18)
		evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout")))
	end

end

-- display an image that can be found in one of the image directories
-- image directories are resp.: /mnt/img/ and /cit200/img/ftp/
-- Note that /mnt/img/ is mounted to /dev/mtdblock/6 OR the sd card (/dev/mmcblk0p1)
-- such images can be uploaded.
-- @param: image   the name of the image. A path is allowed but no ..
local function display_image( cit, image, x, y )
	-- prevent use of paths that go 'up' in the tree
	if image:find( ".*%.%..*" ) then
		logf(LG_WRN,lgid,"No '..' allowed in path for file '%s'.", image)
		return false
	end
	local fname = "/mnt/img/" .. image
	local fstat = sys.lstat( fname )
	if not fstat then
		fname = "/cit200/img/ftp/" .. image
		fstat = sys.lstat( fname )
	end
	if not fstat then
		logf(LG_WRN,lgid,"Image '%s' not found.", image)
		return false
	elseif fstat["isreg"] ~= true then
		logf(LG_WRN,lgid,"File of image '%s' is not a regular file.", image)
		return false
	elseif fstat["size"]>16*1024 then
		logf(LG_WRN,lgid,"Filesize of image '%s' exceeds maximum of 16kB.", image)
		return false
	else
		logf(LG_DBG,lgid,"image='%s', size=%d", fname, fstat["size"])
		display:draw_image( fname, x, y )
		return true
	end
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

	[0x5c] = {
		name = "enable/disable backlight",
		nparam = 1,
		fn = function(cit, onoff)
			gpio:backlight( onoff == 0x31 )
		end
	},

	[0x5d] = {
		name = "sleep/wakeup barcode scanner",
		nparam = 1,
		fn = function(cit, onoff)
			logf(LG_INF, lgid, "Putting scanner to %s", (onoff==0x30 and "sleep" or "wakeup") )
			if onoff == 0x30 and not cit.power_saving_on then
				local itf = config:get("/network/interface")
				local hw = config:get("/dev/hardware")
				local hwnum = tonumber(hw)
				--print("DEBUG: itf=" .. itf .. ", hw=" .. hw .. ", hwnum=" .. (hwnum or "nil"))
				if itf~="ethernet" and (hwnum==nil or hwnum<1.3) then
					logf(LG_WRN,lgid,"Not putting scanner to sleep because " ..
						"it would disable the used network interface (%s) " .. 
						"with this HW version (%s)", itf, hw)
				else
					led:set("yellow","off")
					local ok, err = gpio:set_pin(18, 0)
					cit.power_saving_on = true
				end
			end
			if onoff == 0x31 and cit.power_saving_on then
				local ok, err = gpio:set_pin(18, 1)
				evq:push("reinit_scanner", scanner, 1 )
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
			local port = nr - 0x30 + 1 
			state = state - 0x30
			if (port == 1 or port == 2) and (state == 0 or state == 1) then
				logf(LG_INF, lgid, "Setting GPIO port OUT%d to %d", port, state)
				local ok, err = gpio:set_pin(port == 1 and 1 or 3, state)
				if not ok then
					logf(LG_WRN, lgid, "Error performing GPIO 'set' command: %s", err)
				end
			else
				logf(LG_WRN, lgid, "Incorrect port number (%x) or state value (%x) for gpio out", nr,state)
			end
		end
	},

	[0x7F] = {
		name = "Get GPIO input",
		nparam = 1,
		fn = function(cit, nr)
			local port = nr - 0x30 + 1
			if (port == 1 or port == 2) then
			
				logf(LG_INF, lgid, "Getting GPIO port IN%s", port)
				local value, err = gpio:get_pin(port == 1 and 5 or 7)
				if not value then
					logf(LG_WRN, lgid, "Error performing GPIO 'get' command: %s", err)
				else
					return config:get("/dev/gpio/prefix") .. string.char(nr) .. value;
				end
				
			else
				logf(LG_WRN, lgid, "Incorrect gpio port number (%x) for gpio in", nr)
			end
		end
	},
	
	-- This one is not in the original protocol: display an image
	-- display a default image (see touch-key images) or an uploaded image
	-- specify file with file-extension
	-- use the current pixel positions
	[0xf0] = {
		name = "display an image",
		nparam = 64,
		fn = function( cit, ... )
			cit:display_image( string.char(...), pixel_x, pixel_y )
		end
	},
	
	-- This one is not in the original protocol: relate image to touchscreen key
	-- Format: \xf2 <name released> \x0d <name pressed> \x0d <position by key-id> <coupled to key-id>n \x03
	-- When name-pressed is empty, the image of name-released will be inverted when pressed.
	-- the names of the images shall be without the .gif extension
	-- the names of the images should not be too long and not contain spaces 
	--   together they can have 64-16-3=45 charracters
	[0xf2] = {
		name = "display image and associate to touch-key",
		nparam = 64,
		fn = function( cit, ... )
			-- watch out: the event is handled direct without queueing (delay==-1)!
			evq:push("display_touch_image", {spec = string.char(...)}, -1 )
		end
	},
	
	[0xf3] = {
		name = "show idle message",
		nparam = 0,
		fn = function(cit)
			display:clear() -- effectively disables all possible hooked key-images
			evq:push("cit_idle_msg", {force=true}, 0)
		end
	},
	
	-- clear text layer
	[0xf5] = {
		name = "clear text layer",
		nparam = 0,
		fn = function(cit)
			display:clear(0)
		end
	},

	-- This one is not in the original protocol: show configuration on display
	
	[0xfe] = {
		name = "show configuration",
		nparam = 0,
		fn = function(cit)
			show_configuration()
		end
	},

	-- This one is not in the original protocol.
	-- The instruction is meant for testing purposes only
	-- It only works when the application is started with commandline option -D
	-- It add debug functionality:
	--      0x30 = fake barcode scan
	--      0x31 = code error causing a 'crash' (which should be caught)
	[0xff] = {
		name = "debug functionality",
		nparam = 255,
		fn = function(cit, func, ...)
			if opt.D then
				if func == 0x30 then
					local barcode = string.char(...):sub(2,-1)
					local prefix = string.char(...):sub(1,1)
					logf( LG_DBG, lgid, "Faking barcode '%s%s'", prefix, barcode)
					if barcode == nil then
						logf( LG_WRN, lgid, "No fake barcode data received")
					else
						evq:push("scanner", { result = "ok", barcode = barcode, prefix=prefix })
					end
				elseif func == 0x31 then
					-- simulate crash with error catch for testing purposes
					string.format("%d","string instead of number")
				end
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

	local answer = ""
	
	-- c1000 uses udp packets filled with all \0 charracters to make a complete packet
	-- c1000 bug: see \0\0\0 as an "end of string"
	if c==0 then
		cit.count_nulls_in_a_row = cit.count_nulls_in_a_row + 1
		if cit.count_nulls_in_a_row==3 then
			logf(LG_WRN,lgid,"Faking <EOS> because of 3 null charracters in a row.")
			c=0x03
		end
	else
		cit.count_nulls_in_a_row = 0
	end

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
			if c == 0x03 or cit.last_three == "\0\0\0" then
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
	logf(LG_DBG,lgid,"Received: %s", command)
	for i, c in ipairs( { command:byte(1, #command) } ) do
		local current_answer = handle_byte(cit, c)
		if current_answer and #current_answer>0 then
			logf( LG_DMP, lgid, "Current answer '%s'", current_answer )
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
		if answer and #answer>0 then
			logf( LG_DBG, lgid, "Sending back (UDP) '%s'", answer )
			local nl = translate_NL[config:get("/cit/message_separator")]
			if net.sendto( cit.sock_udp, answer .. nl, destaddr, destport ) ~= #answer+#nl then
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
		if answer and #answer > 0 then
			logf( LG_DBG, lgid, "Sending back (TCP) '%s'", answer )
			local nl = translate_NL[config:get("/cit/message_separator")]
			if net.send(fd, answer .. nl) ~= #answer+#nl then
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
			display_image( cit, "welcome.gif", config:get("/cit/messages/idle/picture/xpos"), config:get("/cit/messages/idle/picture/ypos") )
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

	evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout") ) )
end

local function connect_to_server( cit )

	-- if connected, nothing to do
	if cit.client_connected then
		return true
	end

	logf(LG_DBG,lgid,"connect_to_server()")

	-- Try to connect
	
	local addr = config:get("/cit/remote_ip")
	local port = config:get("/cit/tcp_port")
	local sock = net.socket("tcp")
	local result, err = net.connect(sock, addr, port)
	local ok = result == 0

	if result==1 then
		-- busy due to non blocking sockets
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
	
			-- Enable TCP keep-alive option.
		-- this is required for two reasons:
		--   1. prevent routers of closing inactive connection
		--   2. ability to check the health of the connection without the need to 
		--      sent an application level packet (especially important when using
		--      unreliable connection, eg with a modem)
		local result, errstr = net.setsockopt(sock, "SO_KEEPALIVE", 1);
		if not result then
			logf(LG_WRN, lgid, "setsockopt SO_KEEPALIVE: %s", errstr);
		end
	
		client_new(cit, sock, addr, port)
	else
		net.close(sock)
		logf(LG_WRN, lgid, "Could not connect to %s.%s: %s", addr, port, err)
		return false
	end

	return true
	
end 


local function on_connect_timer(event, cit)
	
	local mode = config:get("/cit/mode")
	-- Nothing to do in server mode or UDP only
	if mode:find("server") or mode=="UDP" or mode == "TCP client on scan" then
		return true
	end

	cit:connect_to_server()
	 
	return true
end


local function init_cit_mode()

	local mode = config:get("/cit/mode")
	local udp_port = config:get("/cit/udp_port")
	local tcp_port = config:get("/cit/tcp_port")
	local remote_ip = config:get("/cit/remote_ip")
	
	-- Close UDP port when needed:
	if cit.sock_udp ~= nil and 
			(udp_port ~= cit.udp_port or mode:find("TCP")) then
		close_udp(cit)
	end
	-- Open udp port when not "TCP server" and not "TCP client" or "TCP client on scan"
	if cit.sock_udp == nil and not mode:find("TCP") then
		local sock = net.socket("udp")
		net.bind(sock, "0.0.0.0", udp_port);
		evq:fd_add(sock)
		cit.sock_udp = sock
		logf(LG_INF, lgid, "Listening on UDP port %d", udp_port)
	end

	-- Close TCP port when needed
	if cit.sock_tcp ~= nil and 
			(tcp_port ~= cit.tcp_port or not mode:find("server")) then
		close_tcp(cit)
	end
	if cit.sock_tcp == nil then
		if mode:find("server") then
			-- Open tcp listen port mode is "server" or "TCP server"
			local sock = net.socket("tcp")
			net.bind(sock, "0.0.0.0", tcp_port)
			net.listen(sock, 5)
			evq:fd_add(sock)
			cit.sock_tcp = sock
			logf(LG_INF, lgid, "Listening on TCP port %d", tcp_port)
		end
	end

	cit.udp_port = udp_port
	cit.tcp_port = tcp_port
	cit.remote_ip = remote_ip
	
end

-- react to "draw_idle_msg" event
-- when force==true: reset idle timeout
-- use cit.idle_message_is_disabled==false to enable the idle message when required
local function on_draw_idle_msg(event, cit) 
	if not cit.idle_message_is_disabled then
		if event.data and event.data.force==true then
			logf(LG_DBG,lgid,"force display of idle message, reset idle timeout")
			-- disable timeout:
			t_lastcmd = 0
		end
		cit:draw_idle_msg() 
	end
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


	-- Initialize listening tcp and udp
	evq:register("fd", on_udp, cit)
	evq:register("fd", on_tcp_server, cit)
	init_cit_mode()

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

	cit.idle_message_is_disabled = false
	evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout") ) )

	-- Led on, we're ready to scan
	
	led:set("yellow", "on")

end

-- close udp listening port
local function close_udp(cit)
	if cit.sock_udp then
		net.close(cit.sock_udp)
		evq:fd_del(cit.sock_udp)
		cit.sock_udp = nil
	end
end

-- close tcp connections and listening port
local function close_tcp(cit)
	if cit.sock_tcp then
		net.close(cit.sock_tcp)
		evq:fd_del(cit.sock_tcp)
		cit.sock_tcp = nil
	end

	for client,_ in pairs(cit.client_list) do
		net.close(client.sock)
		evq:fd_del(client.sock)
		evq:unregister("fd", on_tcp_client, client)
		cit.client_list[client] = nil
	end
	cit.client_connected = false
end

--
-- Stop CIT and cleanup
--
local function stop(cit)
	logf(LG_DBG,lgid,"stop()")	
	logf(LG_INF, lgid, "Stopping CIT server")

	close_udp(cit)
	close_tcp(cit)
	evq:unregister("fd", on_udp, cit)
	evq:unregister("fd", on_tcp_server, cit)

	evq:unregister("scanner", on_barcode, cit)
	evq:unregister("cit_idle_msg", on_draw_idle_msg, cit)
	evq:unregister("cit_error_msg", on_draw_error_msg, cit)
end


function set_fontsize() 
	fontsize_small = config:lookup("/cit/messages/fontsize/small"):get()
	fontsize_big = config:lookup("/cit/messages/fontsize/large"):get()
end

--
-- ftp handling
--

local function os_execute( cmd )
	logf(LG_DBG, lgid, "Executing command: \"%s\"", cmd)
	return os.execute( cmd )
end


-- just reinstate the encrypted password for the current ftp user:
local function on_change_ftp_encrypted()
	logf(LG_DMP,lgid,"on_change_ftp_encrypted()")
	local user = config:get("/dev/auth/username")
	local shadow = make_shadow_password(config:get("/dev/auth/encrypted"))
	-- we can't use vi because the encrypted password can contain $ and / signs
	-- so we just use the default file and add our user
	os_execute("cp /etc/shadow.org /etc/shadow");
	os_execute(string.format("echo '%s:%s:0:0:99999:7:::' >> /etc/shadow", user, shadow));
end


-- change the configured ftp-user
local function on_change_ftp_username()
	if config:get("/dev/auth/enable")=="true" then
		logf(LG_DMP,lgid,"on_change_ftp_username()")
		-- remove prev. ftp-user:
		os_execute(string.format("deluser `cat /etc/vsftpd.user_list`"))
	
		local user = config:get("/dev/auth/username")

		-- add user
		local cmd = ""
		os_execute(string.format("adduser -h /home/ftp -H -s /bin/sh -G ftp -S -D '%s'", user))
		os_execute(string.format("echo '%s' > /etc/vsftpd.user_list", user))
		on_change_ftp_encrypted()
	end
end


-- enable or disable ftp-authentication (anonymous ftp or not)
local function on_change_ftp_auth()
	logf(LG_DMP,lgid,"on_change_ftp_auth_enable()")
	if config:get("/dev/auth/enable")=="false" then
		logf(LG_INF, lgid, "Restoring anonymous ftp-user")
		restore_ftp_defaults()
		config:lookup("/dev/auth/encrypted"):set("")
	else
		-- only allow enabling authentication when a user and password are set
		if config:get("/dev/auth/username") == "" or config:get("/dev/auth/encrypted") == "" then
			logf(LG_WRN,lgid,"Not enabling authentication failed because username or encrypted-password is not set")
			config:lookup("/dev/auth/enable"):set("false")
			config:lookup("/dev/auth/encrypted"):set("")
		else
			os.execute( "cd /etc; ln -sf vsftpd.conf.user vsftpd.conf" )
			on_change_ftp_username()
		end
	end
	os_execute( "killall vsftpd; vsftpd &" )
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
		udp_port = "",
		sock_udp = nil,
		tcp_port = "",
		sock_tcp = nil,
		remote_ip = "",

		power_saving_on = false,
		count_nulls_in_a_row = 0, -- used for ignoring three or more \0 charracters in display text (c1000 bug)
		idle_message_is_disabled = false, -- added for touchscreen handling

		-- methods
		-- Note that it is allowed for 'plugin' modules to call these methods
		-- because cit.lua is not allowed to call plugin method directly (only
		-- via evq:push()

		start = start,
		stop = stop,
		draw_idle_msg = draw_idle_msg,
		draw_error_msg = draw_error_msg,
		send_to_clients = send_to_clients,
		display_image = display_image,
		restore_defaults = restore_defaults,
		connect_to_server = connect_to_server,
	}

	set_password_salt( password_salt )
	
	config:add_watch("/cit", "set", function() 
		cit:stop()
		cit:start()
	end)

   local function reinit_on_network_up(event,cit) 
		logf(LG_DBG,lgid,"Reinit on network_up because network config was changed.")
		init_cit_mode()
		evq:unregister("network_up", reinit_on_network_up, cit)
	end

	evq:register( "network_reconfigure", 
		function (node,cit)
			logf(LG_DBG,lgid,"Closing all tcp connections because network settings changed.")
			close_tcp( cit )
			evq:register("network_up", reinit_on_network_up, cit)
		end, cit)

	config:add_watch("/cit/messages/fontsize", "set", set_fontsize ) 
	set_fontsize()

	-- Check if there are any fonts on the sd card we can use
	-- there are two directories on the sd card: 
	-- /mnt          legacy, the fontfile is burned on the sd-card before it was inserted into the nquire
	-- /mnt/fonts    this is mounted to /home/ftp, font upload by ftp is possible (overrules /mnt)

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
	
	local files = sys.readdir("/mnt/fonts")
	if files then
		for _, file in ipairs(files) do
			local tmp = file:match(".+\.ttf$")
			if tmp then
				font = "/mnt/fonts/" .. tmp
				break
			end
		end
	end

	display:set_font( font, fontsize_small )
	
	-- Start connect timer for client mode

	evq:register("connect_timer", on_connect_timer, cit)
	evq:push("connect_timer", cit, 3.0)

	evq:register("programming_mode_timeout", on_programming_mode_timeout, cit)
	
	-- configure ftp in case the cit.conf is overwritten during startup (/mnt/cit.conf)
	on_change_ftp_auth()
	
	config:add_watch("/dev/auth", "set", on_change_ftp_auth)

	logf(LG_INF, lgid, "Using font file %q", font)
	
	return cit

end

-- vi: ft=lua ts=3 sw=3

