

module("Discovery_sg15", package.seeall)

local lgid="discovery_sg15"

local discovery_port		= 10004

local magic_number		= 0x53544944
local protocol_version  = 0x0002

local MAGIC_IDX					= 1
local PROTOCOL_VERSION_IDX		= 5
local PACKET_TYPE_IDX			= 7
local MAC_IDX					= 9
local INET_IP_IDX				= 25
local ACTIVE_INET_IP_IDX		= 29
local INET_MASK_IDX				= 33
local INET_GATEWAY_IDX			= 37
local MISC_FLAGS_1_IDX			= 41
local FIRMWARE_VERSION_IDX		= 42
local ACTIVE_INTERFACE_IDX		= 57 -- 0=none, 1=eth, 2=wifi
local IDLE_MSG_L1_STR_IDX		= 58
local IDLE_MSG_L2_STR_IDX		= 82
local IDLE_MSG_L3_STR_IDX		= 106
local ERROR_MSG_L1_STR_IDX		= 130
local ERROR_MSG_L2_STR_IDX		= 154
local MISC_FLAGS_2_IDX			= 202
local DEVICE_NAME_IDX			= 204
local SSID_IDX					= 230
local WEP_KEY_IDX				= 262
local MISC_FLAGS_3_IDX			= 278
local SERVER_IP_IDX				= 279
local TCP_PORT_IDX				= 283
local UDP_PORT_IDX				= 285
local TIMEOUTS_IDX				= 287

local code_pages_translation = { 
	["ibm852"]=0, 
	["ibm1252"]=1, 
	["ibm1251"]=2, 
	["ibm866"]=3, 
	["ibm1257"]=4, 
	["ibm874"]=5,
	["ibm1250"]=6,
	["ibm1254"]=7
}


local function get_network_conf()
	if config:get("/network/interface") == "ethernet" then
		conf = ifconfig( "eth0" )
	else
		conf = ifconfig( "wlan0" )
	end
	return conf
end

local function calculate_SG15_align( kind, line_nr )
	local v_align = config:get(string.format("/cit/messages/%s/%d/valign", kind, line_nr))
	local h_align = config:get(string.format("/cit/messages/%s/%d/halign", kind, line_nr))

	local translate_v_align = { ["top"]=9,["middle"]=3,["bottom"]=6 }
	local translate_h_align = { ["left"]=0,["center"]=1,["right"]=2 }

	local SG15_align = translate_v_align[v_align] + translate_h_align[h_align]

	return string.char(SG15_align == 9 and 255 or SG15_align)
end

local function set_msg_line_to_SG15( reply, kind, linenr, offset )
	local idbase = string.format("/cit/messages/%s/%d/", kind, linenr)

	reply = ssub( reply, offset, config:get(idbase .. "text") )
	reply = ssub( reply, offset+20, string.char(config:get(idbase .. "size")=="large" and 1 or 0 ))
	reply = ssub( reply, offset+21, string.char(config:get(idbase .. "xpos") ))
	reply = ssub( reply, offset+22, string.char(config:get(idbase .. "ypos") ))

	local v_align = config:get(idbase .. "valign")
	local h_align = config:get(idbase .. "halign")

	local translate_v_align = { ["top"]=9,["middle"]=3,["bottom"]=6 }
	local translate_h_align = { ["left"]=0,["center"]=1,["right"]=2 }

	local SG15_align = translate_v_align[v_align] + translate_h_align[h_align]

	reply = ssub( reply, offset+23, string.char(SG15_align == 9 and 255 or SG15_align) )

	return reply
end

