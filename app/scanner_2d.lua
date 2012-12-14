--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_2d", package.seeall)

local lgid = "scanner"

--  scanner programminc codes as defined in "HR200 User Guide 090720"
local SCANNER_CMD_SET_DEFAULTS      = "0001000"
local SCANNER_CMD_TERMINATOR_CR     = "0310000=0x0D00"
local SCANNER_CMD_TERMINATOR_ENABLE = "0309010"
local SCANNER_CMD_AUTO_SCAN         = "0302010"
local SCANNER_CMD_CODE_ID_ON        = "0307010"
local SCANNER_CMD_1D_DISABLE        = "0001030"
local SCANNER_CMD_1D_ENABLE         = "0001040"
local SCANNER_CMD_2D_DISABLE        = "0001050"
local SCANNER_CMD_2D_ENABLE         = "0001060"
local SCANNER_CMD_GET_INFO          = "0003000"

local SCANNER_CMD_ILLUMINATION_WINK = "0200000"
local SCANNER_CMD_ILLUMINATION_ON   = "0200010"
local SCANNER_CMD_ILLUMINATION_OFF  = "0200020"
	
local SCANNER_CMD_AIM_WINK          = "0201000"
local SCANNER_CMD_AIM_ON            = "0201010"
local SCANNER_CMD_AIM_SMART         = "0201030"

local SCANNER_CMD_SENSITIVITY_LOW   = "0312000"
local SCANNER_CMD_SENSITIVITY_NORMAL= "0312010"
local SCANNER_CMD_SENSITIVITY_HIGH  = "0312020"

local SCANNER_CMD_CONSTRAIN_MULTI_ON   = "0313010"
local SCANNER_CMD_CONSTRAIN_MULTI_SEMI = "0313030"
local SCANNER_CMD_CONSTRAIN_MULTI_ALL  = "0313020"
--
-- Scanner fd callback, used for both internal and external scanner
--

local function match_max( s )
	
	local t1, sep, t2 = s:match("(.-)([\r\n])(.*)")

	if t1 and t2 then
		local t1_1
		t1_1, t2 = match_max( t2 )
		if t1_1 then
			t1 = t1 .. sep .. t1_1
		end
	end

	return t1, t2
end

local busy=false;
local function on_fd_scanner(event, scanner)

	if event.data.fd ~= scanner.fd then
		return
	end

	if busy then 
		logf(LG_DBG, lgid, "multi threading bug: Busy" )
		return
	end
	busy=true;

	-- tryout for faster beep (this is followed by an error beep when the barcode is invalid)
	beeper:beep_ok()
	
	logf(LG_DBG, lgid, "Start retrieving data from scanner.")
	local t_start = sys.hirestime()
	local err_count = 0;
	local data = sys.read(scanner.fd, 5003)
	while data and #data==0 and t_start+2>sys.hirestime() do
		err_count = err_count+1
		data = sys.read(scanner.fd, 5003)
	end
	logf(LG_DBG, lgid, "#Futile reads=" .. err_count)

	if data and data ~= "" then
		scanner.scanbuf = data

		local t1, t2 = match_max(scanner.scanbuf)
		if t1 then
			local barcode = t1
			scanner.scanbuf = "" -- t2 or ""
		
			logf(LG_DBG, lgid, "Barcode: '%s'", barcode)

			-- Barcode is complete. Fixup the barcode type prefix to be the
			-- compatible format

			local prefix_in, barcode = barcode:match("(.)(.+)")
			local prefix_out = nil

			for _, i in ipairs(prefixes) do
				if prefix_in == i.prefix_2d then
					logf(LG_DBG, lgid, "Barcode type = %q", i.name)
					prefix_out = i.prefix_out
					break
				end
			end

			if not prefix_out then
				logf(LG_WRN, lgid, "Barcode type = Unknown")
				prefix_out = "?"
			end

			evq:push("scanner", { result = "ok", barcode = barcode, prefix=prefix_out })
		else
			logf(LG_WRN, lgid, 
					"Scanned barcode data is not processed \n" ..
					"because it is not terminated.\n" ..
					"Possible cause: message too long (>= 5003 chars)")
			beeper:beep_error()
		end
		if t2 then
			logf(LG_WRN, lgid, "More data is scanned than is processed.\n" ..
											"The following data is ignored:")
			logf(LG_WRN, lgid, "'%s'", t2)
		end
	else
		logf(LG_WRN, lgid, "Scanner data-timeout.")
		beeper:beep_error()
	end
	busy=false
