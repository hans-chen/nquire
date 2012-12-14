--
-- Copyright � 2007 All Rights Reserved.
--

module("Scanner_2d", package.seeall)

local lgid = "scanner"

local first_time = true

--  scanner programming codes as defined in "HR200 User Guide 090720"
local SCANNER_CMD_SAVE              = "0000160"
local SCANNER_CMD_SET_DEFAULTS      = "0001000"
local SCANNER_ALLOW_READ_BATCH_CODE = "0001110"
local SCANNER_CMD_SET_STOP_SUFFIX     = "0310000=0xFEFF"
local SCANNER_CMD_ENABLE_STOP_SUFFIX = "0309010"
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

	local dup_scan_timeout = tonumber( config:get("/dev/scanner/prevent_duplicate_scan_timeout") )

	if scanner.last_received_data_time == 0 or 
			scanner.last_received_data_time < sys.hirestime() - 3 then
		logf(LG_DBG,lgid,"Discarding incomplete scan-data because of timeout: '%s'", scanner.scanbuf)
		scanner.scanbuf = ""
		if dup_scan_timeout == nil then
			beeper:beep_ok()
		end
	end	

	logf(LG_DBG, lgid, "Start retrieving data from scanner.")
	local t_start = sys.hirestime()
	local err_count = 0;
	local data = sys.read(scanner.fd, 5003)
	while data and #data==0 and t_start+2>sys.hirestime() do
		err_count = err_count+1
		data = sys.read(scanner.fd, 5003)
	end
	logf(LG_DBG, lgid, "#Futile reads=%d", err_count)

	if data and data ~= "" then

		logf(LG_DMP,lgid,"Scanned: '%s'", data)
		scanner.scanbuf = scanner.scanbuf .. data

		local barcode_counter = 0
		while string.find(scanner.scanbuf,"\254\255") do
			local barcode, rest = scanner.scanbuf:match("(.-)\254\255(.*)")
			scanner.scanbuf = rest or ""
		
			barcode_counter = barcode_counter + 1
			logf(LG_DBG, lgid, "Barcode: '%s'", barcode)
			logf(LG_DMP, lgid, "Rest='%s'", scanner.scanbuf)

			scanner.last_received_data_time = 0

			if dup_scan_timeout == nil or
					scanner.last_barcode ~= barcode or
					sys.hirestime() - scanner.last_barcode_time > dup_scan_timeout then

				scanner.last_barcode = barcode
				scanner.last_barcode_time = sys.hirestime()
				
				if dup_scan_timeout ~= nil or barcode_counter > 1 then
					beeper:beep_ok()
				end
			
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
				logf(LG_DBG,lgid,"Duplicate barcode %s scanned and ignored", barcode)
			end
		end
		
		if #scanner.scanbuf>0 then
			logf(LG_DBG,lgid,"Received incomplete barcode data '%s'. Waiting for more...", scanner.scanbuf)
			scanner.last_received_data_time = sys.hirestime( );
		end

	else
		logf(LG_WRN, lgid, "Scanner data-timeout.")
		beeper:beep_error()
	end
	busy=false
end

local function _write( scanner, txt )
	sys.write(scanner.fd, txt)
	logf( LG_DMP, lgid, "> %s", txt )
end

local function _read( scanner, max )
	local r = sys.read(scanner.fd, max)
	if r and #r>0 then
		logf( LG_DMP, lgid, "< %s", r )
	end
	return r
end

--
-- Send ping (?) and wait for reply (!)
--

local function _ping(scanner)
	
	_write(scanner, "?")
	
	local tstart = sys.hirestime()
	repeat
		local data = _read(scanner, 1)
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
		local buf = _read(scanner,1024)
		if buf and #buf>0 then
			data = data .. buf
			sys.sleep(0.1)
		end
	until not buf or #buf == 0
	return data
end


--
-- Wait for ACK, recording all data read until the ACK
--

local function _wait_ack(scanner)
	logf(LG_DMP, lgid, "wait_ack()")
	local buf = ""
	local tstart = sys.hirestime()
	repeat
		local data = _read(scanner,5003)
		if data and #data > 0 then
			buf = buf .. data
			if data:find("\006") then
				logf(LG_DMP, lgid, "ACK")
				return buf
			end
			sys.sleep(0.1)
		end
	until sys.hirestime() - tstart > 4.0
	logf(LG_WRN, lgid, "Timeout waiting for ACK")
	if #buf > 0 then
		logf(LG_DMP, lgid, "< %s", buf)
	end
	return nil
