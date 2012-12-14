--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_1d", package.seeall)

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
		if t1 then
			local barcode = t1
			scanner.scanbuf = t2 or ""
			
			logf(LG_DBG, "scanner", "Scanned barcode '%s'", barcode)

			-- Barcode is complete. Fixup the barcode type prefix to be the
			-- compatible format

			local prefix_in, barcode = barcode:match("(.)(.+)")
			local prefix_out = nil

			for _, i in ipairs(prefixes) do
				if prefix_in == i.prefix_1d then
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

	logf(LG_DMP,  "scanner", "< " .. data)
	return data
end

local function read( scanner )
	local delay=10
	local buff
	while buff == nil or #buff == 0 do
		buff = sys.read(scanner.fd, 1024)
		delay = delay - 1
		if delay == 0 then
			logf(LG_DBG,"scanner", "Nothing received from scanner within timout of 1 second")
			return "";
		end
		sys.sleep(0.1)
	end
	
	buff = buff .. scanner:flush( )
	
	logf(LG_DMP, "scanner", "Scanner returned " .. buff)
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
	logf(LG_DBG, "scanner", "Sent %s to scanner (%s)", cmd, cmd_txt_label )
	local answer = scanner:read();
	if not string.match( answer, "!.+;" ) then
		logf(LG_WRN, "scanner", "Error '%s' on scanner command #%s; during programming", answer, cmd )
		return answer, false
	end
	return answer, true
end


local function switch_to_programming_mode( scanner )
	logf(LG_DMP, "scanner", "Switching to programming mode")
	sys.write(scanner.fd, "$$$$")			-- Switch to programming mode
	local answer = scanner:read( )
	if answer ~= "@@@@" then
		logf(LG_WRN, "scanner", "Scanner %s might not work (Could not switch to programming mode)", scanner.device )
		return false
	end
	return true
end


local function switch_to_normal_mode( scanner )
	logf(LG_DMP, "scanner", "Switching to normal mode")
	sys.write(scanner.fd, "%%%%")			-- Switch back to normal mode
	local answer = scanner:read( );
	if answer ~= "^^^^" then
		logf(LG_WRN, "scanner", "Scanner %s: Could not switch to normal mode", scanner.device )
		return false
	end
	return true
end


local function activate_scanning_mode( scanner, mode )

	if scanner.fd == nil then
		logf(LG_WRN,"scanner","nill-file descriptor. Scanning mode %s not activated.", mode)
		return
	end
	if mode=="Off" then
		-- TODO: this does not work: the scanner still scans! Also: Deep sleep does not recover!
		data, good = scanner:cmd( "#99900102;", "Sleep" ) 
		if not good then return; end
	elseif mode=="Blinking" then
		data, good = scanner:cmd( "#99900151;#99900000;#99900001", "Short Interval length" )
		if not good then return; end
		data, good = scanner:cmd( "#99900112;", mode )
		if not good then return; end
	elseif mode=="Sensor mode" then
		data, good = scanner:cmd( "#99900113;", mode )	scanner:cmd( "#99900104;", "Restart" ) -- tryout

		if not good then return; end
-- TODO: verify this (99900152 is NOT fast sensor mode):
--		data, good = scanner:cmd( "#99900152;#99900000;", "Fast sensor mode" )
--		if not good then return; end
	else
		data, good = scanner:cmd( "#99900114;", mode )
		if not good then return; end
	end

	return true
end

--
-- Open and configure scanner device
--
local function open(scanner)

	scanner:close()

	scanner.device = "/dev/ttyS1"

	logf(LG_DBG, "scanner", "Opening scanner on device %s", scanner.device)

	local fd, err = sys.open(scanner.device, "rw")
	if not fd then
		logf(LG_WRN, "scanner", "Could not open scanner device %s: %s", scanner.device, err)
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
	
	local data, good = scanner:cmd( "#99900301;", "Query the hardware version")
	if not good then 
		return; 
	end

	local version = data:match("{(.+);")
	if version then
		config:lookup("/dev/scanner/version"):setraw(version)
	end

	local data, good
	data, good = scanner:cmd( "#99900030;", "All settings to factory default")
	if not good then return; end

	data, good = scanner:cmd( "#99904111;", "Enable Stop Suffix")
	if not good then return; end

	--Blinking,Always ON,Sensor mode
	if not scanner:activate_scanning_mode( config:get("/dev/scanner/1d_scanning_mode") ) then return ; end

-- checking of the return code is not done properly
-- on this command, but it seems to work without exception
	data, good = scanner:cmd( "#99904112;#99900000;#99900015;#99900020;", "Program Stop Suffix")
	if not good then return; end

	data, good = scanner:cmd( "#99904041;", "Allow Code ID Prefix")
	if not good then return; end

	-- disable barcodes when this is configured
	for _,code in ipairs(enable_disable_HR100) do
		logf(LG_DMP,"scanner", "Barcode %s (default=%s): %s=#%s;", code.name, code.default, (code.off and "off" or "on"), code.off or code.on)
		local id = code.name
		local node = config:get("/dev/scanner/enable-disable/" .. id )
		if node then
			if node=="false" and code.off then
				scanner:cmd("#" .. code.off .. ";", "disable scanning code " .. id)
			elseif node=="true" and code.on then
				scanner:cmd("#" .. code.on .. ";", "enabling scanning code " .. id)
			end	
		end
	end

	-- end programming
	if not scanner:switch_to_normal_mode( ) then 
		return 
	end

	logf(LG_DBG, "scanner", "Successfully detected and configured 1D scanner")
end


--
-- Close and restore tty settings
--

local function close(scanner)
	if scanner.fd then
		scanner:disable()
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
		type = "1d",

		-- methods
		open = open,
		close = close,
		enable = enable,
		disable = disable,
		
		cmd = cmd,
		read = read,
		flush = flush,

		activate_scanning_mode = activate_scanning_mode,
		switch_to_programming_mode = switch_to_programming_mode,
		switch_to_normal_mode = switch_to_normal_mode,
	}

	scanner:open()

	config:add_watch("/dev/scanner", "set", function() scanner:open() end, scanner)

	return scanner

end

-- vi: ft=lua ts=3 sw=3
	
