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

local ETX = '\3'
local ACK = '\6'
local LF = '\10'  -- \n
local CR = '\13'  -- \r
local NAK = '\21'
local ESC = '\27'

local fontsize_small = 24
local fontsize_big = 32

local fontsize = fontsize_small

local pixel_x = 0
local pixel_y = 0

local align_h = "l"
local align_v = "t"

local message_received = false

-- variables for handling the delayed message

local one_time_timeout_id = nil -- identify the timeout (with hirestime of the moment it wat set)
local one_time_timeout_msg = nil -- "cit_idle_msg" or "cit_error_msg"
local one_time_timeout_tag = nil -- the tag given for this timeout


local t_idle_msg = 0 -- the moment (hirestime) after which an idle message is allowed to be shown

local sector_data_seperators = { ["none"]="", ["space"]="", ["tab"] = "\t", ["comma"] = ",", ["colon"]=":", ["semicolon"] = ";" }

-- next_barcode_type can be one of "", "default", "config", "serial", "security:barcode"
-- This indicates what the next barcode means.
-- The security barcode is a delayed handling of barcode: first a security code must be read,
-- only then the barcode can be handled.
local next_barcode_type = ""
local barcode_mode = "normal"

local translate_NL = { ["LF"] = "\n", ["CR"] = "\r", ["CRLF"] = "\r\n" }

local function expand_message_tag()
	if config:get("/cit/enable_message_tag")=="true" then
		local tag = config:get("/cit/message_tag")

		-- replace variables:
		tag = tag:gsub("%${serial}", config:get("/dev/serial") )
		tag = tag:gsub("%${mac}", config:get("/network/macaddress_eth0") )

		return tag
	else
		return ""
	end
end


-- Show idle message after a delay
-- This will have no effect when a longer delay was already set
local function push_cit_idle_msg( delay_sec )
	local delay = delay_sec or tonumber(config:get("/cit/messages/idle/timeout"))
	local t = sys.hirestime() + delay
	if t > t_idle_msg then
		t_idle_msg = t
		evq:push("cit_idle_msg", nil, delay)
	end
end

local function set_keepalive( sock )
	local result, errstr = net.setsockopt(sock, "SO_KEEPALIVE", 1);
	if not result then
		logf(LG_WRN, lgid, "setsockopt SO_KEEPALIVE: %s", errstr);
	end
end

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
	local mac_eth0 = config:get("/network/macaddress_eth0")
	display:draw_text("eth %s", mac_eth0)
	local mac_wlan0 = config:get("/network/macaddress_wlan0")
	if #mac_wlan0 > 0 then
		display:draw_text(", wifi %s", mac_wlan0)
	end
	display:draw_text("\n")
	
	-- scanner:
	local scanner_fw = config:get("/dev/scanner/version")
	if #scanner_fw > 0 then
		display:draw_text("%s\n", scanner_fw)
	end

	-- touch screen
	local touch16_name = config:get("/dev/touch16/name")
	if #touch16_name > 0 then
		display:draw_text(touch16_name .. "\n")
	end

	local sep = ""
	
	-- mifare:
	local mifare_model = config:get("/dev/mifare/modeltype")
	if #mifare_model > 0 then
		display:draw_text(sep .. "mifare " .. mifare_model)
		sep = ", "
	end

	-- sd card:
	local mmc = config:get("/dev/mmcblk")
	if #mmc > 0 then
		display:draw_text(sep .. "sd card:" .. mmc)
		sep = ", "
	end
		
	-- TODO: also show other hardware options:
	-- gprs

	push_cit_idle_msg( 10 )
	
end



-- public function for sending data to all clients
local function send_to_clients(self, data)
	local nl = translate_NL[config:get("/cit/message_separator")]
	local s = expand_message_tag() .. data .. nl
	if config:get("/cit/message_encryption") == "base64" then
		s = base64.encode( s ) .. nl
	end

	local mode = config:get("/cit/mode")
	logf(LG_DBG,lgid,"Sending packet with mode='%s'",mode)
	if mode=="UDP" or mode=="client" or mode=="server" then
		local host = config:get("/cit/resolved_remote_ip")
		local ips, errstr = net.gethostbyname( host )
		if ips == nil then
			logf(LG_WRN, lgid, "Could not resolve host %s: %s", host, (errstr or "nil"))
			logf(LG_WRN, lgid, "Data will not be send using udp")
		else
			-- send to all addresses associated with host
			for i,addr in pairs(ips) do
				local port = config:get("/cit/udp_port")
				-- Send to UDP remote server
				local sock = net.socket("udp")
				logf(LG_DBG,lgid,"sendto(addr=%s,port=%d)", addr, port)
				if net.sendto(sock, s, addr, port)~=#s then
					logf(LG_WRN,lgid,"Error sending data to %s (addr=%s), port=%d using UDP", host, addr, port )
				end
				net.close(sock)
			end
		end
	end
	
	-- connect to server when "TCP client on scan"
	if config:get("/cit/mode") == "TCP client on scan" then
		cit:connect_to_server( )
	end
	
	-- Send to all connected TCP clients
	for client,_ in pairs(self.client_list) do
		logf( LG_DBG,lgid,"Sending to client-socket")
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

local function reboot()
	os.execute("sync")
	sys.sleep(2) -- give mmc time to write the data
	os.execute("umount /home/ftp/img/default /home/ftp/img /home/ftp/log")
	os.execute("umount /home/ftp/fonts")
	os.execute("umount /mnt/mmc")
	os.execute("umount /mnt")
	os.execute("reboot")
end

local function restore_ftp_defaults()
	os.execute("cp /etc/passwd.org /etc/passwd");
	os.execute("cp /etc/shadow.org /etc/shadow");
	os.execute("cp /etc/group.org /etc/group");
	os.execute("cp /etc/gshadow.org /etc/gshadow");
	os.execute("cd /etc && ln -sf vsftpd.conf.anonymous vsftpd.conf");
