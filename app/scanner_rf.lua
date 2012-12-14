--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_rf", package.seeall)

require("mifare")

local lgid = "scan_rf"

-- convert spec like 1,2,5,6 to an integer array
local function convert_sectors( ss )
	local ar = {}
	string.gsub( ss, "(%d+)", function (n) table.insert(ar,n+0) end )
	return ar
end


local function on_mifare_data( event, scanner_rf )

	local nsector = scanner_rf.last_cardinfo.nsector
	local nblock = scanner_rf.last_cardinfo.nblock
	local blocksize = scanner_rf.last_cardinfo.blocksize
	local cardnum = scanner_rf.last_cardinfo.cardnum
	local cardnumstr = scanner_rf.last_cardinfo.cardnumstr

	local key = config:get("/dev/mifare/key")
	logf(LG_DMP,lgid,"Using rf key: %s", od(key))

	-- read card
	local result = scanner_rf.mifare_drv:chkkey(key)
	local all_data = cardnum
	if result ~= 0 then
		logf(LG_INF,lgid,"Mifare card %s, chkkey error: %d", cardnumstr, result);
	else
		local sectors = convert_sectors( config:get("/dev/mifare/relevant_sectors") )
		local data = ""
		for _,sector in ipairs( sectors ) do
			if sector <= nsector then
				result, data = scanner_rf.mifare_drv:readblock(sector, nblock, blocksize*nblock)
				if result ~= 0 then 
					logf(LG_INF,lgid,"Mifare Card %s, sector %d, readblock error: %d", cardnumstr, sector, result);
					break 
				end
				logf(LG_DBG,lgid,"Sector %d: '%s'", sector, data);
				all_data = all_data .. data
			end
		end
	end
	
	-- handle error codes
	if result == 0 then
		beeper:beep_ok()
		evq:push("scanner", { result = "ok", barcode = all_data, prefix="MF" })
	else
		beeper:beep_error()
		if result == -7 then
			display:clear()
			display:format_text(config:get("/dev/mifare/msg/access_violation/text"), 1, 1, "c", "m", 18)
			evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout")))
		else
			display:clear()
			display:format_text(config:get("/dev/mifare/msg/incomplete_scan/text"), 1, 1, "c", "m", 18)
			evq:push("cit_idle_msg", nil, tonumber(config:get("/cit/messages/idle/timeout")))
		end
	end

end

--
-- Scanner fd callback, used for both internal and external scanner
--

local function on_fd_scanner(event, scanner_rf)

	if event.data.fd ~= scanner_rf.fd then
		return
	end

	local result, nsector, nblock, blocksize, cardnum =
				 scanner_rf.mifare_drv:fetch_querycardinfo()
	--print("DEBUG: scanner_rf.on_fd_scanner() fetch_querycardinfo() = " .. result)

	if result == 0 then
		local cardnumstr = string.format( "%02x%02x%02x%02x",
					string.byte(cardnum,1), string.byte(cardnum,2), 
					string.byte(cardnum,3), string.byte(cardnum,4))
		--print("DEBUG: cardnum = 0x" .. cardnumstr)
		
		if	(scanner_rf.last_cardinfo ~= nil and scanner_rf.last_cardinfo.cardnumstr ~= cardnumstr) or
			((scanner_rf.last_cardinfo == nil or sys.hirestime()-scanner_rf.last_send_querycardinfo_time>0.2) and
			 sys.hirestime()-scanner_rf.last_cardinfo_time > tonumber(config:get("/dev/mifare/prevent_duplicate_scan_timeout"))) then
			scanner_rf.last_cardinfo = {
					nsector = nsector,
					nblock = nblock,
					blocksize =  blocksize,
					cardnum = cardnum,
					cardnumstr = cardnumstr }
			logf(LG_DBG, lgid, "card info={nsector=%d, nblock=%d, blocksize=%d, cardnum=%s", 
					nsector, nblock, blocksize, cardnumstr )
					
			on_mifare_data( event, scanner_rf )
		end
		scanner_rf.last_cardinfo_time = sys.hirestime()
	elseif result == -8 then
		scanner_rf.last_cardinfo = nil
	end

	evq:push("send_querycardinfo", scanner_rf, 0.2)