local function gen_reply_v1(self)

	local reply=string.rep("\0",287);

	-- response packet header
	reply = poke_big_endian_long( reply, MAGIC_IDX, magic_number )
	reply = poke_big_endian_short( reply, PROTOCOL_VERSION_IDX, protocol_version )
	reply = ssub( reply, PACKET_TYPE_IDX, string.char( 0x01 ) )

	-- network settings
	local conf = get_network_conf()
	if conf then
		reply = ssub( reply, INET_IP_IDX, string.char( conf.inet[1],conf.inet[2],conf.inet[3],conf.inet[4] ) )
		reply = ssub( reply, ACTIVE_INET_IP_IDX, string.char( conf.inet[1],conf.inet[2],conf.inet[3],conf.inet[4] ) )
		reply = ssub( reply, INET_MASK_IDX, string.char( conf.mask[1],conf.mask[2],conf.mask[3],conf.mask[4] ) )
		reply = ssub( reply, MAC_IDX, string.char( conf.mac[1],conf.mac[2],conf.mac[3],conf.mac[4],conf.mac[5],conf.mac[6] ) )
	end

	local device_name = config:lookup("/dev/serial"):get()
	local firmware_major, firmware_minor = string.match( config:lookup("/dev/version"):get(), "(%d+).(%d+)" )

	local host = config:get("/cit/resolved_remote_ip")
	local ips, errstr = net.gethostbyname( host )
	if ips==nil then
		logf(LG_WRN,lgid,"Could not resolve host %s: %s", host, errstr)
	else
		-- just use the first ips available 
		-- (most times there will be only one)
		local rip1, rip2, rip3, rip4 = string.match( ips[1], "(%d+).(%d+).(%d+).(%d+)" )
		reply = ssub( reply, SERVER_IP_IDX, string.char( rip1, rip2, rip3, rip4 ) )
	end
	
	-- firmware versions and date ##.##:
	local firmware = string.format( "%02d.%02d", firmware_major+0, firmware_minor+0 )
	reply = ssub( reply, FIRMWARE_VERSION_IDX, firmware:sub(1,5) )
	reply = ssub( reply, DEVICE_NAME_IDX, device_name:sub(1,25) )

	-- interface
	local itf =  config:get("/network/interface")
	reply = ssub( reply, ACTIVE_INTERFACE_IDX, string.char(  itf=="ethernet" and 1 or itf=="wifi" and 2 or 0) )

	reply = ssub( reply, SSID_IDX, config:get("/network/wifi/essid"):sub( 1,32 ) )

	reply = poke_big_endian_short( reply, TCP_PORT_IDX, config:get("/cit/tcp_port")+0 )
	reply = poke_big_endian_short( reply, UDP_PORT_IDX, config:get("/cit/udp_port")+0 )

	-- message lines:
	reply = set_msg_line_to_SG15( reply, "idle", 1, IDLE_MSG_L1_STR_IDX )
	reply = set_msg_line_to_SG15( reply, "idle", 2, IDLE_MSG_L2_STR_IDX )
	reply = set_msg_line_to_SG15( reply, "idle", 3, IDLE_MSG_L3_STR_IDX )
	reply = set_msg_line_to_SG15( reply, "error", 1, ERROR_MSG_L1_STR_IDX )
	reply = set_msg_line_to_SG15( reply, "error", 2, ERROR_MSG_L2_STR_IDX )

	-- Misc. Flags #1
	local beeper_bit = config:get( "/cit/disable_scan_beep" )=="true" and 0x10 or 0
	local dhcp_bit = config:get( "/network/dhcp" )=="true" and 1 or 0
	local misc_flags_1 = beeper_bit + dhcp_bit
	reply = ssub( reply, MISC_FLAGS_1_IDX, string.char( misc_flags_1 ) )

	-- Misc. Flags #2
	local sg15_codepage = code_pages_translation[config:get("/cit/codepage")] or 7
	reply = ssub( reply, MISC_FLAGS_2_IDX, string.char( sg15_codepage*0x20 ) )

	-- Misc. Flags #3
	local connect_mode = 0x80
	local tcp_mode = config:get("/cit/mode")=="server" and 0x40 or 0
	local scanner_string_terminator = 0x08
	local WEB128 = config:get("/network/wifi/keytype")=="WEP" and 0x04 or 0
	local power_saving = cit.power_saving_on and 0x02 or 0
	local misc_flags_3 = connect_mode + tcp_mode + scanner_string_terminator + WEB128 + power_saving
	reply = ssub( reply, MISC_FLAGS_3_IDX, string.char( misc_flags_3 ) )

	-- timeouts
	local idle_msg_timeout = config:get("/cit/messages/idle/timeout")+0
	if idle_msg_timeout>15 then idle_msg_timeout=15 end
	local error_msg_timeout = config:get("/cit/messages/error/timeout")+0
	if error_msg_timeout>15 then erro_msg_timeout=15 end
	reply = ssub( reply, TIMEOUTS_IDX, string.char( error_msg_timeout*0x10 + idle_msg_timeout ) )

	return reply
end

local function get_ip_str( data, pos )
	return string.format( "%d.%d.%d.%d", 
				string.byte( data, pos ), string.byte( data, pos+1 ), 
				string.byte( data, pos+2 ), string.byte( data, pos+3 ) )