end


local function restore_defaults()
	logf(LG_INF, lgid, "Scanned 'factory defaults' barcode, restoring and rebooting system")

	os.execute("rm -f /mnt/img/* /mnt/log/* /mnt/fonts/*")
	os.execute("rm -f /mnt/mmc/img/* /mnt/mmc/log/* /mnt/mmc/fonts/*")
	os.execute("rm -f /cit200/*.conf /etc/nowatchdog /mnt/*.conf")
	-- remove possible files from versions prior to 1.6
	os.execute("rm -f /mnt/*conf.bkup /mnt/mmc/*conf.bkup")
	restore_ftp_defaults()

	reboot()

end


local function prepare_for_settings_barcode()
	display:set_font( nil, 18, nil )
	display:show_message( "Programming", "", "Scan settings" )
	if scanner.enable_citical_2d then
		scanner:enable_citical_2d()
	end
end

local function show_wlan_diag( )
	display:set_font( nil, 18, nil )
	if config:get("/network/interface") ~= "wifi" then
		display:show_message( "diagnosis only", "available for wifi" )
		push_cit_idle_msg( )
	else
		display:show_message( "", "Starting", "wlan diagnosis" )
		display:update(true)
	
		local f = io.popen("iwlist wlan0 scan")
		if f then
			local l
			local our_essid = config:get("/network/wifi/essid")
			logf(LG_DBG,lgid,"our_essid=%s", our_essid)
			local curr_address
			local aps = {} -- list of access points (index by mac address)
			local essid_aps = {} -- the aps of our essid
			local channels = {}
			repeat
				l = f:read()
				if l then
					local address = l:match("Address:%s*(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x)")
					if address then 
						curr_address = address
						aps[address] = {}
						logf(LG_DBG,lgid,"curr_address=%s", curr_address)
					end

					local essid = l:match("ESSID:%s*\"(.*)\"")
					if essid then 
						aps[curr_address].essid = essid
						logf(LG_DBG,lgid,"aps[%s].essid=%s", curr_address, essid)
						if essid == our_essid then
							table.insert( essid_aps, curr_address )
						end
					end
					
					local channel = l:match("Channel%s*(%d%d?)")
					if channel then
						logf(LG_DBG,lgid,"aps[%s].channel=%s", curr_address, channel)
						aps[curr_address].channel = channel
						if not channels[channel] then
							channels[channel] = {}
							channels[channel].addresses = {}
						end
						table.insert( channels[channel].addresses, curr_address )
						
					end
					
				end
			until l == nil
			
			f:close()
			
			-- check whether there is a channnel conflict on one of our aps
			local problem_channels = {}
			local has_problem_channels = false
			for mac,ap in pairs( aps ) do
				if ap.essid == our_essid and #channels[ap.channel].addresses > 1 then
					problem_channels[ap.channel] = channels[ap.channel]
					has_problem_channels = true
				end
			end
			
			display:clear()
			display:set_font( nil, 18, nil )

			if #essid_aps == 0 then	
				display:draw_text("Could not find accesspoint\n")
				display:set_font( nil, display["native_font_size"])
				display:draw_text("essid: \"" .. our_essid .. "\"")
			elseif has_problem_channels then
				display:draw_text("Detected channel conflic:\n")
				display:set_font( nil, display["native_font_size"])
				for i,channel in pairs( problem_channels ) do
					display:draw_text("channel %s:\n", i)
					for j,mac in pairs( channel.addresses ) do
						display:draw_text("  %s (essid: \"%s\")\n", mac, aps[mac].essid or "")
					end
				end
			else
				local wpa_status = network:get_wpa_status()

				-- just show an overview
				if wpa_status["wpa_state"] == "COMPLETED" then
					display:draw_text("Network overview\n")
				else
					display:draw_text("No AP connection (yet)\n")
				end
				display:set_font( nil, display["native_font_size"])
				display:draw_text("AP with essid=\"%s\":\n", our_essid)
				local sep=""
				for i,mac in pairs(essid_aps) do
					display:draw_text("%s%s",sep, mac)
					if sep == ", " then sep = "\n" else sep = ", " end
				end
				
				local f
				
				f = io.popen( "iwconfig wlan0" )
				if f then
					local l
					repeat
						l = f:read()
						if l and (l:match("Link Quality") or l:match("Tx-Power")) then
							display:draw_text("\n%s", l:match("%s*(.*)"))
						end		
					until l == nil
					f:close()
				end
				
				for k,v in pairs(wpa_status) do
					display:draw_text("\n%s=%s", k, v)
				end

			end

		else
			display:show_message( "Error", "failed", "wlan diagnosis" )
		end

		push_cit_idle_msg( 10 )
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
			push_cit_idle_msg( )
			success = false
			next_barcode_type = ""
		else
			if next_barcode_type == "defaults" then
				restore_defaults()
			elseif next_barcode_type == "config" then
				prepare_for_settings_barcode()
			else
				-- bug, should not happen
				push_cit_idle_msg( 0 )
				success = false
				next_barcode_type = ""
			end
		end

	elseif next_barcode_type == "serial" then

		logf(LG_INF, lgid, "Programming product serial number: %s", barcode)
		config:lookup("/dev/serial"):set(barcode)
		next_barcode_type = ""
		push_cit_idle_msg( 0 )

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

		push_cit_idle_msg( 0 )

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
				reboot()
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
			elseif par == "06" then
				show_wlan_diag( )
			else
				display:set_font( nil, 18, nil )
				display:show_message( "Programming", "", "Unknown code" )
				success = false
			end
			push_cit_idle_msg( )
		else
			success = false
		end
	end
	return success
end


local function end_barcode_programming()
	barcode_mode = "normal"
	next_barcode_type = ""
	t_idle_msg = 0
	evq:push( "cit_idle_msg", nil, 0 )
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



