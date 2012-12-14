--
-- Copyright © 2007 All Rights Reserved.
--

-- This module interfaces with the optional mifare hw
-- When a mifare card is scanned it will throw an event:
-- event = scan_rf
--    data.data  => data.data:=all data preformatted in one string || nil
--    data.error => error message, only when data.data==nil

module("Scanner_rf", package.seeall)

require("mifare")

local lgid = "scan_rf"

local mifare_drv = nil
local has_mifare_hw = nil


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


local function get_mifare_drv()
	if mifare_drv == nil then
		mifare_drv = mifare.new()
	end
	return mifare_drv
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
			local sect,colon,block = string.match(g,"^(%d%d?)(:-)([012]-)$")
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

	--print("DEBUG: send_querycardinfo()")
	local result = get_mifare_drv():send_querycardinfo(mf.fd)

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

	local event_data = { cardnum = cardnum, cardnumstr = cardnumstr, read = {} }

	local spec, count = convert_sectors( config:get("/dev/mifare/relevant_sectors") )
	if count > 0 then
		result = scanner_rf:chkkey( config:get("/dev/mifare/key_A") )
	
		if result == 0 then
			local data = ""
			for count,sb in ipairs( spec ) do
				local error_str
				logf(LG_DBG,lgid,"Reading mifare %s, sector %d, block %s", cardnumstr, sb.sector or -1, sb.block and tostring(sb.block) or "all")
				data, result, error_str = get_mifare_drv():readblock(sb.sector, sb.block or nblock, sb.block and blocksize or blocksize*nblock)
				if not data then 
					logf(LG_WRN,lgid,"Mifare Card %s, sector %d, block %s, readblock error: %s", cardnumstr, sb.sector or -1, sb.block and tostring(sb.block) or "all", error_str);
					break 
				end
				logf(LG_DBG,lgid,"Sector %d block %d: '%s'", sb.sector, sb.block or 3, data);
				table.insert(event_data.read, {sector=sb.sector, block=sb.block, data=data})
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
		if result == -3 or result == -4 then
			event_data.error = config:get("/dev/mifare/msg/access_violation/text")
		else
			event_data.error = config:get("/dev/mifare/msg/incomplete_scan/text")
		end
	end

	evq:push("scan_rf", event_data)
		
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
	
		local cardnumstr = string.format("%02x%02x%02x%02x", string.byte(cardnum,1,4) )
		logf(LG_DBG, lgid, "cardnum = 0x%s", cardnumstr)
		
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
	if scanner_rf.state == state_will_query_cardinfo then
		send_querycardinfo(scanner_rf)
	end
end


-- public function
-- return result-code as defined in mifare.c
local function query_cardinfo( mf )

	local result, nsect, nblock, blocksize, cardnum
	if scanner_rf.state == state_waiting_for_cardinfo then
		result, nsect, nblock, blocksize, cardnum = get_mifare_drv():fetch_querycardinfo( )
	end
	if cardnum == nil then
		result, nsect, nblock, blocksize, cardnum = get_mifare_drv():querycardinfo( )
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
		return result, cardnum:gsub("(.)", function (c) return string.format("%2x", c:byte(1)) end )
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

	local result = get_mifare_drv():chkkey( key )
	if result ~= 0 then
		logf(LG_INF,lgid,"Mifare chkkey error: %d", result);
	end

	return result
end


-- public function
-- return code as in mifare.c
local function write_block( scanner_rf, sector, block, data )

	if scanner_rf.fd == nil then
		logf(LG_WRN,lgid,"Mifare not available")
		return 1
	end
	
	local result, error_str = get_mifare_drv():writeblock( sector, block, data )
	if result ~= 0 then
		-- try again
		local blockstr = block and ("block " .. block .. " in ") or ""
		logf(LG_INF,lgid,"Mifare write error \"%s\" for %ssector %d: retry", error_str or "nil", blockstr, sector or -1);
		result, error_str = get_mifare_drv():writeblock( sector, block, data )
		if result ~= 0 then
			logf(LG_WRN,lgid,"Mifare write error \"%s\" for %ssector %d", error_str or "nil", blockstr, sector or -1);
		end
	end
	
	if scanner_rf.state == state_waiting_for_cardinfo then
		-- resend the cardinfo request
		send_querycardinfo( scanner_rf )
	end

	return result
end

-- public function
-- return data, error  -> error code as in mifare.c
local function read_block( scanner_rf, sector, block )

	if scanner_rf.fd == nil then
		logf(LG_WRN,lgid,"Mifare not available")
		return nil, -1
	end

	local nsector = 16 -- scanner_rf.last_cardinfo.nsector
	local nblock = 3 -- scanner_rf.last_cardinfo.nblock
	local blocksize = 16 -- scanner_rf.last_cardinfo.blocksize

	local result
	local error_str
	local data
	
	if block == nil then
		-- read whole sector:
		data, result, error_str = get_mifare_drv():readblock(sector, nblock, blocksize*nblock)
	else
		-- read specific block:
		data, result, error_str = get_mifare_drv():readblock(sector, block, blocksize)
	end
	
	if not data then 
		logf(LG_INF,lgid,"Mifare readblock error on sector %d, block %d: %s", sector, block or 3, error_str);
	else
		logf(LG_DBG,lgid,"Sector %d, block %d: '%s'", sector, block or 3, data);
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

	-- has_mifare_hw==nill when hw detection is not done yet
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

		get_mifare_drv():close(scanner_rf.fd)
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
		
		query_cardinfo = query_cardinfo,

		chkkey = chkkey,
		write_block = write_block,
		read_block = read_block,
		
		stop_card_detection = stop_card_detection,
		start_card_detection = start_card_detection,

		last_cardinfo = nil,
		last_cardinfo_time = 0,
		last_send_querycardinfo_time = 0,
		
		-- The state variable (see top of file for declarations)
		state = state_idle, 
	}

	if scanner_rf:open() then

		os.execute( "touch /mnt/log/mifare.log; chmod 444 /mnt/log/mifare.log" )

		config:add_watch("/dev/mifare", "set", function(event, scnnr) scnnr:open() end, scanner_rf)
		evq:register("reinit_scanner", function(event, scnnr) scnnr:open() end, scanner_rf)

		return scanner_rf

	else

		return nil

	end

end

-- vi: ft=lua ts=3 sw=3
	
