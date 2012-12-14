--
-- Copyright © 2007 All Rights Reserved.
--

-- This module interfaces with the optional rfid hw
-- When an rfid card is scanned it will throw an event:
-- event = scan_rf
--    data.data  => data.data:=all data preformatted in one string || nil
--    data.error => error message, only when data.data==nil

module("Scanner_rf", package.seeall)

require("mifare")

local lgid = "scan_rf"

local rfid_drv = nil
local has_rfid_hw = nil


-- The various states card-detection can have:

-- state_idle: no card detection active, accidental received cardinfo event are
-- ignored start_card_detection() will change the state to waiting_for_cardinfo
local state_idle = 1 

-- state_will_query_cardinfo: within some time a querycardinfo will be send and 
-- the state will become waiting_for_cardinfo:
local state_will_query_cardinfo = 2 

-- state_waiting_for_cardinfo: waiting for answer from send_querycardinfo(). 
-- stop_card_detection() changes the state to idle
local state_waiting_for_cardinfo = 3


local function get_rfid_drv()
	if rfid_drv == nil then
		rfid_drv = mifare.new()
	end
	return rfid_drv
end

 
-- convert spec like 1,2:2,15:0 to an array of {sector,block} pairs
-- when block == nil than the whole sector should be read
local function convert_sectors( s )
	local ar = {}
	local count = 0
	
	if s and #s>0 then
		local e=0
		while e~=nil do 
			local b=e+1
			e=string.find(s,",",b)
			--print("DEBUG: e = " .. (e or "nil"))
			local g=string.sub(s,b,e and e-1 or b+4)
			local sect,block = string.match(g,"^(%d?%d):(%d?%d)$")
			if #block == 0 then block = nil end
			table.insert(ar,{sector=tonumber(sect),block=tonumber(block)})
			logf(LG_DBG,lgid,"Found sector %s, block %s", sect, block or -1 )
			count=count+1
		end
	end

	return ar, count
end


-- return true if the state actually change, false when it stayed the same
local function change_state( mf, new_state )
	local state_strings = { [1]="idle",[2]="will_query_cardinfo",[3]="waiting_for_cardinfo"}
	if mf.state ~= new_state then
		logf(LG_DBG,lgid,"Changing state from '%s' to '%s'", state_strings[mf.state], state_strings[new_state] or "nil")
		mf.state = new_state
		return true
	else
		return false
	end
end


local function send_querycardinfo( mf )

	logf(LG_DMP,lgid,"send_querycardinfo (fd=%d)", mf.fd)
	local result = get_rfid_drv():send_querycardinfo(mf.fd)

	if result < 0 then
		logf(LG_WRN,lgid,"Mifare scanner (temporary?) not operational. (querycardinfo error=%d).", result)
		if mf.state ~= state_will_query_cardinfo then
			evq:push("send_querycardinfo", mf, 10)
			change_state( mf, state_will_query_cardinfo )
		else
		end
	else
		mf.last_send_querycardinfo_time = sys.hirestime()
		change_state( mf, state_waiting_for_cardinfo )
	end

end


