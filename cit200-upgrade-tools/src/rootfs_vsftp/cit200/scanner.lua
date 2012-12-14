--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner", package.seeall)



local SCANNER_CMD_SET_DEFAULTS      = "0001000"
local SCANNER_CMD_TERMINATOR_CR     = "0310000=0x0D00"
local SCANNER_CMD_TERMINATOR_ENABLE = "0309010"
local SCANNER_CMD_CONTINUOUS_SCAN   = "0302010"
local SCANNER_CMD_AIMING_ALWAYS_ON  = "0201010"
local SCANNER_CMD_1D_DISABLE        = "0001030"
local SCANNER_CMD_1D_ENABLE         = "0001040"
local SCANNER_CMD_2D_DISABLE        = "0001050"
local SCANNER_CMD_2D_ENABLE         = "0001060"

--
-- Scanner fd callback
--

local function on_fd_scanner(event, scanner)

	if event.data.fd ~= scanner.fd then
		return
	end

	local data = sys.read(scanner.fd, 256)

	if data then
		scanner.scanbuf = scanner.scanbuf .. data

		local t1, t2 = scanner.scanbuf:match("(.-)\r(.*)") 
		if t1 then
			local barcode = t1
			scanner.scanbuf = t2 or ""
			logf(LG_INF, "validator", "Scanned barcode '%s'", barcode)
			evq:push("scanner", { result = "ok", barcode = barcode })
		end
	end
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

	repeat
		local buf = sys.read(scanner.fd, 1024)
		if buf and #buf>0 then
			sys.sleep(0.1)
		end
	until not buf or #buf == 0
end


--
-- Wait for ACK
--

local function wait_ack(scanner)
	local tstart = sys.hirestime()
	repeat
		local data = sys.read(scanner.fd, 1)
		if data == "\006" then
			logf(LG_DMP, "scanner", "< ACK")
			return true
		end
	until sys.hirestime() - tstart > 1.0
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
		scanner:wait_ack()
	end
	
end


--
-- Open and configure scanner device
--

local function open(scanner)

	scanner:close()
			
	local device = config:get("/dev/scanner/device")
	local baudrate = config:get("/dev/scanner/baudrate")
	local barcodes = config:get("/dev/scanner/barcodes")
	
	if device == "/dev/null" then
		return
	end

	logf(LG_DBG, "scanner", "Opening scanner on device %s, baudrate %s", device, baudrate)

	local fd, err = sys.open(device, "rw")
	if not fd then
		logf(LG_WRN, "scanner", "Could not open scanner device %s: %s", device, err)
		return
	end

	scanner.fd = fd
	scanner.device = device
	scanner.scanbuf = ""

	sys.set_noncanonical(fd, true)
	sys.set_baudrate(fd, baudrate)

	evq:fd_add(fd)
	evq:register("fd", on_fd_scanner, scanner)

	scanner:ping()
	scanner:cmd(
		SCANNER_CMD_SET_DEFAULTS,
		SCANNER_CMD_TERMINATOR_CR,
		SCANNER_CMD_TERMINATOR_ENABLE,
		SCANNER_CMD_CONTINUOUS_SCAN,
		SCANNER_CMD_AIMING_ALWAYS_ON
	)
	scanner:flush()

	if barcodes == "1D only" then
		scanner:cmd(SCANNER_CMD_2D_DISABLE)
	else
		scanner:cmd(SCANNER_CMD_2D_ENABLE)
	end

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
-- Set scanner data format
--

local function set_barcode_format(scanner, format)

	if format == "plain" or format == "base64" then
		logf(LG_DBG, "scanner", "Set barcode format to %s", format)
		scanner.barcode_format = format
	else
		logf(LG_WRN, "scanner", "Illegal barcode format %s", format)
	end

end


--
-- Constructor
--

function new(device, baudrate)
	

	local scanner = {

		-- data
		fd = nil,
		device = nil,
		scanbuf = "",
		barcode_format = "plain",

		-- methods
		open = open,
		close = close,
		ping = ping,
		flush = flush,
		wait_ack = wait_ack,
		cmd = cmd,
		enable = enable,
		disable = disable,
		set_barcode_format = set_barcode_format,
	}

	config:add_watch("/dev/scanner", "set", function() scanner:open() end, scanner)

	scanner:open()

	return scanner

end

-- vi: ft=lua ts=3 sw=3
	