-- Display an image that can be found in one of the image directories
-- Image directories are resp.: /home/ftp/img and /home/ftp/img/default
-- Note that /home/ftp/img/ is mounted to /mnt/img or /mnt/mmc/img, so uploaded
-- images are persistent
-- @param: image   the name of the image. A path is allowed but no ..
local function display_image( cit, image, x, y )
	-- prevent use of paths that go 'up' in the tree
	if image:find( ".*%.%..*" ) then
		logf(LG_WRN,lgid,"No '..' allowed in path for file '%s'.", image)
		return false
	end
	local fname = "/home/ftp/img/" .. image
	local fstat = sys.lstat( fname )
	if not fstat then
		fname = "/home/ftp/img/default/" .. image
		fstat = sys.lstat( fname )
	end
	if not fstat then
		logf(LG_WRN,lgid,"Image '%s' not found.", image)
		return false
	elseif fstat["isreg"] ~= true then
		logf(LG_WRN,lgid,"File of image '%s' is not a regular file.", image)
		return false
	elseif fstat["size"]>24*1024 then
		logf(LG_WRN,lgid,"Filesize of image '%s' exceeds maximum of 24kB.", image)
		return false
	else
		logf(LG_DBG,lgid,"image='%s', size=%d", fname, fstat["size"])
		display:draw_image( fname, x, y )
		return true
	end
end