end

local function on_send_querycardinfo( event, scanner_rf )

	--print("DEBUG: on_send_querycardinfo()")
	local result = scanner_rf.mifare_drv:send_querycardinfo(scanner_rf.fd)

	if result < 0 then
		logf(LG_WRN,lgid,"Mifare scanner (temporary?) not operational. (querycardinfo error=%d).", result)
		evq:push("send_querycardinfo", scanner_rf, 10)
	else
		scanner_rf.last_send_querycardinfo_time = sys.hirestime()
	end
	
end

--
-- Open and configure scanner device
--
local function open(scanner_rf)

	scanner_rf:close()
	scanner_rf.device = config:get("/dev/mifare/device")
			
	logf(LG_INF, "scanner_rf", "Opening mifare rfid scanner on device %s", scanner_rf.device)

	require("mifare")
	scanner_rf.mifare_drv = mifare.new()
	scanner_rf.fd = scanner_rf.mifare_drv:open( scanner_rf.device )

	if scanner_rf.fd <= 0 then
		scanner_rf.fd = 0
		scanner_rf.mifare_drv:close()
		scanner_rf.mifare_drv = nil
		logf(LG_WRN,lgid,"No mifare/rfid hardware found")
		return false
	end

	scanner_rf.scanbuf = ""
	
	evq:fd_add(scanner_rf.fd)
	evq:register("fd", on_fd_scanner, scanner_rf)

	evq:register("send_querycardinfo", on_send_querycardinfo, scanner_rf)
	evq:push("send_querycardinfo", nil, 10)

	return true

end


--
-- Close and restore tty settings
--
local function close(scanner_rf)
	if scanner_rf.fd ~= 0 then
		evq:unregister("send_querycardinfo", on_send_querycardinfo)

		evq:unregister("fd", on_fd_scanner, scanner_rf)
		evq:fd_del(scanner_rf.fd)

		scanner_rf.mifare_drv:close()
		scanner_rf.mifare_drv = nil
		scanner_rf.fd = nil
	end
end


-- 
-- Enable scanning
--
local function enable(scanner_rf)
	--- TODO
	logf(LG_DBG, lgid, "Enabling rfid scanner_rf")
end


--
-- Disable scanning
--
local function disable(scanner_rf)
	--- TODO
	logf(LG_DBG, lgid, "Disabling rfid scanner_rf")
end


--
-- is hardware available
--
local has_mifare_hw = nil
function is_available()

	local device = config:get("/dev/mifare/device")
	if not has_mifare_hw then
		local hw = config:get( "/dev/mifare/has_hardware" )
		--print("DEBUG: scanner_rf:is_available() hw=" .. hw)
		if hw == "auto" then
			local mifare_drv = mifare.new()
			local fd = mifare_drv:open( device )
			--print("DEBUG: scanner_rf:is_available() fd==" .. fd)
			if fd <= 0 then
				-- should be NLRF_ERR_NODEV
				has_mifare_hw = false
			else
				has_mifare_hw = true
				mifare_drv:close()
			end
		elseif hw == "yes" then
			has_mifare_hw = true
		else
			has_mifare_hw = false
		end
	end

	--print("DEBUG: scanner_rf:is_available() retval=" .. (has_mifare_hw and "true" or "false"))
	return has_mifare_hw
end

--
-- Constructor
--
function new()

	local scanner_rf = {

		mifare_drv = nil,

		-- data
		fd = 0,
		device = nil,
		scanbuf = "",
		type = "rf",

		-- scanner_rf independent methods
		open = open,
		close = close,
		enable = enable,
		disable = disable,

		last_cardinfo = nil,
		last_cardinfo_time = 0,
		last_send_querycardinfo_time = 0,
	}

	if scanner_rf:open() then

		config:add_watch("/dev/mifare", "set", function() scanner:open() end, scanner)
		evq:register("reinit_scanner", function() scanner:open() end, scanner)
		
		return scanner_rf

	else

		return nil

	end

end

-- vi: ft=lua ts=3 sw=3
	
