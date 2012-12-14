--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_1d", package.seeall)

local lgid = "scanner"
--
-- Scanner fd callback, used for both internal and external scanner
--

local function on_fd_scanner(event, scanner)

	if event.data.fd ~= scanner.fd then
		return
	end

	local data = sys.read(scanner.fd, 256)

	if data then
		scanner.scanbuf = scanner.scanbuf .. data

		local t1, t2 = scanner.scanbuf:match("(.-)[\r\n](.*)")
		logf(LG_DBG,lgid,"Scanbuf:\n%s", dump( scanner.scanbuf, 10 ) )
		if t1 and #t1==0 then
			logf( LG_DBG,lgid, "Skipping empty scan data" )
			scanner.scanbuf = t2 or ""
		elseif t1 and #t1>0 then
			local barcode = t1
			scanner.scanbuf = t2 or ""
			
			local dup_scan_timeout = tonumber( config:get("/dev/scanner/prevent_duplicate_scan_timeout") )
			--print("DEBUG: dup_scan_timeout = " .. (dup_scan_timeout or "nil"))
			if dup_scan_timeout == nil or
					scanner.last_barcode ~= barcode or
					sys.hirestime() - scanner.last_barcode_time > dup_scan_timeout then
				
				scanner.last_barcode = barcode
				scanner.last_barcode_time = sys.hirestime()

				beeper:beep_ok()
			
				logf(LG_DBG, lgid, "Scanned barcode '%s'", barcode)

				-- Barcode is complete. Fixup the barcode type prefix to be the
				-- compatible format

				local prefix_in, barcode = barcode:match("(.)(.+)")
				local prefix_out = nil

				for _, i in ipairs(prefixes) do
					if prefix_in ~= nil and prefix_in == i.prefix_1d then
						logf(LG_DBG, lgid, "Scanned %q barcode type", i.name)
						prefix_out = i.prefix_out
						break
					end
				end

				if not prefix_out then
					logf(LG_DBG, lgid, "Scanned unknown barcode type")
					prefix_out = "?"
				end

				evq:push("scanner", { result = "ok", barcode = barcode, prefix=prefix_out })
			else
				logf(LG_DBG,lgid,"Duplicate barcode %s scanned and ignored", barcode)
			end
		end
	else
		logf(LG_DBG,"event but no data received from scanner device")
	end
end


local function flush( scanner, n )
	local data = ""
	if n==nil or n==0 then n=1024; end
	
	repeat
		sys.sleep(0.01)
		local buf = sys.read(scanner.fd, n)
		if buf and #buf>0 then
			data = data .. buf
		end
	until not buf or #buf == 0

	logf(LG_DBG,  lgid, "< %s", data)
	return data
end

local function read( scanner )
	local delay=10
	local buff
	while buff == nil or #buff == 0 do
		buff = sys.read(scanner.fd, 1024)
		delay = delay - 1
		if delay == 0 then
			logf(LG_DBG,lgid, "Nothing received from scanner within timeout of 1 second")
			return "";
		end
		sys.sleep(0.1)
	end
	
	buff = buff .. scanner:flush( )
	
	logf(LG_DBG, lgid, "Scanner returned '%s'", buff)
	return buff
end