end

-- set configuration when item is changed
local function set_conf( id, value )
	local found = value:find( "%z" )
	if found then
		value = value:sub( 1,found-1 )
	end;
	if config:lookup(id):get() ~= value then
		logf(LG_INF, lgid, "Setting %s to %s", id, value)
		config:lookup(id):set(value)
	else
		logf(LG_DBG, lgid, "Skipping %s (%s) <== %s", config:lookup(id):get(), id, value)
	end
end


local function set_msg_line_from_SG15( data, kind, linenr, offset )

	local idbase = string.format("/cit/messages/%s/%d/", kind, linenr)

	set_conf( idbase .. "text", data:sub( offset, offset+19 ) )
	config:set( idbase .. "size", (data:byte( offset+20 )==0 and "small" or "large") )

	local translate_h_align = { [0]="left",[1]="center",[2]="right" }
	local translate_v_align = { [0]="top",[3]="middle",[6]="bottom" }
	local SG15_align = data:byte( offset+23 );
	local h_align = "left"
	local v_align = "top"
	local xpos = data:byte( offset+21 )
	local ypos = data:byte( offset+22 )
	if SG15_align<12 then
		h_align = translate_h_align[SG15_align % 3]
		if SG15_align<9 then
			local i = SG15_align-(SG15_align % 3)
			v_align = translate_v_align[i]
		end
		xpos=0
	end

	config:set( idbase .. "xpos", xpos )
	config:set( idbase .. "ypos", ypos )
	config:set( idbase .. "halign", h_align )
	config:set( idbase .. "valign", v_align )

end

local function bittst( byte, bitnr )
	local bitnrvalue = 2^bitnr
	local result = ((byte - (byte % bitnrvalue))/bitnrvalue) % 2
	return result
end

local function bitand( byte1, byte2 )
	local result = 0
	for i=0,7,1 do 
		local bit1 = bittst( byte1, i )
		local bit2 = bittst( byte2, i )
		if bit1 == 1 and bit2 == 1 then
			result = result + 2^i
		end
	end
	return result
end

local function cit_SG15_configure( data )
	logf(LG_INF, lgid, "cit_SG15_configure( )")

	-- Misc. Flags #1
	local misc_flags_1 = data:byte( MISC_FLAGS_1_IDX )
	logf(LG_DBG,lgid, "misc_flags_1=0x%02x", misc_flags_1)
	config:set( "/cit/disable_scan_beep", bittst( misc_flags_1, 4 )==1 and "true" or "false" )
	local dhcp_flag = bittst( misc_flags_1, 0 )==1
	config:set( "/network/dhcp", dhcp_flag and "true" or "false" )

	-- Misc. Flags #2
	local misc_flags_2 = data:byte( MISC_FLAGS_2_IDX )
	logf(LG_DBG,lgid, "misc_flags_2=0x%02x", misc_flags_2)
	local sg15_codepage = (misc_flags_2 - (misc_flags_2 % 0x20))/0x20
	for code,i in ipairs( code_pages_translation ) do
		if i == sg15_codepage then
			config:set("/cit/codepage", code)
			break
		end
	end

	-- Misc. Flags #3
	local misc_flags_3 = data:byte( MISC_FLAGS_3_IDX )
	logf(LG_DBG,lgid, "misc_flags_3=0x%02x", misc_flags_3)
	config:set("/cit/mode", bittst(misc_flags_3, 6 ) == 1 and "server" or "client" )
	local wep128 = bittst(misc_flags_3, 2 )==1
	config:set("/network/wifi/keytype", wep128 and "WEP" or "off")

	-- network settings
	if not dhcp_flag then
		set_conf( "/network/ip/address", get_ip_str( data, INET_IP_IDX ) )
		set_conf( "/network/ip/netmask", get_ip_str( data, INET_MASK_IDX ) )
		set_conf( "/network/ip/gateway", get_ip_str( data, INET_GATEWAY_IDX ) )
	end

	set_conf( "/cit/remote_ip", get_ip_str( data, SERVER_IP_IDX ) )
	set_conf( "/cit/tcp_port", string.format( "%d", peek_big_endian_short( data, TCP_PORT_IDX ) ) )
	set_conf( "/cit/udp_port", string.format( "%d", peek_big_endian_short( data, UDP_PORT_IDX ) ) )

	set_conf( "/network/wifi/essid", data:sub( SSID_IDX, SSID_IDX+31 ) )
	if wep128 then
		set_conf( "/network/wifi/key", data:sub( WEP_KEY_IDX, WEP_KEY_IDX+12 ) )
	end

	-- messages
	set_msg_line_from_SG15( data, "idle", 1, IDLE_MSG_L1_STR_IDX )
	set_msg_line_from_SG15( data, "idle", 2, IDLE_MSG_L2_STR_IDX )
	set_msg_line_from_SG15( data, "idle", 3, IDLE_MSG_L3_STR_IDX )
	set_msg_line_from_SG15( data, "error", 1, ERROR_MSG_L1_STR_IDX )
	set_msg_line_from_SG15( data, "error", 2, ERROR_MSG_L2_STR_IDX )

	-- timeouts
	local timeouts = data:byte( TIMEOUTS_IDX )
	config:set( "/cit/messages/idle/timeout", timeouts % 0x10 )
	config:set( "/cit/messages/error/timeout", (timeouts-timeouts % 0x10) / 0x10 )

