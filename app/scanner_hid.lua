--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_hid", package.seeall)

local lgid = "scanner"

------------------------------------------------------------------------
-- External scanner_hid in HID keyboard emulation
------------------------------------------------------------------------

--
-- Scanner fd callback, used for both internal and external scanner
--

local function on_fd_scanner(event, scanner)

	if event.data.fd ~= scanner.fd then
		return
	end

	local read_data = sys.read(scanner.fd, 256)

	if read_data then
		logf(LG_DBG,lgid,"read: '%s'", read_data)
		scanner.scanbuf = scanner.scanbuf .. read_data

		local data
		repeat
			local rest
			data, rest = scanner.scanbuf:match("(.-)[\r\n](.*)") 
			if data then
				local event_data = { result = "ok" }
				scanner.scanbuf = rest or ""
			
				logf(LG_DBG, lgid, "part data '%s'", data)

				-- Barcode is complete. 

				if config:get("/dev/extscanner/raw") == "true" then
					event_data.prefix = "U"
					event_data.barcode = data
				else
					-- Fixup the barcode type prefix to be the compatible format
					local prefix_in
					prefix_in, event_data.barcode = data:match("(.)(.+)")
					for _, i in ipairs(prefixes) do
						if prefix_in == i.prefix_hid then
							logf(LG_DBG, lgid, "Scanned %q barcode type", i.name)
							event_data.prefix = i.prefix_out
							break
						end
					end

					if not event_data.prefix then
						logf(LG_DBG, lgid, "Scanned unknown barcode type")
						event_data.prefix = "?"
					end
				end
			
				evq:push("scanner", event_data)
			end
		until data == nil
	end
end

--
-- Open and configure external scanner_hid device
--

local function open(scanner_hid)

	scanner_hid:close()
			
	local device = "/dev/tty0"

	logf(LG_DBG, "scanner_hid", "Opening external scanner on device %s", device)

	local fd, err = sys.open(device, "rw")
	if not fd then
		logf(LG_WRN, "scanner_hid", "Could not open scanner device %s: %s", device, err)
		return
	end

	scanner_hid.fd = fd
	scanner_hid.device = device
	scanner_hid.scanbuf = ""

	sys.set_noncanonical(fd, true)

	evq:fd_add(fd)
	evq:register("fd", on_fd_scanner, scanner_hid)

end


--
-- Close device
--

local function close(scanner_hid)
	if scanner_hid.fd then
		evq:fd_del(scanner_hid.fd)
		evq:unregister("fd", on_fd_scanner, scanner_hid)
		sys.set_noncanonical(scanner_hid.fd, false)
		sys.close(scanner_hid.fd)
		scanner_hid.fd = nil
	end
end


--
-- Constructor
--

function new(device, baudrate)

	local scanner_hid = {

		-- data
		fd = nil,
		device = nil,
		scanbuf = "",

		-- methods
		open = open,
		close = close,
	}

	return scanner_hid

end

-- vi: ft=lua ts=3 sw=3
	