end



--
-- Send ping (?) and wait for reply (!)
--

local function ping(scanner)
	
	sys.write(scanner.fd, "?")

	local tstart = sys.hirestime()
	repeat
		local data = sys.read(scanner.fd, 1)
		if data == "!" then
			return true
		end
	until sys.hirestime() - tstart > 1.0
		
	logf(LG_WRN, lgid, "Scanner does not reply to ping")
	return false
end


--
-- Empty RX buffer
--

local function flush(scanner)
	local data = ""
	repeat
		local buf = sys.read(scanner.fd, 1024)
		if buf and #buf>0 then
			data = data .. buf
			sys.sleep(0.1)
		end
	until not buf or #buf == 0
	logf(LG_DMP, lgid, "< " .. data)
	return data
end


--
-- Wait for ACK, recording all data read until the ACK
--

local function wait_ack(scanner, time)
	local buf = ""
	local tstart = sys.hirestime()
	repeat
		local data = sys.read(scanner.fd, 5003)
		if data and #data > 0 then
			buf = buf .. data
			if data:find("\006") then
				logf(LG_DMP, lgid, "ACK")
				if #buf > 1 then
					logf(LG_DMP, lgid, "< " .. buf)
				end
				return buf
			end
			sys.sleep(0.1)
		end
	until sys.hirestime() - tstart > 4.0
	logf(LG_WRN, lgid, "Timeout waiting for ACK")
	return nil
end

local function cmd_noack(scanner, command)

	-- Create and send out command

	local buf = "!NLS" .. command .. ";"
	sys.write(scanner.fd, buf)
	logf(LG_DMP, lgid, "> %s", buf)

end


--
-- Send cmd to scanner and read response
--

local function cmd(scanner, ...)

	-- Create and send out command

	scanner:flush()

	for _, cmd in ipairs({...}) do
		cmd_noack( scanner, cmd )
	end

	return scanner:wait_ack()

end


function get_illumination_mode_code( mode )
	if mode == "Always ON" then
		return SCANNER_CMD_ILLUMINATION_ON;
	elseif mode == "Always OFF" then
		return SCANNER_CMD_ILLUMINATION_OFF;
	else
		return SCANNER_CMD_ILLUMINATION_WINK;
	end
end

-- enable/disable barcodes.
local function barcode_on_off( scanner, name, on_off, wait_for_ack )
	local programmed=false
	logf(LG_DMP, lgid, "barcode_on_off(" .. name .. "," .. on_off .. ")")
	for _,code in ipairs( enable_disable_HR200 ) do
		--logf(LG_DMP, lgid, "code=" .. code.name)
		if code.name == name then
			if on_off == "on" and code.on then
				logf(LG_DBG, lgid, "enabling barcode " .. name)
				scanner:cmd_noack(code.on)
				programmed=true
			elseif on_off == "off" and code.off then
				logf(LG_DBG, lgid, "disabling barcode " .. name)
				scanner:cmd_noack(code.off)
				programmed=true
			end
		end
	end
	if wait_for_ack and programmed then
		if not scanner:wait_ack() then
			logf( LG_WRN, lgid, "Error disabling/enabling barcode " .. name .. "." )
		end
	end
end

--
-- Open and configure scanner device
--