local function handle_mifare_data( scanner_rf )

	local result = 0

	local nsector = scanner_rf.last_cardinfo.nsector
	local nblock = scanner_rf.last_cardinfo.nblock
	local blocksize = scanner_rf.last_cardinfo.blocksize
	local cardnum = scanner_rf.last_cardinfo.cardnum
	local cardnumstr = scanner_rf.last_cardinfo.cardnumstr
	local keysize = scanner_rf.last_cardinfo.keysize

	local event_data = { cardnum = cardnum, cardnumstr = cardnumstr, read = {} }

	local spec, count = convert_sectors( config:get("/dev/mifare/relevant_sectors") )
	local error_str
	if count > 0 then
		result = scanner_rf:chkkey( string.sub(config:get("/dev/mifare/key_A"),0,keysize) )
	
		if result == 0 then
			local data = ""
			if #spec>0 and scanner_rf.last_cardinfo.cardtype == "MIFARE_ULTRALIGHT" then
				-- MIFARE ULTRALIGHT requires read ops before read
				get_rfid_drv():readblock(0,0,blocksize)
			end
			for count,sb in ipairs( spec ) do
				if sb.sector>=nsector then
					logf(LG_WRN,lgid,"Error reading sector %d from rfid-card with %d (=0..%d) sectors",sb.sector or -1, nsector, nsector-1) 
					result = -10
					error_str = "Wrong sector index"
				elseif sb.block>=nblock then
					logf(LG_WRN,lgid,"Error reading block %d from rfid-card with %d (=0..%d) blocks per sector",sb.block or -1, nblock, nblock-1)
					result = -10
					error_str = "Wrong block index"
				else
					logf(LG_DBG,lgid,"Reading rfid-card %s, sector %d, block %d", cardnumstr, sb.sector or -1, sb.block or -1)
					data, result, error_str = get_rfid_drv():readblock(sb.sector, sb.block, blocksize)
					if not data then
						logf(LG_WRN,lgid,"rfid-card %s, sector %d, block %d, readblock error: %s", cardnumstr, sb.sector or -1, sb.block or -1, error_str);
						break 
					end
					logf(LG_DBG,lgid,"Sector %d block %d: '%s'", sb.sector, sb.block, data);
					table.insert(event_data.read, {sector=sb.sector, block=sb.block, data=data})
				end
			end
		end
	end
	
	-- handle error codes
	if result == 0 then
		if config:get("/dev/mifare/suppress_beep") == "false" then
			beeper:beep_ok()
		end
	else
		beeper:beep_error()
		if result == -3 or result == -4 or result == -6 then
			event_data.error = config:get("/dev/mifare/msg/access_violation/text")
		elseif result == -2 then
			event_data.error = config:get("/dev/mifare/msg/incomplete_scan/text")
		else 
			event_data.error = "Mifare error: " .. (result or -101) .. "\n" .. (error_str or "")
		end
	end

	evq:push("scan_rf", event_data)
		
	return result
end


local function cardnum2string( cardnum )
	return cardnum:gsub(".", function (c) return string.format("%02x", string.byte(c)); end )
end


--
-- Scanner fd callback, used for both internal and external scanner
--

local function on_fd_scanner(event, scanner_rf)

	if event.data.fd ~= scanner_rf.fd then
		return
	end

	local result, cardnum, cardtype, nsector, nblock, blocksize, keysize = 
			get_rfid_drv():fetch_querycardinfo()

	if scanner_rf.state == state_idle then
		-- ignore this event
		logf(LG_DMP,lgid,"Received mifare event in idle state: ignored")
		return
	end

	if scanner_rf.state ~= state_waiting_for_cardinfo then
		logf(LG_DBG,lgid,"State error (%d) (perhaps crossing events?): corrected", scanner_rf.state)
		change_state( scanner_rf, state_waiting_for_cardinfo )
	end

	if result == 0 then
	
		local cardnumstr = cardnum2string(cardnum)
		logf(LG_DBG, lgid, "card info={nsector=%d, nblock=%d, blocksize=%d, cardnum=%s, keysize=%d", nsector, nblock, blocksize, cardnumstr, keysize )
		
		if	(scanner_rf.last_cardinfo ~= nil and 
				scanner_rf.last_cardinfo.cardnumstr ~= cardnumstr) or
				((scanner_rf.last_cardinfo == nil or 
				sys.hirestime()-scanner_rf.last_send_querycardinfo_time>0.2) and
				sys.hirestime()-scanner_rf.last_cardinfo_time > tonumber(config:get("/dev/mifare/prevent_duplicate_scan_timeout"))) then
			
			local prev_cardinfo = scanner_rf.last_cardinfo
			scanner_rf.last_cardinfo = {
					cardnum = cardnum,
					cardnumstr = cardnumstr,
					cardtype = cardtype,
					nsector = nsector,
					nblock = nblock,
					blocksize =  blocksize,
					keysize = keysize }
			local result = handle_mifare_data( scanner_rf )
			if result < 0 then
				scanner_rf.last_cardinfo = prev_cardinfo
			else
				scanner_rf.last_cardinfo_time = sys.hirestime()
			end

		else
			logf(LG_DMP,lgid, "scanner_rf.on_fd_scanner() cardnum = 0x%s (ignored: duplicate)", cardnumstr)
			scanner_rf.last_cardinfo_time = sys.hirestime()
		end

		if scanner_rf.state == state_waiting_for_cardinfo then
			evq:push("send_querycardinfo", scanner_rf, 1)
			change_state( scanner_rf, state_will_query_cardinfo )
		else
			change_state( scanner_rf, state_idle )
		end

	else

		logf(LG_DMP,lgid, "scanner_rf.on_fd_scanner() fetch_querycardinfo() = %d", result)
		
		-- nothing received so it is ok to reinit a query request immediately
		if scanner_rf.state == state_waiting_for_cardinfo then
			send_querycardinfo( scanner_rf )
		else
			change_state( scanner_rf, state_idle )
		end

	end	

