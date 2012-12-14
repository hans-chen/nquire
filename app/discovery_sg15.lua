

module("Discovery_sg15", package.seeall)


local discovery_address = "239.255.255.250"
local discovery_port = 10004

local magic_number = 0x53544944
local protocol_version = 0x0002

local MAGIC_IDX = 1
local PROTOCOL_VERSION_IDX = 5
local PACKET_TYPE_IDX = 7

local MAC_IDX = 9
local INET_IP_IDX = 25
local INET_MASK_IDX = 33
local INET_GATEWAY_IDX = 37
local FIRMWARE_VERSION_IDX = 42


local function get_network_conf()
	if config:get("/network/interface") == "ethernet" then
		conf = ifconfig( "eth0" )
	else
		conf = ifconfig( "wlan0" )
	end
	return conf
end

local function gen_reply_v1(self)

	local reply=string.rep("\0",228);

	-- response packet header
	reply = poke_little_endian_long( reply, MAGIC_IDX, magic_number )
	reply = poke_little_endian_short( reply, PROTOCOL_VERSION_IDX, protocol_version )
	reply = ssub( reply, PACKET_TYPE_IDX, string.char( 0x01 ) )

	-- network settings
	local conf = get_network_conf()
	if conf then
		reply = ssub( reply, INET_IP_IDX, string.char( conf.inet[1],conf.inet[2],conf.inet[3],conf.inet[4] ) )
		reply = ssub( reply, INET_MASK_IDX, string.char( conf.mask[1],conf.mask[2],conf.mask[3],conf.mask[4] ) )
		reply = ssub( reply, MAC_IDX, string.char( conf.mac[1],conf.mac[2],conf.mac[3],conf.mac[4],conf.mac[5],conf.mac[6] ) )
	end

	-- firmware versions and date:
	local serial = config:lookup("/dev/serial"):get()
	reply = ssub( reply, FIRMWARE_VERSION_IDX, serial )
	
	return reply
end

local function get_ip_str( data, pos )
	return string.format( "%d.%d.%d.%d", 
				string.byte( data, pos ), string.byte( data, pos+1 ), 
		      string.byte( data, pos+2 ), string.byte( data, pos+3 ) )
end

-- set configuration when item is changed
local function set_conf( id, value )
	if config:lookup(id):get() ~= value then
		logf(LG_INF, "discovery", "Setting %s to %s", id, value)
		config:lookup(id):set(value)
	else
		logf(LG_DBG, "discovery", "Skipping %s (%s) <== %s", config:lookup(id):get(), id, value)
	end
end


local function cit_SG15_configure( data )
	logf(LG_INF, "discovery", "SG15 configuration: only ip address, ip netmask and ip gateway implemented")

	-- TODO: or should the ip date be checked against the ifconfig data?
	set_conf( "/network/ip/address", get_ip_str( data, INET_IP_IDX ) )
	set_conf( "/network/ip/netmask", get_ip_str( data, INET_MASK_IDX ) )
	set_conf( "/network/ip/gateway", get_ip_str( data, INET_GATEWAY_IDX ) )

end

local function on_fd_read(event, self)

	if event.data.fd ~= self.fd then
		return
	end

	local data, saddr, sport = net.recvfrom(self.fd, 4096)

	logf(LG_DMP, "discovery", "saddr=%s, sport=%d", saddr, sport)
	if data then 
		logf(LG_DMP, "discovery", "Received packed (first 8 bytes): " .. dump( data, 1 ) ) 
	end

	if data and peek_little_endian_long(data, MAGIC_IDX) == magic_number and
					peek_little_endian_short(data, PROTOCOL_VERSION_IDX) == protocol_version then
		local packet_type = string.byte(data, PACKET_TYPE_IDX);
		if packet_type == 0x00 then
			-- handle discovery packet
			logf(LG_INF, "discovery", "Received SG15 discovery packet from %s", saddr)
			local reply = gen_reply_v1()
			net.sendto(self.fd, reply, discovery_address, discovery_port)
			logf(LG_DBG, "discovery", "Send response packet to %s:%d\n%s", discovery_address, discovery_port, dump(reply, 4) )
		elseif packet_type == 0x02 then
			-- only handle configuration packet when the mac-adres is the same as our mac-adres
			local my_mac = get_network_conf().mac
			local mac = {string.byte( string.sub( data, MAC_IDX, MAC_IDX+5 ), 1, 6 )}
			if my_mac[1]==mac[1] and my_mac[2]==mac[2] and my_mac[3]==mac[3] and 
            my_mac[4]==mac[4] and my_mac[5]==mac[5] and my_mac[6]==mac[6] then
				-- handle configuration packet
				logf(LG_INF, "discovery", "Received SG15 configuration packet from %s", saddr)
				cit_SG15_configure( data )
			else
				logf(LG_DBG, "discovery", "Received configuration packet but not for me.")
			end
		elseif packet_type == 0x01 then
			-- don't handle response packet (could be from other SG15 shuttles)
		else
			logf(LG_DMP, "discovery", "Received unknown SG15 packet type %d from %s", packet_type, saddr)
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
		net.setsockopt(fd, "IP_ADD_MEMBERSHIP", discovery_address)
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


-- vi: ft=lua ts=3 sw=3