local function open(scanner)

	scanner:close()

	scanner.device = "/dev/scanner"

	logf(LG_DBG, lgid, "Opening scanner on device %s", scanner.device)
	local fd, err = sys.open(scanner.device, "rw")
	if not fd then
		logf(LG_WRN, lgid, "Could not open scanner device %s: %s", scanner.device, err)
		return
	end

	scanner.fd = fd
	scanner.scanbuf = ""

	sys.set_noncanonical(fd, true)

	evq:fd_add(fd)
	evq:register("fd", on_fd_scanner, scanner)

	-- Basic scanner configuration

	logf(LG_INF, lgid, "Configuring scanner")
	local ok = scanner:ping()

	local errors = false

	if not ok then
		logf(LG_WRN, lgid, "Scanner does not ping, can not configure")
		return
	end

	if not scanner:cmd(
				SCANNER_CMD_SET_DEFAULTS,
				SCANNER_CMD_TERMINATOR_CR,
				SCANNER_CMD_TERMINATOR_ENABLE,
				SCANNER_CMD_AUTO_SCAN,
				SCANNER_CMD_CODE_ID_ON
			) then
		logf( LG_WRN, lgid, "Error setting scanner defaults." )
		errors = true
	end
	
	-- Get version info. We need to match some stuff in a blob of free formatted text to 
	-- get the proper info
	
	local data = scanner:cmd(SCANNER_CMD_GET_INFO)
	if data then
		local version = ""
		local tmp = data:match("Device ID: %s+(%S+)")
		if tmp then version = version .. tmp .. " " end
		local tmp = data:match("uIMG Ver:%s+(%S+)")
		if tmp then version = version .. "/ app:" .. tmp .. " " end
		local tmp = data:match("Firmware Ver:%s+(%S+)")
		if tmp then version = version .. "/ fw:" .. tmp .. " " end
		config:lookup("/dev/scanner/version"):setraw(version)
	else
		logf(LG_WRN, lgid, "Could not acquire scanner version information")
		errors = true
	end

	-- prohibit multi reading:
	if config:get("/dev/scanner/multi_reading_constraint") == "On" then
		scanner:cmd(SCANNER_CMD_CONSTRAIN_MULTI_ON,
						SCANNER_CMD_CONSTRAIN_MULTI_ALL)
	elseif config:get("/dev/scanner/multi_reading_constraint") == "Semi" then
		scanner:cmd(SCANNER_CMD_CONSTRAIN_MULTI_ON,
						SCANNER_CMD_CONSTRAIN_MULTI_SEMI)
	end

	-- Disable 2D codes if configured
	
	local barcodes = config:get("/dev/scanner/barcodes")
	
	if barcodes == "1D only" then
		scanner:cmd_noack(SCANNER_CMD_2D_DISABLE)
	else
		scanner:cmd_noack(SCANNER_CMD_2D_ENABLE)
	end

	-- enable/disable barcodes when this is configured
	for _,code in ipairs(enable_disable_HR200) do
		local id = code.name
		local node = config:lookup("/dev/scanner/enable-disable/" .. id )
		if node and node:get()=="false" then
			scanner:barcode_on_off( id, "off" )
		elseif node and node:get()=="true" then
			if not is_2d_code(id) or config:get("/dev/scanner/barcodes") == "1D and 2D" then
				scanner:barcode_on_off( id, "on" )
			end
		end
	end
	if not scanner:wait_ack() then
		logf( LG_WRN, lgid, "Error disabling/enabling barcodes." )
		errors = true
	end

	-- Configure code prefixes

	for _,i in ipairs(prefixes) do
		if i.cmd_HR200 then
			scanner:cmd_noack( i.cmd_HR200 .. '="' .. i.prefix_2d .. '"' )
		end
	end

	-- Configure illumination mode: Blinking,Always ON,Always OFF
	scanner:cmd_noack( get_illumination_mode_code( config:get("/dev/scanner/illumination_led") ) )

	-- Configure aiming mode: Blinking,Always ON,Sensor mode
	local aiming_led_mode = config:get("/dev/scanner/aiming_led")
	if aiming_led_mode == "Always ON" then
		scanner:cmd_noack( SCANNER_CMD_AIM_ON )
	elseif aiming_led_mode == "Sensor mode" then
		scanner:cmd_noack( SCANNER_CMD_AIM_SMART )
	else
		scanner:cmd_noack( SCANNER_CMD_AIM_WINK )
	end

	-- Configure sensitivity: Low,Medium,High
	local reading_sensitivity = config:get("/dev/scanner/reading_sensitivity")
	if reading_sensitivity == "Low" then
	   -- Low sensitivity moet geprogrammeerd staan op 20:
		scanner:cmd_noack( "0312040", "0000020", "0000000", "0000160" )
		scanner:cmd_noack( SCANNER_CMD_SENSITIVITY_LOW )
	elseif reading_sensitivity == "High" then
		scanner:cmd_noack( SCANNER_CMD_SENSITIVITY_HIGH )
	else
		scanner:cmd_noack( SCANNER_CMD_SENSITIVITY_NORMAL )
	end
	if not scanner:wait_ack() then
		logf( LG_WRN, lgid, "Error setting illumination, aiming mode or sensitivity." )
		errors = true
	end
	scanner:flush()

	if errors then
		logf(LG_WRN, lgid, "Finnished configuring scanner, but there were errors.")
		led:set("yellow","blink")
	else
		logf(LG_DBG, lgid, "Successfully detected and configured scanner, enabled %s" % barcodes)
		led:set("yellow","on")
	end