end


local function on_send_querycardinfo( event, scanner_rf )
	logf(LG_DMP,lgid,"on_send_querycardinfo()")
	if scanner_rf.state == state_will_query_cardinfo then
		send_querycardinfo(scanner_rf)
	end
end


-- public function: fetch or query card-info
-- do not store the retrieved info in last_cardinfo!
-- return result-code as defined in mifare.c, cardnumstr, nsect, nblock, blocksize, keysize
local function query_cardinfo( mf )

	local result, nsector, nblock, blocksize, cardnum, keysize
	if scanner_rf.state == state_waiting_for_cardinfo then
		result, cardnum, cardtype, nsector, nblock, blocksize, keysize = 
				get_rfid_drv():fetch_querycardinfo( )
	end
	if cardnum == nil then
		result, cardnum, cardtype, nsector, nblock, blocksize, keysize = 
				get_rfid_drv():querycardinfo( )
		if result ~= 0 then
			logf(LG_WRN, lgid, "Query cardinfo error %d", result)
		end
	end

	if scanner_rf.state == state_waiting_for_cardinfo then
		-- resend the cardinfo request
		send_querycardinfo( scanner_rf )
	end

	if cardnum == nil then
		return result
	else
		return result, cardnum2string(cardnum), cardtype, nsector, nblock, blocksize, keysize
	end
end


-- public function
-- return code as defined in mifare.c
local function chkkey( scanner_rf, keyA )

	if scanner_rf.fd == nil then
		logf(LG_WRN,lgid,"Mifare not available")
		return 1
	end

	logf(LG_DBG,lgid,"Using rf keyA: \"%s\"", keyA)
	local key = keyA:gsub("%x",function (nibble) return string.char(tonumber(nibble,16)) end)
	logf(LG_DBG,lgid,"key: %s", od(key))

	local result = get_rfid_drv():chkkey( key )
	if result ~= 0 then
		logf(LG_INF,lgid,"Mifare chkkey error: %d", result);
	end

	return result
end


-- public function
-- return code as in mifare.c
local function writeblock( scanner_rf, sector, block, data )

	if scanner_rf.fd == nil then
		logf(LG_WRN,lgid,"Mifare not available")
		return 1
	end
	
	local result, error_str = get_rfid_drv():writeblock( sector, block, data )
	if result ~= 0 then
		logf(LG_INF,lgid,"Mifare write-block error \"%s\" for sector %d block %d with data=\"%s\"", error_str or "nil", sector, block, data);
	end
	
	if scanner_rf.state == state_waiting_for_cardinfo then
		-- resend the cardinfo request
		send_querycardinfo( scanner_rf )
	end

	return result
end

-- public function
-- remember: MIFARE_ULTRALIGHT requires a read of secoter0,block0 first!
-- return data, error  -> error code as in mifare.c
local function readblock( scanner_rf, sector, block, blocksize )

	logf(LG_DBG,lgid,"readblock(sector=%d,block=%d,blocksize=%d", sector, block, blocksize)

	if scanner_rf.fd == nil then
		logf(LG_WRN,lgid,"Mifare not available")
		return nil, -1
	end

	local result
	local error_str
	local data

	-- read specific block:
	data, result, error_str = get_rfid_drv():readblock(sector, block, blocksize)
	
	if not data then 
		logf(LG_INF,lgid,"Mifare read-block error on sector %d, block %d, size %d: %s", sector, block, blocksize, error_str);
	else
		logf(LG_DBG,lgid,"Sector %d, block %d with size %d: '%s'", sector, block, blocksize, data);
	end

	if scanner_rf.state == state_waiting_for_cardinfo then
		-- resend the cardinfo request
		send_querycardinfo( scanner_rf )
	end

	return data, result