local function read_mifare_card( cit, msg )
	local cardnum, keyA, specs = msg:match("^(%x+),(%x*):(.*)")
				
	if cardnum == nil or specs == nil or #specs==0 or
			(#cardnum~=8 and #cardnum~=16) or 
			(#keyA~=0 and #keyA~=8 and #keyA~=12) then
		logf(LG_WRN,lgid,"Message format error")
		return NAK .. "7"
	else
		-- first verify that we are reading the right card
		local info_result, real_cardnum, cardtype, nsect, nblock, blocksize, keysize = scanner_rf:query_cardinfo()
		if info_result == 0 and cardnum ~= real_cardnum then
				-- try again (could be a read-error)
				logf(LG_DBG,lgid,"Incorrect card detected. Re-reading to exclude read-errors")
				info_result, real_cardnum, cardtype, nsect, nblock, blocksize, keysize = scanner_rf:query_cardinfo()
		end
		logf(LG_DBG,lgid,"Real cardnum = %s", cardnum or "nil")
		if info_result ~= 0 then
			logf(LG_WRN,lgid,"Could not verify cardnum (error=%d)", info_result)
			return NAK .. "5"
		elseif cardnum ~= real_cardnum then
			logf(LG_WRN,lgid,"Cardnum mismatch req=%s, real=%s", cardnum, real_cardnum or "nil")
			return NAK .. "5"
		else
		
			-- set key:
			local chkkey_result = scanner_rf:chkkey( string.sub(keyA,0,keysize) )
			if chkkey_result ~= 0 then
				return NAK .. "3"
			end
			
			local stopped = scanner_rf:stop_card_detection()

			if cardtype == "MIFARE_ULTRALIGHT" then
				-- MIFARE ULTRALIGHT requires read ops before read
				scanner_rf:readblock(0,0,blocksize)
			end

			-- read data:
			local data = ""
			local sep = ""
			local sepact = sector_data_seperators[config:get("/dev/mifare/sector_data_seperator")]
			while #specs~=0 do
				local sector_chr,block_chr,format,rest = specs:match("^(.)(.)([BH])(.*)")
				local sector = sector_chr:byte()-0x30
				local block = block_chr:byte()-0x30
				if sector_chr == nil or sector<0 or sector>=16 or block<0 or block>=32 then
					logf(LG_WRN,lgid,"Message format error: %s, sector=%d, block=%d", specs, sector, block)
					if stopped then scanner_rf:start_card_detection() end
					return NAK .. "4"
				else
					specs = rest or ""
					local pdata, result = scanner_rf:readblock( sector, block, blocksize )
					if pdata == nil then
						if stopped then scanner_rf:start_card_detection() end
						return NAK .. "1"
					else
						if format == "B" then
							data = data .. sep .. pdata
						else -- "H"
							data = data .. sep .. pdata:gsub("(.)",function (c) return string.format( "%02x", string.byte(c) ) end )
						end
						sep = sepact
					end
				end
			end
			
			if stopped then scanner_rf:start_card_detection() end

			return ACK .. data
		end
	end
end


-- @param msg: <carnum>,<transaction id>:K<keyA>{{{W<sector><block><format><data>}|{K<keyA>}}}+
local function write_mifare_card( cit, msg )

	local cardnum, transaction_id, cmds = msg:match("^(%x+),(%x+):(.+)")
	if cardnum == nil or (#cardnum~=8 and #cardnum~=16) then
		logf(LG_WRN,lgid,"Incorrect message format: \"%s\"", msg)
		return NAK .. "7"
	elseif #transaction_id > 8 then
		logf(LG_WRN,lgid,"Rfid transaction id too big %s", transaction_id)
		return NAK .. "7"
	else
		-- first validate the format and construct a 'command' list
		local commands = {}
		local result = NAK
		while #cmds ~= 0 do
			logf(LG_DBG,lgid,"cmds='%s'", cmds)
			local command = cmds:sub(1,1)
			if command == "K" then -- keyA, reserve 'k' for keyB
				local keyA, rest = cmds:match("^K(%x*),?([KW].*)")
				if keyA == nil or (#keyA~=0 and #keyA~=8 and #keyA~=12) then
					logf(LG_WRN,lgid,"Format error in '%s'", cmds)
					return result .. "K4"
				else
					table.insert(commands,{cmd="K", keyA=keyA})
					cmds=rest
					result = result .. "K0"
					key_defined = true
				end
			elseif command == "W" then
				local sector_chr, block_chr, format, rest = cmds:match("^W(.)(.)([BH])(.*)")
				if sector_chr == nil then
					logf(LG_WRN,lgid,"Format error '%s'", cmds)
					return result .. "W4"
				end
				local sector = sector_chr:byte() - 0x30
				local block = block_chr:byte() - 0x30
				if sector_chr == nil or sector<0 or sector>=16 or block<0 or block>=32 then
					logf(LG_WRN,lgid,"Format error in '%s'", cmds)
					return result .. "W4"
				else
					local data = ""
					if format == "B" and #rest >= 16 then
						data = rest:sub(1,16)
						cmds = rest:sub(17)
					elseif format == "H" then
						local data_hex, rest = rest:match("^(%x+),?(.*)")
						if data_hex then
							data = data_hex:gsub("(%x%x)", function (cc) return string.char(tonumber(cc,16)) end )
							cmds = rest
						else
							logf(LG_WRN,lgid,"format error (no data) in '%s'", cmds)
							return result .. "W4"
						end
					else
						logf(LG_WRN,lgid,"format error (data) in '%s'", cmds)
						return result .. "W4"
					end
					table.insert(commands,{cmd="W", sector=sector, block=block, data=data})
					result = result .. "W0"
				end
			elseif command == "I" then
				logf(LG_WRN,lgid,"Mifare block increment: not implemented")
				return result .. "I4"
			elseif command == "D" then
				logf(LG_WRN,lgid,"Mifare block decrement: not implemented")
				return result .. "D4"
			else
				logf(LG_WRN,lgid,"Unknown mifare write cmd: '%s'", command)
				return result .. "?" .. "4"
			end
		end

		-- verify space on log-partition simply by creating and removing a file 
		-- ('df' is not reliable because it is a compressed partition)
		local ftmp = io.open( "/home/ftp/log/tmp.log", "w" )
		if ftmp==nil then
  			logf(LG_WRN,lgid,"File system full for mifare logging.")
			evq:push("cit_send_to_clients", "W1", 1 )
			return NAK .. "6"
		end
		ftmp:close()
		os.remove("/home/ftp/log/tmp.log")

		local stopped = scanner_rf:stop_card_detection()
		result = ""
		local retval = ""
		-- than write the card and write to log.
		local flog = io.open( "/home/ftp/log/mifare.log", "a" )
		if flog==nil then
			logf(LG_WRN, lgid, "Could not open log-file: mifare transaction refused")
			result = NAK .. "6"
		else
			-- first verify that the card is not exchanged for another
			local info_result, real_cardnum, cardtype, nsect, nblock, blocksize, keysize = scanner_rf:query_cardinfo()
			if info_result == 0 and cardnum ~= real_cardnum then
				-- try again (could be a read-error)
				logf(LG_DBG,lgid,"Incorrect card detected. Re-reading to exclude read-errors")
				info_result, real_cardnum, cardtype, nsect, nblock, blocksize, keysize = scanner_rf:query_cardinfo()
			end
			logf(LG_DBG,lgid,"Real cardnum = %s", cardnum)

			if info_result ~= 0 then
				logf(LG_WRN,lgid,"Could not verify cardnum (error=%d)", info_result)
				result = "2"
			elseif cardnum ~= real_cardnum then
				logf(LG_WRN,lgid,"Cardnum mismatch req=%s, real=%s", cardnum, real_cardnum or "nil")
				result = "5"
			else
				if cardtype == "MIFARE_ULTRALIGHT" then
					-- MIFARE ULTRALIGHT requires read ops before write
					scanner_rf:readblock(0,0,blocksize)
				end
				for _,cmd in ipairs(commands) do
					if cmd.cmd == "K" then
						logf(LG_DBG,lgid,"Executing mifare sub-comand: %s", cmd.cmd)
						local r = scanner_rf:chkkey( string.sub(cmd.keyA, 0, keysize) )
						if r ~= 0 then
							logf(LG_WRN,lgid,"Check key error")
							result = result .. "K2"
							break
						else
							result = result .. "K0"
						end
					elseif cmd.cmd == "W" then
						local wdata = string.sub(cmd.data, 0, blocksize)
						logf(LG_DBG,lgid,"Executing mifare sub-comand: %s on sector %d block %d, with data '%s'", cmd.cmd, cmd.sector, cmd.block, wdata)
						local r = scanner_rf:writeblock( cmd.sector, cmd.block, wdata )
						if r ~= 0 then
							result = result .. "W3"
							break
						else
							result = result .. "W0"
						end
					end
				end
			end

			local logstring
			if result:match("0$") then
				logstring = transaction_id .. ":0\n"
				retval = ACK
			else
				logstring = transaction_id .. ":" .. result .. "\n"
				retval = NAK .. result
			end
			flog:write( logstring )
			flog:close()
			
			-- verify whether the transaction was really written to the log-file:
			local f = io.open( "/home/ftp/log/mifare.log", "r" )
			if f then
				local t = f:read("*all")
				f:close()
				if #t > 2000 then
					-- send a log-rotate request
					logf(LG_INF,lgid,"Big log-file detected")
					evq:push("cit_send_to_clients", "W8", 1 )
				end
				local last = t:sub( -#logstring )
				if last ~= logstring then
					logf(LG_WRN,lgid,"Transaction not logged: '%s'", logstring)
					retval = NAK .. result .. "6"
				else
					logf(LG_DBG,lgid,"Transaction logging '%s':  verified", logstring)
				end
			else
				logf(LG_WRN,lgid,"Could not verify transaction logging of: '%s'", logstring)
				retval = NAK .. result .. "6"
			end
		end

		if stopped then
			scanner_rf:start_card_detection()
		end

		return retval
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
			logf(LG_DBG,lgid,"pixel_x=%d, pixel_y=%d", pixel_x, pixel_y)
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
			reboot()
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
	
	-- This one is not in the original protocol: display and relate image to touchscreen key
	-- Format: \xf2 <name released> \x0d <name pressed> \x0d <position by key-id> <coupled to key-id>n \x03
	-- When name-pressed is empty, the image of name-released will be inverted when pressed.
	-- the names of the images shall be without the .gif extension
	-- the names of the images should not be too long and not contain spaces 
	--   together they can have 64-16-3=45 charracters
	[0xf2] = {
		name = "display image and associate to touch-key",
		nparam = 64,
		fn = function( cit, ... )
			if keyboard ~= nil then
				local dta = string.char(...)
				local released_img, pressed_img, pos, spec = string.match( dta, "^([%w-_]+.gif)\r([%w-_.]*)\r(%x)(%x+)$" )
				logf(LG_DBG,lgid,"release_img='%s', pressed_img='%s', pos=%s, spec=%s", (released_img or "nil"), (pressed_img or "nil"), (pos or "nil"), (spec or "nil"))

				if released_img == nil then
					logf(LG_WRN,lgid,"Incorrect data for display touch image. Command: '%s'", dta )
					return
				end
			
				-- watch out: the event is handled direct without queueing (delay==-1)!
				-- TODO: refactor to a normal function call
				evq:push("display_touch_image", {
						search_path="/home/ftp/img:/home/ftp/img/default",
						gif_released=released_img,
						gif_pressed=pressed_img,
						key_pos=pos,
						keys=spec}, -1)
			else
				logf(LG_WRN,lgid,"No touch keyboard detected")
			end
		end
	},
	
	[0xf3] = {
		name = "show idle message",
		nparam = 0,
		fn = function(cit)
			display:clear() -- 'clear' disables all possible hooked key-images
			t_idle_msg = 0
			evq:push("cit_idle_msg", {force=true}, 0)
		end
	},


	[0xf4] = {
		name = "set one-time-timeout and server-event",
		-- Delay error or idle message timeout and send a server event before this
		-- message is displayed, giving the server a chance to show a custom message
		-- format: <msg-type><delay><timeout><tag>
		-- msg-type    ::= "E" | "I"     (display error or idle message)
		-- delay       ::= \x31 .. \xff  (delay time before event will be sent: resp. 1 to 207 seconds)
		-- msg_timeout ::= \x31 .. \xff  (one time idle or error message timeout)
		nparam = 43,
		fn = function(cit, msg_type, delay, timeout, ...)
			delay = delay and (delay - 0x30) or 0
			timeout = timeout and (timeout - 0x30) or 0
			msg_type = msg_type and string.char(msg_type) or "nil"
			local tag = string.char(...)
			if msg_type ~= "I" and msg_type ~= "E" then
				logf(LG_WRN,lgid,"Incorrect message type '%s' (should be 'E' or 'I')", msg_type)
			elseif delay < 1 then
				logf(LG_WRN,lgid,"Incorrect delay value \\x%02x (should be between \\x31 and \\xff)", delay+0x30)
			elseif timeout < 1 then
				logf(LG_WRN,lgid,"Incorrect timeout value \\x%02x (should be between \\x31 and \\xff)", delay+0x30)
			else	
				logf(LG_DBG,lgid,"Delaying message %s for %d seconds, than timing out with %d seconds", msg_type, delay, timeout )
				msg = msg_type == "I" and "cit_idle_msg" or "cit_error_msg"
				-- the last one-time-timeout counts when used more than once:
				one_time_timeout_id = sys.hirestime()
				one_time_timeout_msg = msg
				one_time_timeout_tag = tag
				logf(LG_DBG,lgid,"Setting one-time-timeout-time to %d seconds from %d", timeout, one_time_timeout_id)
				evq:push("cit_sendevent_for_msg", {one_time_timeout_id=one_time_timeout_id, msg_timeout = timeout, msg_type = msg }, delay)
			end
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




	[0xf8] = {
		name = "mifare read",
		nparam = 60, 
		fn = function(cit, ...)
			if scanner_rf then
				-- format: <carnum>,<keyA>:{<sector><block>}n
				return read_mifare_card( cit, string.char(...) )
			else
				logf(LG_WRN,lgid,"No mifare HW detected")
				return NAK .. "1"
			end
		end
	},

	[0xf9] = {
		name = "mifare write", -- write/increment/decrement
		nparam = 512, -- just some sensible maximum
		fn = function(cit, ...)
			if scanner_rf then
				-- format: <carnum>,<transaction id>:K<keyA>{{{W<sector><block><format><data>}|{K<keyA>}}}+
				return write_mifare_card( cit, string.char(...) )
			else
				logf(LG_WRN,lgid,"No mifare HW detected")
				return NAK .. "1"
			end
		end
	},

	[0xfa] = {
		name = "shift mifare transaction log",
		nparam = 9,
		fn = function(cit, ...)
			if scanner_rf then
				-- format: <fileid>
				local par = string.char(...)
				local fileid = string.match( par, "^%x+$" )
				if fileid == nil  then
					logf(LG_WRN,lgid,"Incorrect file-id '%s' for shifting the mifare transaction log", par )
					return NAK .. "4"
				else
					local fname = "/home/ftp/log/mifare.log"
					local shiftfname = "/home/ftp/log/mifare-" .. fileid ..".log"
					os.execute("touch " .. fname .. "; mv " .. fname .. " " .. shiftfname .. "; chmod 777 " .. shiftfname )
					os.execute("touch " .. fname .. "; chmod 744 " .. fname)
					return ACK
				end
			else
				logf(LG_WRN,lgid,"No mifare HW detected")
				return NAK .. "1"
			end
		end
	},


	[0xfb] = {
		name = "enable/disable mifare card detection",
		nparam = 1,
		fn = function(cit, onoff)
			if scanner_rf then
				-- onoff: 0x30=off, 0x31=on
				if onoff == 0x30 then
					scanner_rf:stop_card_detection()
				elseif onoff == 0x31 then
					scanner_rf:start_card_detection()
				else
					logf(LG_WRN,lgid,"Invalid parameter: 0x%02x", onoff )
				end
			end
		end
	},


	[0xfe] = {
		name = "show configuration", -- on display
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

local bytes_remaining = ""
local function handle_bytes(cit, bytes)

	local answer=""

	message_received = true
	local encryption = config:get("/cit/message_encryption")
	local nl = translate_NL[config:get("/cit/message_separator")]
			
	if encryption == "base64" then
		bytes_remaining = bytes_remaining .. bytes
		logf(LG_DBG,lgid, "Decoding (base64): \"%s\"", bytes_remaining)
		command = ""
		local n=0
		local e=0
		while n ~= nil do
			n,e = bytes_remaining:find(nl)
			logf(LG_DBG,lgid, "Found n=%d, e=%d", n or "-1", e or -1)
			if n then
				command = command .. base64.decode( bytes_remaining:sub(1,n-1) )
				logf(LG_DBG,lgid, "command = \"%s\"", command)
				bytes_remaining = bytes_remaining:sub(e+1)
				logf(LG_DBG,lgid, "bytes_remaining = \"%s\"", bytes_remaining)
			end
		end
	else
		command = bytes
		bytes_remaining = ""
	end
	
	logf(LG_DBG,lgid,"Received: %s", command)
	for i, c in ipairs( { command:byte(1, #command) } ) do
		local current_answer = handle_byte(cit, c)
		if current_answer and #current_answer>0 then
			logf( LG_DBG, lgid, "Current answer '%s'", current_answer )
			if encryption == "base64" then
				current_answer = base64.encode(current_answer .. nl)
			end
			answer = answer .. current_answer .. nl
		end
	end

	push_cit_idle_msg( )
	
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
			local s = expand_message_tag() .. answer
			logf( LG_DBG, lgid, "Sending back (UDP) '%s'", s )
			if net.sendto( cit.sock_udp, s, destaddr, destport ) ~= #s then
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
			local s = expand_message_tag() .. answer
			logf( LG_DBG, lgid, "Sending back (TCP) '%s'", s )
			if net.send(fd, s) ~= #s then
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

	set_keepalive( sock )

	local client = client_new(cit, sock, addr, port)

end


--
-- Draw idle message
--

local function draw_idle_msg(cit)
	logf(LG_DBG,lgid, "draw_idle_msg()")

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

	logf(LG_DBG,lgid,"draw_error_msg()")

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

	push_cit_idle_msg( )
end


-- Enable TCP keep-alive option.
-- Watch out: linux sockets won't inherit this option!!!
-- this is required for two reasons:
--   1. prevent routers of closing inactive connection
--   2. ability to check the health of the connection without the
--      need to sent an application level packet (especially 
--      important when using unreliable connection, eg with a modem)
local function enable_keepalive_config( net, sock )
	if config:get("/network/tcp_keepalive/use_keepalive") == "true" then

--TODO: use setsockopt instead of systemwide proc settings
--TCP_KEEPCNT
--    The maximum number of keepalive probes TCP should send before dropping the connection. This option should not be used in code intended to be portable. 
--TCP_KEEPIDLE
--    The time (in seconds) the connection needs to remain idle before TCP starts sending keepalive probes, if the socket option SO_KEEPALIVE has been set on this socket. This option should not be used in code intended to be portable. 
--TCP_KEEPINTVL
--    The time (in seconds) between individual keepalive probes. This option should not be used in code intended to be portable. 

		-- workaround for missing SOL_TCP defintions:
		os.execute( "echo " .. config:get("/network/tcp_keepalive/time") .. " > /proc/sys/net/ipv4/tcp_keepalive_time" )
		os.execute( "echo " .. config:get("/network/tcp_keepalive/intvl") .. "  > /proc/sys/net/ipv4/tcp_keepalive_intvl" )
		os.execute( "echo " .. config:get("/network/tcp_keepalive/probes") .. "  > /proc/sys/net/ipv4/tcp_keepalive_probes" )

		set_keepalive( sock )
	end
end


local function connect_to_server( cit )

	-- if connected, nothing to do
	if cit.client_connected then
		return true
	end

	logf(LG_DBG,lgid,"connect_to_server()")

	-- Try to connect
	
	local host = config:get("/cit/resolved_remote_ip")
	local port = config:get("/cit/tcp_port")
	
	-- resolve hostname and try all addresses
	local addrs, errstr = net.gethostbyname(host)
	if addrs == nil then
		logf(LG_WRN, lgid, "Could not resolve host %s: %s", host, errstr)
		return false
	end

	local err = ""
	for i,addr in pairs(addrs) do
		logf(LG_DBG,lgid, "Trying to connect to %s (%s)", addr, host)
		local result = 0
		local sock = net.socket("tcp")
		
		flag = 1;

		result, err = net.connect(sock, addr, port)
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
			enable_keepalive_config( net, sock )
			client_new(cit, sock, addr, port)
			return true
		end
		
		net.close(sock)
	end
	
	logf(LG_WRN, lgid, "Could not connect to %s.%s: %s", host, port, err)
	return false
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
	local remote_ip = config:get("/cit/resolved_remote_ip")
	
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
			
			--enable_keepalive_config( net, sock )
			
			--net.setsockopt( sock , "TCP_NODELAY", 1 )
			
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


-- event function to decouple sending something to clients
local function on_send_to_clients( event, cit )
	-- defensive programming:
	if event.data then
		cit:send_to_clients( event.data )
	end
end


local function on_sendevent_for_msg(event, cit)
	-- originated from:
	-- evq:push("cit_sendevent_for_msg", {one_time_timeout_id=one_time_timeout_id, msg_timeout = msg_timeout }, delay)
	if one_time_timeout_id ~= nil and event.data.one_time_timeout_id == one_time_timeout_id then
		logf(LG_DBG,lgid,"pushing %s at %d seconds", one_time_timeout_msg, event.data.msg_timeout)
		evq:push(event.data.msg_type, event.data, event.data.msg_timeout)
		cit:send_to_clients( "TT" .. one_time_timeout_tag )
		one_time_timeout_tag = nil
		if event.data.msg_type == "cit_error_msg" then
			message_received = false
		end
	end
end


-- react to "draw_idle_msg" event
-- when force==true: reset idle timeout
local function on_draw_idle_msg(event, cit) 
	if not keyboard or not keyboard:is_active() then
		
		logf(LG_DBG,lgid,"on_draw_idle_msg" )
		if event.data and event.data.force==true then
			logf(LG_DBG,lgid,"force display of idle message, reset idle timeout")
			-- disable timeout:
			t_idle_msg = 0
		end
		logf(LG_DBG,lgid,"on_draw_idle_msg: one_time_timeout_id==%d", one_time_timeout_id or -1)
		if one_time_timeout_msg ==  nil or 
				event.data and  event.data.one_time_timeout_id == one_time_timeout_id then
				
			if t_idle_msg - 1 < sys.hirestime() then
				cit:draw_idle_msg() 
			end
		else
			logf(LG_DBG,lgid,"on_draw_idle_msg: skipping one_time_timeout_id: %d =?= %d", event.data and event.data.one_time_timeout_id or -1, one_time_timeout_id or -1)
		end
	end
end


local function on_draw_error_msg(event, cit)
	if event.data and event.data.one_time_timeout_id then
		logf(LG_DBG,lgid,"on_draw_error_msg(event.data.one_timeo_timeout_time = %d) one_time_timeout_id=%d", event.data.one_time_timeout_id, one_time_timeout_id or -1)
	end
	if		one_time_timeout_msg ~= "cit_error_msg" or 
			event.data and event.data.one_time_timeout_id == one_time_timeout_id then
		cit:draw_error_msg() 
	end
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

		logf(LG_DBG, lgid, "on_barcode()")

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
					display:clear()
					t_idle_msg = 0
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
					success = handle_barcode_programming(cit, barcode, prefix)
					set_programming_mode_timeout()
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
		push_cit_idle_msg( )
	end

end


--
-- Handle scan data (mifare only)
--

local function on_scan_rf(event, cit)

	logf(LG_DBG, lgid, "on_scan_rf()")

	if event.data.error then

		display:clear()
		display:format_text(event.data.error or "Unspecified error", 1, 1, "c", "m", 18)
		push_cit_idle_msg( )

	else
	
		local data = ""
		if config:get("/dev/mifare/cardnum_format") == "hexadecimal" then
			data = event.data.cardnumstr
		else
			data = event.data.cardnum
		end

		if config:get("/dev/mifare/send_cardnum_only") == "false" then
			local dataformat = config:get("/dev/mifare/sector_data_format")
			local sep = sector_data_seperators[config:get("/dev/mifare/sector_data_seperator")]
			for i,read in pairs(event.data.read) do
				if dataformat == "base 64" then
					data = data .. sep .. base64.encode(read.data)
				elseif dataformat == "hex escapes" then
					data = data .. sep .. binstr_to_escapes( read.data, 32, 256, "" )
				elseif dataformat == "binary" then
					data = data .. sep .. read.data
				elseif dataformat == "hex" then
					data = data .. sep .. read.data:gsub(".", 
						function (c) return string.format("%02x", c:byte()) end)
				else
					logf(LG_WRN,lgid,"Unrecognized sectordata format: '%s'",
										 data_format)
				end
			end
		end

		cit:send_to_clients( "MF" .. data )

		-- and show the error screen when timeout has passed without command:
		message_received = false
		local timeout = tonumber(config:get("/cit/messages/error/timeout"))
		evq:push("cit_error_msg", nil, timeout)
		
	end
	
end

-- handle gpio event
local function on_gpio(event, cit)

	if event.data.IN1 then
		local level = string.char(event.data.IN1+0x30)
		logf(LG_DBG, lgid, "on_gpio(): IN1=%s", level)
		cit:send_to_clients( config:get("/dev/gpio/prefix") .. "0" .. level )
	end

	if event.data.IN2 then
		local level = string.char(event.data.IN2+0x30)
		logf(LG_DBG, lgid, "on_gpio(): IN2=%s", level)
		cit:send_to_clients( config:get("/dev/gpio/prefix") .. "1" .. level )
	end

end


-- handle touch16 event
local function on_touch16(event, cit)

	logf(LG_DBG, lgid, "on_touch16(data.type='%s')", (event.data.type or "nil"))

	if event.data.type == "key" then
		cit:send_to_clients( config:get("/dev/touch16/prefix") .. event.data.key .. (event.data.tag or ""))
	elseif event.data.type == "activated" then
	elseif event.data.type == "deactivated" then
		if event.data.cause and event.data.cause == "timeout" then
			cit:send_to_clients( config:get("/dev/touch16/prefix") .. "T" )
		else
			cit:send_to_clients( config:get("/dev/touch16/prefix") .. "Q" )
		end
		
		push_cit_idle_msg( config:get("/cit/messages/error/timeout") )

	end

end

local function on_display_clear( event, cit )
	-- break a possible running one-time-timeout 
	if one_time_timeout_id ~= nil then
		logf(LG_DBG,lgid,"Killing a one-time-timeout due to display_clear event")
		if one_time_timeout_tag ~= nil then
			-- no timeout send yet:
			cit:send_to_clients( "TQ" .. one_time_timeout_tag )
		end
		one_time_timeout_id = nil
		one_time_timeout_msg = nil
		one_time_timeout_tag = nil
	end
end

local resolved_ip_hostname = nil
local resolved_ip = nil
local resolved_ip_time = nil
local function on_get_resolved_remote_ip(node,cit)

	local hostname = config:get("/cit/remote_ip")

	-- invalidate cache when it more than 1 day old
	if resolved_ip_time and sys.hirestime() - resolved_ip_time > 60*60*24 then
		resolved_ip = nil
		resolved_ip_time = nil
		logf(LG_DBG,lgid,"Invalidating resolved ip cache because it was more than 1 day ago resolved")
	end
	
	-- check if it is cached:
	if resolved_ip_hostname == hostname and resolved_ip ~= nil then
		logf(LG_DBG,lgid,"Using cached resolved ip %s", resolved_ip or "nil" )
		return resolved_ip
	end

	-- just use it when it is formatted as a valid ip
	local n1,n2,n3,n4 = hostname:match("^(%d%d?%d?).(%d%d?%d?).(%d%d?%d?).(%d%d?%d?)%s*$")
	if n1 and n2 and n3 and n4 and 
			tonumber(n1)<=255 and tonumber(n2)<=255 and 
			tonumber(n3)<=255 and tonumber(n4)<=255 then
		resolved_ip_hostname = hostname
		resolved_ip = hostname
		resolved_ip_time = sys.hirestime()
		logf(LG_DBG,lgid,"Using ip literal %s", resolved_ip )
		return resolved_ip
	end
	
	-- otherwise start resolving:
	-- start gethostbyname in the background and fill in "/cit/resolved_remote_ip"
	-- invalidate the old value:
	resolved_ip_hostname = hostname
	resolved_ip = nil
	
	logf(LG_DBG,lgid,"Starting 'gethostbyname' for %s", hostname)
	runbg("killall /cit200/gethostbyname > /dev/null 2>&1; /cit200/gethostbyname " .. hostname,
		function(rv,cit)
			if rv == 0 then
				-- ok
				logf(LG_INF,lgid,"Using server ip %s (=%s)",
						resolved_ip or "nil", resolved_ip_hostname or "nil");
				resolved_ip_time = sys.hirestime()
			else
				-- failed
				logf(LG_WRN,lgid,"Failed resolv ip for hostname '%s'", hostname or "nil");
			end
		end,
		function(data,cit)
			local ip = data:match("^(%d+%.%d+%.%d+%.%d+)")
			logf(LG_DBG,lgid,"found ip %s for %s (first of %s)", ip or "nil", hostname, data or "nil")
			resolved_ip = ip
		end,
		cit)
	
	-- just wait 1 second in case it is resolved very quick (but most times it should be cached):
	for i=1,10 do
		if resolved_ip then
			return resolved_ip
		end
		sys.sleep(0.1)
	end
	return "0.0.0.0"
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

	-- Register to input events
	
	evq:register("scanner", on_barcode, cit)
	evq:register("scan_rf", on_scan_rf, cit)
	evq:register("gpio", on_gpio, cit)
	evq:register("touch16", on_touch16, cit)

	-- Event handlers for showing idle and error message
	
	evq:register("cit_idle_msg", on_draw_idle_msg, cit)
	evq:register("cit_error_msg", on_draw_error_msg, cit)
	evq:register("cit_sendevent_for_msg", on_sendevent_for_msg, cit)
	
	evq:register("cit_send_to_clients", on_send_to_clients, cit)
	
	evq:register("display_clear", on_display_clear, cit )

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

	push_cit_idle_msg( )

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

	evq:unregister("touch16", on_touch16, cit)
	evq:unregister("gpio", on_gpio, cit)
	evq:unregister("scan_rf", on_scan_rf, cit)
	evq:unregister("scanner", on_barcode, cit)
	evq:unregister("cit_idle_msg", on_draw_idle_msg, cit)
	evq:unregister("cit_error_msg", on_draw_error_msg, cit)
	evq:unregister("cit_sendevent_for_msg", on_sendevent_for_msg, cit)
	evq:unregister("cit_send_to_clients", on_send_to_clients, cit)
	evq:unregister("display_clear", on_display_clear, cit )

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
	logf(LG_DBG,lgid,"on_change_ftp_encrypted()")
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
		logf(LG_DBG,lgid,"on_change_ftp_username()")
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
	logf(LG_DBG,lgid,"on_change_ftp_auth_enable()")
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
	os_execute( "while killall vsftpd; do sleep 0.1; done; vsftpd &" )
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

		-- methods

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
	-- /mnt/mmc/          legacy, the fontfile is burned on the sd-card before it was inserted into the nquire
	-- /mnt/mmc/fonts    this is mounted to /home/ftp, font upload by ftp is possible (overrules font file in /mnt/mmc)

	local files = sys.readdir("/mnt/mmc")
	if files then
		for _, file in ipairs(files) do
			local tmp = file:match(".+\.ttf$")
			if tmp then
				font = "/mnt/mmc/" .. tmp
				break
			end
		end
	end
	
	local files = sys.readdir("/home/ftp/fonts")
	if files then
		for _, file in ipairs(files) do
			local tmp = file:match(".+\.ttf$")
			if tmp then
				font = "/home/ftp/fonts/" .. tmp
				break
			end
		end
	end
	
	-- Get codepage
	
	cit.codepage = config:get("/cit/codepage") 
	config:add_watch("/cit/codepage", "set", 
		function() 
			cit.codepage = config:get("/cit/codepage") 
		end, cit)
	
	-- Get resolv remote_ip or convert remote_ip to address
	config:add_watch("/cit/resolved_remote_ip", "get", on_get_resolved_remote_ip, cit)

	display:set_font( font, fontsize_small )
	
	-- Start connect timer for client mode

	evq:register("connect_timer", on_connect_timer, cit)
	evq:push("connect_timer", cit, 3.0)

	evq:register("programming_mode_timeout", on_programming_mode_timeout, cit)
	
	-- configure ftp in case the cit.conf is overwritten during startup (/udisk/cit.conf)
	on_change_ftp_auth()
	
	config:add_watch("/dev/auth", "set", on_change_ftp_auth)

	logf(LG_INF, lgid, "Using font file %q", font)
	
	return cit

end

-- vi: ft=lua ts=3 sw=3