end

local function _cmd_commit(scanner)
	local errors = false

	-- Send out collected commands and wait for an answer
	-- first all in one batch:
	local bytes = 0
	local answer = ""
	for _,command in ipairs(scanner.commands) do
		if bytes + #command >= 100 then
			logf(LG_DBG,lgid,"sent #bytes=%d", bytes)
			answer = _wait_ack(scanner)
			bytes=0
			errors = errors or not answer or answer:find("\015")
		end
		_write(scanner, command )
		bytes = bytes + #command
	end
	logf(LG_DBG,lgid,"sent #bytes=%d", bytes)
	answer = _wait_ack(scanner)
	errors = errors or not answer or answer:find("\015")
	
	if errors then
		errors = false
		logf(LG_INF,lgid,"Configuring with batch of commands failed. Retry one by one.")
		answer = ""
		for _,command in ipairs(scanner.commands) do
			_write(scanner, command )
			local ack = _wait_ack(scanner)
			if not ack then
				errors = true
			else
				answer = answer .. ack
			end
		end
	end
	scanner.commands = {}
	return errors, answer
end


--
-- Queue command for scanner (send with _cmd_commit)
--

local function _cmd(scanner, ...)
	-- Add command to list
	for _, cmd in ipairs({...}) do
		table.insert( scanner.commands, "!NLS" .. cmd .. ";" )
		logf(LG_DMP,lgid,"Queuing: %s", cmd)
	end
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

-- add enable/disable codes to command list
local function _configure_barcode( scanner, name )
	local value = config:get(string.format("/dev/scanner/enable-disable/%s", name))
	local code = find_by_name( enable_disable_HR200, name )
	local layout = find_by_name( prefixes, name ).layout
	logf(LG_DMP,lgid,"name=%s, value=%s, code.on=%s, code.off=%s, layout=%s", name, (value or "nil"), (code.on or "nil"), (code.off or "nil"), (layout or "nil"))
	
	if code and does_firmware_support(code) then
		if layout ~= "2D" or config:get("/dev/scanner/barcodes") == "1D and 2D"  then
			if value == "true" and code.on then 
				logf(LG_DBG, lgid, "Enabling barcode type %s", name)
				_cmd(scanner,code.on)
			elseif value == "false" and code.off then
				logf(LG_DBG, lgid, "Disabling barcode type %s", name)
				_cmd(scanner,code.off)
			else
				logf(LG_DBG, lgid, "Using factory default %s for barcode type %s", (value=="true" and "enabled" or "disabled"), name)
			end
		else
			logf(LG_DMP,lgid,"Skipping configuration of %s because layout = %s and %s is selected" , name, layout, config:get("/dev/scanner/barcodes") )
		end
	else
		logf(LG_DBG, lgid, "%s not supported by firmware", (name or "nil"))
	end
end

--
-- Open and configure scanner device
--