end


--
-- Close and restore tty settings
--

local function close(scanner)
	scanner:disable()
	if scanner.fd then
		evq:fd_del(scanner.fd)
		evq:unregister("fd", on_fd_scanner, scanner)
		sys.set_noncanonical(scanner.fd, false)
		sys.close(scanner.fd)
		scanner.fd = nil
	end
end


-- 
-- Enable scanning
--

local function enable(scanner)
	logf(LG_DBG, lgid, "Enabling scanner")
	if scanner.fd then
		sys.write(scanner.fd, "\0272")
		scanner:wait_ack()
		scanner:cmd( get_illumination_mode_code(config:get("/dev/scanner/illumination_led")) )
		led:set("yellow","on")
	end
end


--
-- Disable scanning
--

local function disable(scanner)
	logf(LG_DBG, lgid, "Disabling scanner")
	if scanner.fd then
		sys.write(scanner.fd, "\0270")
		scanner:wait_ack()
		scanner:cmd( get_illumination_mode_code("Always OFF") )
		led:set("yellow","off")
	end
end

-- watch out: Scanner_1d:is_available() depends on this
local has_2d_hw = nil
function is_available()
	if has_2d_hw == nil then
		local fd = io.open("/dev/scanner")
		if fd then
			fd:close()
			has_2d_hw = true
		else
			has_2d_hw = false
		end
	end
	return has_2d_hw
end


--
-- Constructor
--
-- This function creates two devices, one for the internal USB scanner, one for
-- an external scanner in USB HID keyboard emulation mode.
--

function new()

	local scanner = {

		-- data
		fd = nil,
		device = nil,
		scanbuf = "",
		type = "2d",
		enable_disable = enable_disable_HR200,

		-- scanner independent methods
		open = open,
		close = close,
		enable = enable,
		disable = disable,

		cmd = cmd,
		flush = flush,
		
		-- other methods:
		cmd_noack = cmd_noack,
		wait_ack = wait_ack,
		ping = ping,
		barcode_on_off = barcode_on_off,
	}

	config:add_watch("/dev/scanner", "set", function() scanner:open() end, scanner)
	evq:register("reinit_scanner", function() scanner:open() end, scanner)
	scanner:open()

	return scanner

end

-- vi: ft=lua ts=3 sw=3
	