end


local function on_fd_read(event, self)

	if event.data.fd ~= self.fd then
		return
	end

	local data, saddr, sport = net.recvfrom(self.fd, 4096)

	logf(LG_DBG, lgid, "saddr=%s, sport=%d", saddr, sport)
	if data then 
		logf(LG_DBG, lgid, "Received packed (first 8 bytes): %s", dump( data, 1 ) ) 
	end

	if data then
		local my_magic_number = peek_big_endian_long(data, MAGIC_IDX)
		local my_protocol_version = peek_big_endian_short(data, PROTOCOL_VERSION_IDX)
		logf(LG_DBG, lgid, "my_magic_nr = %x, my_protocol_version=%x", my_magic_number, my_protocol_version )

		if my_magic_number == magic_number and my_protocol_version == protocol_version then
			local packet_type = string.byte(data, PACKET_TYPE_IDX);
			if packet_type == 0x00 then
				-- handle discovery packet
				logf(LG_INF, lgid, "Received SG15 discovery packet from %s", saddr)
				local reply = gen_reply_v1()
				local bc_addr = config:get( "/network/discovery/sg15_broadcast_addr" )
				net.sendto(self.fd, reply, bc_addr, sport)
				logf(LG_DBG, lgid, "Send response packet to %s:%d\n%s", bc_addr, discovery_port, dump(reply, 4) )
			elseif packet_type == 0x02 then
				-- only handle configuration packet when the mac-adres is the same as our mac-adres
				local my_mac = get_network_conf().mac
				local mac = {string.byte( string.sub( data, MAC_IDX, MAC_IDX+5 ), 1, 6 )}
				if my_mac[1]==mac[1] and my_mac[2]==mac[2] and my_mac[3]==mac[3] and 
		         my_mac[4]==mac[4] and my_mac[5]==mac[5] and my_mac[6]==mac[6] then
					-- handle configuration packet
					logf(LG_INF, lgid, "Received SG15 configuration packet from %s", saddr)
					cit_SG15_configure( data )
				else
					logf(LG_DBG, lgid, "Received configuration packet but not for me.")
				end
			elseif packet_type == 0x01 then
				-- don't handle response packet (could be from other SG15 shuttles)
			else
				logf(LG_DBG, lgid, "Received unknown SG15 packet type %d from %s", packet_type, saddr)
			end
		end
	end
end



local function start(self)

	if not self.running then

		-- Open multicast UDP socket and add to evq

		local fd = net.socket("udp")
		net.setsockopt(fd, "TCP_NODELAY", 1)
		net.setsockopt(fd, "SO_BROADCAST", 1)
		net.setsockopt(fd, "SO_REUSEADDR", 1)
		local bc_addr = config:get( "/network/discovery/sg15_broadcast_addr" )
		net.setsockopt(fd, "IP_ADD_MEMBERSHIP", bc_addr)
		net.bind(fd, "0.0.0.0", discovery_port)
		self.fd = fd

		evq:fd_add(self.fd)
		evq:register("fd", on_fd_read, self)
		self.running = true
	end
end


local function stop(self)

	if self.running then
		net.close(self.fd)
		evq:fd_del(self.fd)
		evq:unregister("fd", on_fd_read, self)
		self.running = false
	end

end




--
-- Constructor
--

function new()
	
	local self = {
		-- data

		running = false,

		-- methods
		
		start = start,
		stop = stop,
	}

	return self
end


-- vi: ft=lua ts=4 sw=4