local function open(scanner)

	if scanner.fd then
		logf(LG_WRN, lgid, "Scanner already opened: not initializing scanner")
		return
	end

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

	-- Basic scanner configuration

	logf(LG_INF, lgid, "Configuring scanner")
	local ok = _ping(scanner)
	if not ok then
		scanner.retry_counter = scanner.retry_counter + 1
		local dt = scanner.retry_counter ^ 2 + 10
		logf(LG_WRN, lgid, "Scanner does not ping, retry in %d seconds", dt)
		evq:push("reinit_scanner", scanner, dt)
		return
	end
	
	local errors = false
	local err = false
	local answer = ""
	
	-- disable scanner
	_write(scanner, "\0270")
	_wait_ack(scanner)
	logf( LG_DBG, lgid, "Scanner disabled during programming...")

	logf( LG_INF, lgid, "Restoring defaults")
	_cmd(scanner, SCANNER_CMD_SET_DEFAULTS )
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error setting scanner defaults." )
		errors = true
	end

	logf( LG_INF, lgid, "Making basic settings")
	_cmd(scanner, 
				SCANNER_ALLOW_READ_BATCH_CODE,
				SCANNER_CMD_SET_STOP_SUFFIX,
				SCANNER_CMD_ENABLE_STOP_SUFFIX,
--				SCANNER_CMD_AUTO_SCAN,
				SCANNER_CMD_CODE_ID_ON
			)
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error setting innitial settings" )
		errors = true
	end

	-- Get version info. We need to match some stuff in a blob of free formatted text to 
	-- get the proper info
	
	logf( LG_INF, lgid, "Getting scanner module info")
	_cmd(scanner,SCANNER_CMD_GET_INFO)
	err,answer = _cmd_commit(scanner)
	if not err then
		local version = ""
		local tmp = answer:match("Device ID: %s+(%S+)")
		if tmp then version = version .. tmp .. " " end
		local tmp = answer:match("uIMG Ver:%s+(%S+)")
		if tmp then version = version .. "/ app:" .. tmp .. " " end
		local tmp = answer:match("Firmware Ver:%s+(%S+)")
		if tmp then version = version .. "/ fw:" .. tmp .. " " end
		config:lookup("/dev/scanner/version"):setraw(version)
	else
		logf(LG_WRN, lgid, "Could not acquire scanner version information")
		errors = true
	end
	
	if first_time then
		for _,rec in ipairs( scanner.enable_disable ) do
			if not does_firmware_support( rec ) then
				logf(LG_INF,lgid,"Barcode %s not supported by firmware %s", rec.name, config:get("/dev/scanner/version"))
			end
		end
		first_time = false
	end

	logf( LG_INF, lgid, "Setting reading constraint and 2d/1d")
	-- prohibit multi reading:
	if config:get("/dev/scanner/multi_reading_constraint") == "On" then
		_cmd(scanner,SCANNER_CMD_CONSTRAIN_MULTI_ON, SCANNER_CMD_CONSTRAIN_MULTI_ALL)
	elseif config:get("/dev/scanner/multi_reading_constraint") == "Semi" then
		_cmd(scanner,SCANNER_CMD_CONSTRAIN_MULTI_ON, SCANNER_CMD_CONSTRAIN_MULTI_SEMI)
	end

	-- Disable 2D codes if configured
	if config:get("/dev/scanner/barcodes") == "1D only" then
		_cmd(scanner,SCANNER_CMD_2D_DISABLE)
	else
		_cmd(scanner,SCANNER_CMD_2D_ENABLE)
	end
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error setting 1d/2d or reading constraint" )
		errors = true
	end

	-- enable/disable barcodes when this is configured
	for _,code in ipairs(enable_disable_HR200) do
		-- skip code128 because that should always be turned on
		if code.name ~= "Code128" then
			_configure_barcode( scanner, code.name )
		end
	end
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error enabling/disabling barcodes." )
		errors = true
	end

	-- Configure code prefixes
	for _,i in ipairs(prefixes) do
		if i.cmd_HR200 then
			_cmd(scanner, i.cmd_HR200 .. '="' .. i.prefix_2d .. '"' )
		end
	end
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error configuring prefixes." )
		errors = true
	end

	-- Configure illumination mode: Blinking,Always ON,Always OFF
	_cmd(scanner, get_illumination_mode_code( config:get("/dev/scanner/illumination_led") ) )

	-- Configure aiming mode: Blinking,Always ON,Sensor mode
	local aiming_led_mode = config:get("/dev/scanner/aiming_led")
	if     aiming_led_mode == "Always ON"   then 
		_cmd(scanner, SCANNER_CMD_AIM_ON )
	elseif aiming_led_mode == "Sensor mode" then 
		_cmd(scanner, SCANNER_CMD_AIM_SMART )
	else 
		_cmd(scanner, SCANNER_CMD_AIM_WINK )
	end
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error configuring aiming mode." )
		errors = true
	end

	-- Configure sensitivity: Low,Medium,High
	local reading_sensitivity = config:get("/dev/scanner/reading_sensitivity")
	if reading_sensitivity == "Low" then
	   -- Low sensitivity moet geprogrammeerd staan op 20:
		_cmd(scanner, "0312040", "0000020", "0000000", SCANNER_CMD_SAVE, SCANNER_CMD_SENSITIVITY_LOW )
	elseif reading_sensitivity == "High" then
		_cmd(scanner, SCANNER_CMD_SENSITIVITY_HIGH )
	else
		_cmd(scanner, SCANNER_CMD_SENSITIVITY_NORMAL )
	end

	-- this should be the last: it enabled scanning!
	_cmd(scanner, SCANNER_CMD_AUTO_SCAN )
	err, answer = _cmd_commit(scanner)
	if err then
		logf( LG_WRN, lgid, "Error setting scanner sensitivity." )
		errors = true
	end

