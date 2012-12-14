--
-- Copyright © 2007 All Rights Reserved.
--

module("Scanner_rf", package.seeall)

require("mifare")

local lgid = "scan_rf"

local mifare_drv = nil
local has_mifare_hw = nil

local function get_mifare_drv()
	if mifare_drv == nil then
		mifare_drv = mifare.new()
	end
	return mifare_drv
end

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

	local key_str = config:get("/dev/mifare/key_A")
	logf(LG_DBG,lgid,"Using rf key_A: \"%s\"", key_str)
	local key = key_str:gsub("%x",function (nibble) return string.char(tonumber(nibble,16)) end)
	logf(LG_DMP,lgid,"key: %s", od(key))

	-- read card
	local result = 0
	local all_data = ""
	if #key_str ~= 0 then
		result = get_mifare_drv():chkkey(key)
		if result ~= 0 then
			logf(LG_INF,lgid,"Mifare card %s, chkkey error: %d", cardnumstr, result);
		end
	end
	
	if result == 0 then
		local sectors = convert_sectors( config:get("/dev/mifare/relevant_sectors") )
		local data = ""
		for count,sector in ipairs( sectors ) do
			if sector <= nsector then
				result, data = get_mifare_drv():readblock(sector, nblock, blocksize*nblock)
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
		
		local data = ""
		if config:get("/dev/mifare/cardnum_format") == "hexadecimal" then
			data = cardnumstr
		else
			data = cardnum
		end
		
		if config:get("/dev/mifare/send_cardnum_only") == "false" then
			if config:get("/dev/mifare/sector_data_format") == "base 64" then
				data = data .. base64.encode(all_data)
			elseif config:get("/dev/mifare/sector_data_format") == "hex escapes" then
				data = data .. binstr_to_escapes( all_data, 32, 256, "" )
			else
				data = data .. all_data
			end
		end
			
		evq:push("scanner", { result = "ok", barcode = data, prefix="MF" })
	else
		beeper:beep_error()
		if result == -3 or result == -4 then
			evq:push("scanner", { result = "error", msg = config:get("/dev/mifare/msg/access_violation/text") } )
		else
			evq:push("scanner", { result = "error", msg = config:get("/dev/mifare/msg/incomplete_scan/text") } )
		end
	end

	return result
end

--
-- Scanner fd callback, used for both internal and external scanner
--

local function on_fd_scanner(event, scanner_rf)

	if event.data.fd ~= scanner_rf.fd then
		return
	end

	local result, nsector, nblock, blocksize, cardnum =
				 get_mifare_drv():fetch_querycardinfo()
	logf(LG_DMP,lgid, "scanner_rf.on_fd_scanner() fetch_querycardinfo() = %d", result)

	if result == 0 then
		local cardnumstr = string.format("%02x%02x%02x%02x", string.byte(cardnum,1,4) )
		logf(LG_DMP, lgid, "cardnum = 0x%s", cardnumstr)
		
		if	(scanner_rf.last_cardinfo ~= nil and 
				scanner_rf.last_cardinfo.cardnumstr ~= cardnumstr) or
				((scanner_rf.last_cardinfo == nil or 
				sys.hirestime()-scanner_rf.last_send_querycardinfo_time>0.2) and
				sys.hirestime()-scanner_rf.last_cardinfo_time > tonumber(config:get("/dev/mifare/prevent_duplicate_scan_timeout"))) then
			logf(LG_DBG, lgid, "card info={nsector=%d, nblock=%d, blocksize=%d, cardnum=%s", nsector, nblock, blocksize, cardnumstr )
			
			local prev_cardinfo = scanner_rf.last_cardinfo
			scanner_rf.last_cardinfo = {
					nsector = nsector,
					nblock = nblock,
					blocksize =  blocksize,
					cardnum = cardnum,
					cardnumstr = cardnumstr }
			local result = on_mifare_data( event, scanner_rf )
			if result < 0 then
				scanner_rf.last_cardinfo = prev_cardinfo
			else
				scanner_rf.last_cardinfo_time = sys.hirestime()
			end
		else
			scanner_rf.last_cardinfo_time = sys.hirestime()
		end
		
	end

	evq:push("send_querycardinfo", scanner_rf, 0.2)
end

local function on_send_querycardinfo( event, scanner_rf )

	--print("DEBUG: on_send_querycardinfo()")
	local result = get_mifare_drv():send_querycardinfo(scanner_rf.fd)

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

	if has_mifare_hw == false then
		return false
	end
	
	local device = config:get("/dev/mifare/device")
	
	if scanner_rf.fd ~= nil and scanner_rf.device == device then
		-- no need to reopen (also: nlrf_close has a bug (svn 698)!)
		return
	end
	
	scanner_rf:close()
	
	logf(LG_DBG,lgid,"Searching for mifare/rfid hardware")
	local fd = get_mifare_drv():open( device )

	if fd <= 0 then
		logf(LG_DBG,lgid,"No mifare/rfid hardware found on device %s.", device)
		has_mifare_hw = false
		return false
	end
	has_mifare_hw = true
	
	scanner_rf.device = device
	scanner_rf.fd = fd

	-- store the modeltype in the configuration:
	local modeltype = get_mifare_drv():get_modeltype(fd)
	local modeltype = modeltype > 0 and string.format("%d", modeltype ) or "detect err"
	config:lookup("/dev/mifare/modeltype"):setraw( modeltype )

	logf(LG_INF, lgid, "Mifare hardware found on device %s", scanner_rf.device)

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
	if scanner_rf.fd ~= nil then
		logf(LG_DBG,lgid,"Closing mifare")
		evq:unregister("send_querycardinfo", on_send_querycardinfo)

		evq:unregister("fd", on_fd_scanner, scanner_rf)
		evq:fd_del(scanner_rf.fd)

		get_mifare_drv():close(scanner_rf.fd)
		scanner_rf.fd = nil
		scanner_rf.device = nil
	end
end


-- 
-- Enable scanning
--
local function enable(scanner_rf)
	--- TODO
	logf(LG_DBG, lgid, "Enabling rfid scanner_rf")
	scanner_rf:open()
end


--
-- Disable scanning
--
local function disable(scanner_rf)
	--- TODO
	logf(LG_DBG, lgid, "Disabling rfid scanner_rf")
	scanner_rf:close()
end

--
-- is hardware available
--
function is_available()

	if has_mifare_hw==nil then
		logf(LG_WRN,lgid,"No mifare hardware detected yet. Assuming not available.")
		return false
	end

	return has_mifare_hw
end

--
-- Constructor
--
function new()

	local scanner_rf = {

		-- data
		fd = nil,
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

		config:add_watch("/dev/mifare", "set", function(event, scnnr) scnnr:open() end, scanner_rf)
		evq:register("reinit_scanner", function(event, scnnr) scnnr:open() end, scanner_rf)

		evq:register( "input", 	
			function( event, scanner )
				logf(LG_DBG,lgid,"event.data.msg='%s'",event.data.msg)
				if event.data.msg == "disable" then
					scanner:disable()
				elseif event.data.msg == "enable" then
					scanner:enable()
				end
			end, scanner_rf )
		
		return scanner_rf

	else

		return nil

	end

end

-- vi: ft=lua ts=3 sw=3
	