end


-- public function
local function start_card_detection(mf, delay)
	if mf.state == state_idle or mf.state == state_will_query_cardinfo then
		send_querycardinfo( mf )
	end
end


-- public function
-- return true when card detection was actually stopped, false when it was already stopped
local function stop_card_detection(mf)
	return change_state( mf, state_idle )
end


--
-- Open and configure scanner device
--
local function open(scanner_rf)

	-- has_rfid_hw==nil when hw detection is not done yet
	if has_rfid_hw == false then
		return false
	end
	
	local device = config:get("/dev/mifare/device")
	
	if scanner_rf.fd ~= nil and scanner_rf.device == device then
		-- no need to reopen (also: nlrf_close has a bug (svn 698)!)
		logf(LG_DBG,lgid,"Reusing existing mifare handle")
		return true
	end
	
	scanner_rf:close()
	
	logf(LG_DBG,lgid,"Searching for mifare/rfid hardware")
	local fd = get_rfid_drv():open( device )

	if fd <= 0 then
		has_rfid_hw = false
		logf(LG_DBG,lgid,"Could not open mifare fd on %s.", device)
		return false
	end

	-- store the modeltype in the configuration:
	local modeltype = get_rfid_drv():get_modeltype(fd)
	if modeltype == -2 then
		logf(LG_WRN,lgid,"No rfid HW on %s.", device)
		get_rfid_drv():close(scanner_rf.fd)
		has_rfid_hw = false
		return false
	end

	scanner_rf.device = device
	scanner_rf.fd = fd
	has_rfid_hw = true

	local modeltype = modeltype > 0 and string.format("%d", modeltype ) or "unknown"
	config:lookup("/dev/mifare/modeltype"):setraw( modeltype )

	logf(LG_INF, lgid, "Mifare hardware model V%s found on device %s (fd=%d)", modeltype, scanner_rf.device, scanner_rf.fd)

	scanner_rf.scanbuf = ""
	
	evq:fd_add(scanner_rf.fd)
	evq:register("fd", on_fd_scanner, scanner_rf)

	evq:register("send_querycardinfo", on_send_querycardinfo, scanner_rf)
	evq:push("send_querycardinfo", nil, 5)
	change_state( scanner_rf, state_will_query_cardinfo )

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

		get_rfid_drv():close(scanner_rf.fd)
		scanner_rf.fd = nil
		scanner_rf.device = nil
	end
end


-- 
-- Enable scanning
--
local function enable(scanner_rf)
	--- TODO: ???
	logf(LG_DBG, lgid, "Enabling rfid scanner_rf")
	scanner_rf:open()
end


--
-- Disable scanning
--
local function disable(scanner_rf)
	-- TODO: ???
	logf(LG_DBG, lgid, "Disabling rfid scanner_rf")
	scanner_rf:close()
end

--
-- is hardware available
--
function is_available()

	if has_rfid_hw==nil then
		logf(LG_WRN,lgid,"No mifare hardware detected yet. Assuming not available.")
		return false
	end

	return has_rfid_hw
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
		
		query_cardinfo = query_cardinfo,

		chkkey = chkkey,
		writeblock = writeblock,
		readblock = readblock,
		
		stop_card_detection = stop_card_detection,
		start_card_detection = start_card_detection,

		last_cardinfo = nil,
		last_cardinfo_time = 0,
		last_send_querycardinfo_time = 0,
		
		-- The state variable (see top of file for declarations)
		state = state_idle, 
	}

	if scanner_rf:open() then

		os.execute( "touch /home/ftp/log/mifare.log; chmod 644 /home/ftp/log/mifare.log" )

		config:add_watch("/dev/mifare", "set", function(event, scnnr) scnnr:open() end, scanner_rf)
		evq:register("reinit_scanner", function(event, scnnr) scnnr:open() end, scanner_rf)

		return scanner_rf

	else

		return nil

	end

end

-- vi: ft=lua ts=3 sw=3
	