--logf( LG_WRN, lgid, "Temporary insert with wait for debugging disable")
--for q=1,20 do
--	sys.sleep(0.1)
--	local data = _read(scanner,5003)
--end
--logf( LG_WRN, lgid, "Continueing")
--if false then
--end

	-- enable scanner
	_write(scanner, "\0272")
	_wait_ack(scanner)

	evq:fd_add(fd)
	evq:register("fd", on_fd_scanner, scanner)

	if errors == true then
		logf(LG_WRN, lgid, "Finnished configuring scanner, but there were errors.")
		
		led:set("yellow","blink")
		scanner.retry_counter = scanner.retry_counter + 1
		local dt = scanner.retry_counter ^ 2 + 10
		logf(LG_WRN, lgid, "Retry configure in %d seconds", dt)
		evq:push("reinit_scanner", scanner, dt)
	else
		logf(LG_INF, lgid, "Successfully detected and configured scanner")
		led:set("yellow","on")
		scanner.retry_counter = 0
	end
end

-- enable the 2d barcodes for barcode programming
local function enable_citical_2d(scanner)
	_cmd(scanner, 
			SCANNER_CMD_2D_ENABLE, 
			find_by_name(scanner.enable_disable, "QR_Code").on, 
			find_by_name(scanner.enable_disable, "DataMatrix").on )
	_cmd_commit(scanner)
end

-- reset the barcodes enabled in enable_citical_d2() to config settings
local function reinit_2d(scanner)
	if config:get("/dev/scanner/barcodes") == "1D only" then
		_cmd(scanner,SCANNER_CMD_2D_DISABLE)
	else
		_configure_barcode( scanner, "QR_Code" )
		_configure_barcode( scanner, "DataMatrix", true )
	end
	_cmd_commit(scanner)
end


--
-- Close and restore tty settings
--

local function close(scanner, quick)
	if scanner.fd then
		if not quick then scanner:disable() end
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
		_write(scanner, "\0272")
		_wait_ack(scanner)
		_cmd(scanner, get_illumination_mode_code(config:get("/dev/scanner/illumination_led")) )
		_cmd_commit(scanner);
		led:set("yellow","on")
	end
end


--
-- Disable scanning
--

local function disable(scanner)
	logf(LG_DBG, lgid, "Disabling scanner")
	if scanner.fd then
		--logf(LG_DMP,lgid,"%s",debug.traceback() )
		_write(scanner, "\0270")
		_wait_ack(scanner)
		_cmd(scanner, get_illumination_mode_code("Always OFF") )
		_cmd_commit(scanner);
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

	if not Scanner_2d.is_available() then
		return nil
	end

	local scanner = {

		-- data
		fd = nil,
		device = nil,
		scanbuf = "",
		type = "em2027", -- watch out when em3000 scanner modules are released
		enable_disable = enable_disable_HR200,
		retry_counter = 0,
		commands = {}, -- the commands collected for cmd_commit
		last_received_data_time = 0, -- the last time data was received from the scanner
		last_barcode = "",
		last_barcode_time = 0,

		-- scanner methods:
		
		open = open,
		close = close,
		enable = enable,
		disable = disable,

		enable_citical_2d = enable_citical_2d,
		reinit_2d = reinit_2d,
	}

	config:add_watch("/dev/scanner", "set", function (e) evq:push( "reinit_scanner" ) end)
	evq:register("reinit_scanner", function (e,s) s:close() s:open() end, scanner)
	
	evq:register( "input", 	
		function( event, scanner )
			if event.data.msg == "disable" then
				scanner:close()
			elseif event.data.msg == "enable" then
				scanner:open()
			end
		end, scanner )

	return scanner

end

-- vi: ft=lua ts=3 sw=3
	
