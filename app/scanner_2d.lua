--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_2d", package.seeall)


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
	if busy then 
		logf(LG_DBG, "scanner", "multi threading bug: Busy" )
		return
	end
	
	if event.data.fd ~= scanner.fd then
		return
	end
	busy=true;

	local data = sys.read(scanner.fd, 5003)

	if data and data ~= "" then
		logf(LG_DBG, "scanner", "Recieved scanner data: '%s'", data)
		scanner.scanbuf = data

		-- TODO: fetch the longest match
		local t1, t2 = match_max(scanner.scanbuf)
		if t1 then
			local barcode = t1
			scanner.scanbuf = "" -- t2 or ""
		
			logf(LG_DBG, "scanner", "Barcode from data='%s'", barcode)

			-- Barcode is complete. Fixup the barcode type prefix to be the
			-- compatible format

			local prefix_in, barcode = barcode:match("(.)(.+)")
			local prefix_out = nil

			for _, i in ipairs(prefixes) do
				if prefix_in == i.prefix_2d then
					logf(LG_DBG, "scanner", "Scanned %q barcode type", i.name)
					prefix_out = i.prefix_out
					break
				end
			end

			if not prefix_out then
				logf(LG_DBG, "scanner", "Scanned unknown barcode type")
				prefix_out = "?"
			end

			evq:push("scanner", { result = "ok", barcode = barcode, prefix=prefix_out })
		else
			logf(LG_WRN, "scanner", "Scanned barcode data is not processed because it is not terminated. Possible cause: message too long >= 5003 chars")
			beeper:play( "o3g16c16" )
		end
		if t2 then
			logf(LG_WRN, "scanner", "More data is scanned than is processed. This data is ignored:")
			logf(LG_WRN, "scanner", "'%s'", t2)
		end
		
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
		
	logf(LG_WRN, "scanner", "Scanner does not reply to ping")
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
	logf(LG_DMP, "scanner", "< " .. data)
	return data
end


--
-- Wait for ACK, recoriding all data read until the ACK
--

local function wait_ack(scanner, time)
	local buf = ""
	local tstart = sys.hirestime()
	repeat
		local data = sys.read(scanner.fd, 1024)
		if data and #data > 0 then
			buf = buf .. data
			if data:find("\006") then
				logf(LG_DMP, "scanner", "< ACK")
				if #buf > 1 then
					logf(LG_DMP, "scanner", "< " .. buf)
				end
				return buf
			end
			sys.sleep(0.1)
		else
			buf = buf .. data
		end
	until sys.hirestime() - tstart > 2.0
	logf(LG_WRN, "scanner", "Timeout waiting for ack")
	return false
end


--
-- Send cmd to scanner and read response
--

local function cmd(scanner, ...)

	-- Create and send out command

	for _, cmd in ipairs({...}) do
		local buf = "!NLS" .. cmd .. ";"
		scanner:flush()
		sys.write(scanner.fd, buf)
		logf(LG_DMP, "scanner", "> %s", buf)
	end

	return scanner:wait_ack()

end


--
-- Open and configure scanner device
--

local function open(scanner)

	scanner:close()
			
	scanner.device = "/dev/scanner"

	logf(LG_DBG, "scanner", "Opening scanner on device %s", scanner.device)
	local fd, err = sys.open(scanner.device, "rw")
	if not fd then
		logf(LG_WRN, "scanner", "Could not open scanner device %s: %s", scanner.device, err)
		return
	end

	scanner.fd = fd
	scanner.scanbuf = ""

	sys.set_noncanonical(fd, true)

	evq:fd_add(fd)
	evq:register("fd", on_fd_scanner, scanner)

	-- Basic scanner configuration

	logf(LG_INF, "scanner", "Configuring scanner")
	local ok = scanner:ping()

	if not ok then
		logf(LG_WRN, "scanner", "Scanner does not ping, can not configure")
		return
	end

	scanner:cmd(
		SCANNER_CMD_SET_DEFAULTS,
		SCANNER_CMD_TERMINATOR_CR,
		SCANNER_CMD_TERMINATOR_ENABLE,
		SCANNER_CMD_AUTO_SCAN,
		SCANNER_CMD_CODE_ID_ON
	)
	scanner:flush()
	
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
		logf(LG_WRN, "scanner", "Could not acquire scanner version information")
	end

	-- Disable 2D codes if configured
	
	local barcodes = config:get("/dev/scanner/barcodes")
	
	if barcodes == "1D only" then
		scanner:cmd(SCANNER_CMD_2D_DISABLE)
	else
		scanner:cmd(SCANNER_CMD_2D_ENABLE)
	end
	scanner:flush()

	-- Configure code prefixes

	local cmd_list = {}
	for _,i in ipairs(prefixes) do
		if i.cmd then
			table.insert(cmd_list, i.cmd .. '="' .. i.prefix_2d .. '"')
		end
	end
	scanner:cmd(unpack(cmd_list))
	scanner:flush()

	-- Configure illumination mode: Blinking,Always ON,Always OFF
	local illumination_led_mode = config:get("/dev/scanner/illumination_led")
	if illumination_led_mode == "Always ON" then
		scanner:cmd( SCANNER_CMD_ILLUMINATION_ON )
	elseif illumination_led_mode == "Always OFF" then
		scanner:cmd( SCANNER_CMD_ILLUMINATION_OFF )
	else
		scanner:cmd( SCANNER_CMD_ILLUMINATION_WINK )
	end
	scanner:flush()

	-- Configure aiming mode: Blinking,Always ON,Sensor mode
	local aiming_led_mode = config:get("/dev/scanner/aiming_led")
	if aiming_led_mode == "Always ON" then
		scanner:cmd( SCANNER_CMD_AIM_ON )
	elseif aiming_led_mode == "Sensor mode" then
		scanner:cmd( SCANNER_CMD_AIM_SMART )
	else
		scanner:cmd( SCANNER_CMD_AIM_WINK )
	end
	scanner:flush()

	-- Configure sensitivity: Low,Medium,High
	local reading_sensitivity = config:get("/dev/scanner/reading_sensitivity")
	if reading_sensitivity == "Low" then
	   -- Low sensitivity moet geprogrammeerd staan op 20:
		scanner:cmd( "0312040", "0000020", "0000000", "0000160" )
		scanner:cmd( SCANNER_CMD_SENSITIVITY_LOW )
	elseif reading_sensitivity == "High" then
		scanner:cmd( SCANNER_CMD_SENSITIVITY_HIGH )
	else
		scanner:cmd( SCANNER_CMD_SENSITIVITY_NORMAL )
	end
	scanner:flush()

	logf(LG_DBG, "scanner", "Successfully detected and configured scanner, enabled %s" % barcodes)
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
	logf(LG_DBG, "scanner", "Enabling scanner")
	if scanner.fd then
		sys.write(scanner.fd, "\0272")
		scanner:wait_ack()
	end
end


--
-- Disable scanning
--

local function disable(scanner)
	logf(LG_DBG, "scanner", "Disabling scanner")
	if scanner.fd then
		sys.write(scanner.fd, "\0270")
		scanner:wait_ack()
	end
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

		-- methods
		open = open,
		close = close,
		ping = ping,
		flush = flush,
		wait_ack = wait_ack,
		cmd = cmd,
		enable = enable,
		disable = disable,
	}

	config:add_watch("/dev/scanner",    "set", function() scanner:open() end, scanner)

	scanner:open()

	return scanner

end

-- vi: ft=lua ts=3 sw=3
	