--
-- Send a command to the scanner (the scanner should already be in programming mode
-- @param fd            the file descriptor of the serial port to communicate with
-- @param cmd           the bare command (withoout it's pre and suffix)
-- @param cm_txt_label  the label of the command, this is only used for logging purposes
-- @return txt, goodflag
--         

local function cmd( scanner, cmd, cmd_txt_label )
	sys.write(scanner.fd, cmd )
	logf(LG_DBG, lgid, "Sent %s to scanner (%s)", cmd, cmd_txt_label )
	local answer = scanner:read();
	if not string.find( answer, "^!.+;" ) then
		logf(LG_WRN, lgid, "Error '%s' on scanner command %s during programming", answer, cmd )
		return answer, false
	end
	return answer, true
end


local function switch_to_programming_mode( scanner )
	logf(LG_DBG, lgid, "Switching to programming mode")
	sys.write(scanner.fd, "$$$$")			-- Switch to programming mode
	local answer = scanner:read( )
	if answer ~= "@@@@" then
		logf(LG_WRN, lgid, "Scanner %s might not work (Could not switch to programming mode)", scanner.device )
		return false
	end
	return scanner:cmd( "#99900031;", "Code programming on" )
end


local function switch_to_normal_mode( scanner )
	logf(LG_DBG, lgid, "Switching to normal mode")
	local answer1, result = scanner:cmd( "#99900032;", "Code programming off" )
	sys.write(scanner.fd, "%%%%")			-- Switch back to normal mode
	local answer2 = scanner:read( );
	if not string.find(answer2,"%^%^%^%^$") then
		logf(LG_WRN, lgid, "Scanner %s: Could not switch to normal mode", scanner.device )
		return false
	end
	return true
end


local function activate_scanning_mode( scanner, mode )

	local data = nil
	local retval = false
	if scanner.fd == nil then
		logf(LG_WRN,lgid,"nil-file descriptor. Scanning mode %s not activated.", mode)
	elseif mode=="Off" then
		-- TODO: this does not work: the scanner still scans! Also: Deep sleep does not recover!
		data, retval = scanner:cmd( "#99900102;", "Sleep" ) 
	elseif mode=="Blinking" then
		data, retval = scanner:cmd( "#99900151;#99900000;#99900001", "Short Interval length" )
		if retval then
			data, retval = scanner:cmd( "#99900112;", mode )
		end
	elseif mode=="Sensor mode" then
		data, retval = scanner:cmd( "#99900113;", mode )
		--	scanner:cmd( "#99900104;", "Restart" )
		-- TODO: verify this (99900152 is NOT fast sensor mode):
		if retval then
			data, retval = scanner:cmd( "#99900152;", "High sensitivity" )
		end
	else
		data, retval = scanner:cmd( "#99900114;", mode )
	end

	return data, retval
end

--
-- Open and configure scanner device
--
local function open(scanner)

	if scanner.fd then
		logf(LG_WRN, lgid, "Scanner already opened: not initializing scanner")
		return
	end

	led:set("yellow","flash")

	scanner.device = "/dev/ttyS1"

	logf(LG_DBG, lgid, "Opening scanner on device %s", scanner.device)

	local fd, err = sys.open(scanner.device, "rw")
	if not fd then
		logf(LG_WRN, lgid, "Could not open scanner device %s: %s", scanner.device, err)
		return
	end

	scanner.fd = fd
	scanner.scanbuf = ""

	sys.set_noncanonical(fd, true)
	sys.set_baudrate(fd, 9600)

	evq:fd_add(fd)
	evq:register("fd", on_fd_scanner, scanner)
	
	if not scanner:switch_to_programming_mode() then
		return
	end
	
	-- The retry is necessary because of an em1300 firmware bug which is not solved yet.
    -- When a settings failes it will probably succeed the next time or it is succeeded
	-- but gives (incorrect) an error back
    -- The patch is to retry and ignore errors the last time.
	local max_retry = 4
	local fatal = false

	local data, good = scanner:cmd( "#99900301;", "Query the hardware version")
	if good then 
		local version = data:match("{(.+);")
		if version then
			config:lookup("/dev/scanner/version"):setraw(version)
		end
	end

	if good or scanner.retry_counter>=max_retry then 
		data, lgood = scanner:cmd( "#99900030;", "All settings to factory default")
		good = lgood and good
	end
	
	-- apply pre_init
	local pre_init = config:get("/dev/scanner/em1300_pre_init")
	if pre_init ~= "" then
		for i,c in ipairs(pre_init:split( ";" )) do
			scanner:cmd("#" .. c .. ";", "em1300_pre_init #" .. i)
		end
	end

	if good or scanner.retry_counter>=max_retry then 
		data, lgood = scanner:cmd( "#99904020;", "Disable User Prefix")
		good = lgood and good
	end
	
	if good or scanner.retry_counter>=max_retry then 
		data, lgood = scanner:cmd( "#99904111;", "Enable Stop Suffix")
		good = lgood and good
	end
	
	if good or scanner.retry_counter>=max_retry then 
		data, lgood = scanner:cmd( "#99904112;#99900000;#99900015;#99900020;", "Program Stop Suffix 0x0d")
		good = lgood and good
	end
	
	if good or scanner.retry_counter>=max_retry then 
		data, lgood = scanner:cmd( "#99904041;", "Allow Code ID Prefix")
		good = lgood and good
	end

	if good or scanner.retry_counter>=max_retry then 
		--Blinking,Always ON,Sensor mode
		data, lgood = scanner:activate_scanning_mode( config:get("/dev/scanner/1d_scanning_mode") )
		good = lgood and good
	end
	
	-- disable/enable barcodes when this needed
	for _,code in ipairs(enable_disable_HR100) do
		local id = code.name
		local node = config:lookup("/dev/scanner/enable-disable/" .. id )
		if node and ( good or scanner.retry_counter>=max_retry ) then
			if node:get()=="false" and code.off then
				data, lgood = scanner:cmd("#" .. code.off .. ";", "disable scanning code " .. id)
				good = lgood and good
			elseif node:get()=="true" and code.on then
				data, lgood = scanner:cmd("#" .. code.on .. ";", "enabling scanning code " .. id)
				good = lgood and good
			end
		end
	end

	-- apply post_init
	local post_init = config:get("/dev/scanner/em1300_post_init")
	if post_init ~= "" then
		for i,c in ipairs(post_init:split( ";" )) do
			scanner:cmd("#" .. c .. ";", "em1300_post_init #" .. i)
		end
	end

	if not scanner:switch_to_normal_mode( ) then 
		logf(LG_WRN,lgid,"Could not switch to normal mode")
		good=false
		fatal = true
	end

	if not good then
		if scanner.retry_counter<max_retry then
			logf(LG_WRN, lgid, "Errors during scanner configuration.")
		
			led:set("yellow","blink")
			scanner.retry_counter = scanner.retry_counter + 1
			logf(LG_WRN, lgid, "Retry configure in 3 seconds")
			evq:push("reinit_scanner", nil, 3)
		elseif fatal then
			logf(LG_WRN, lgid, "Fatal error during scanner configuration.")
		else
			logf(LG_INF, lgid, "Ready configuring 1D scanner.")
			led:set("yellow","on")
			scanner.retry_counter = 0
			gpio:scan_1d_led( true )
			if config:get("/dev/scanner/default_illumination_leds") == "On" then
				gpio:set_pin(11, 0)
			else
				gpio:set_pin(11, 1)
			end
		end
	else
		logf(LG_INF, lgid, "Successfully detected and configured 1D scanner.")
		-- end programming
		led:set("yellow","on")
		scanner.retry_counter = 0
		gpio:scan_1d_led( true )
		if config:get("/dev/scanner/default_illumination_leds") == "On" then
			gpio:set_pin(11, 0)
		else
			gpio:set_pin(11, 1)
		end
	end
	
end


--
-- Close and restore tty settings
--

local function close(scanner, quick)
	if scanner.fd then
		gpio:scan_1d_led( false )
		if not quick then 
			scanner:disable()
		else
			led:set("yellow","off")
		end
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
	if scanner:switch_to_programming_mode( ) then

		scanner:activate_scanning_mode( config:get("/dev/scanner/1d_scanning_mode") )
		scanner:switch_to_normal_mode( )

		led:set("yellow","on")
	end
end


--
-- Disable scanning
--

local function disable(scanner)
	if scanner:switch_to_programming_mode() then
	
		scanner:activate_scanning_mode( "Off" )
		scanner:switch_to_normal_mode()
	
		led:set("yellow","off")
	end
end

local function barcode_on_off( scanner, name, on_off, wait_for_ack )
	-- not implemented (required for consistency with 2d scanner)
end

function is_available()
	return not Scanner_2d.is_available()
end

--
-- Constructor
--
-- This function creates two devices, one for the internal USB scanner, one for
-- an external scanner in USB HID keyboard emulation mode.
--

function new()

	if not Scanner_1d.is_available() then
		return nil
	end

	local scanner = {

		-- data
		fd = nil,
		device = nil,
		scanbuf = "",
		type = "em1300",
		enable_disable = enable_disable_HR100,
		retry_counter = 0,
		last_barcode = "",
		last_barcode_time = 0,

		-- scanner independent methods
		open = open,
		close = close,
		enable = enable,
		disable = disable,
		
		cmd = cmd,
		flush = flush,

		-- other methods:
		read = read,

		activate_scanning_mode = activate_scanning_mode,
		switch_to_programming_mode = switch_to_programming_mode,
		switch_to_normal_mode = switch_to_normal_mode,

		barcode_on_off = barcode_on_off,
	}

	config:add_watch("/dev/scanner", "set", function (e) evq:push( "reinit_scanner" ) end)
	evq:register("reinit_scanner", 
		function (e,s) 
			s:close()
			s:open()
		end, scanner)

	return scanner

end

-- vi: ft=lua ts=3 sw=3
	
