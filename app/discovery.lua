

module("Discovery", package.seeall)

local lgid = "discovery"

local discovery_address = "239.255.255.250"
local discovery_port = 19200


local function gen_reply_v1(self)

	local reply = { "CIT-DISCOVER-RESPONSE"}
	
	-- Get some info from the database
	
	local keys = { "/dev/name", "/dev/version", "/dev/build", "/dev/serial" }

	for _, key in ipairs(keys) do
		local val = config:get(key)
		local label = config:lookup(key).label
		table.insert(reply, label .. ": " .. val)
	end

	-- Get current network address
	local convert_to_itf = { ["ethernet"] = "eth0", ["wifi"]="wlan0" }
	local itf = convert_to_itf[config:get("/network/interface")]
	if itf ~= nil then
		local ip, err = net.get_interface_ip( itf )
		if err or not ip then
			logf(lgid,LG_WRN,"%s", (err or "error getting ip"))
		else
			table.insert(reply, "IP-Address: " .. ip)
		end
		
		local mac, err = net.get_interface_mac( itf )
		if err or not mac then
			logf(lgid,LG_WRN,"%s", (err or "error getting mac"))
		else
			table.insert(reply, "MAC-Address: " .. mac)
		end
	end
	local reply = table.concat(reply, "\n")
	logf(LG_DMP,lgid, "Discover Reply=%s", reply)

	return reply
end


local function on_fd_read(event, self)
	
	if event.data.fd ~= self.fd then
		return
	end

	local data, saddr, sport = net.recvfrom(self.fd, 4096)

	if data and data:match("CIT%-DISCOVER%-REQUEST") then
		logf(LG_DBG, lgid, "Received CIT-DISCOVER request from %s", saddr)
		local version = data:match("Version:%s*(%d+)")
		if version == "1" then
			logf(LG_INF, lgid, "Received CIT-DISCOVER request from %s %s", saddr, sport)
			local reply = gen_reply_v1()
			local response_port = data:find("RESPONSE%-TO%-SENDER%-PORT") and sport or discovery_port
			logf(LG_DBG, lgid, "sending response to %s:%d", discovery_address, response_port )
			net.sendto(self.fd, reply, discovery_address, response_port)
		else
			logf(LG_WRN, lgid, "Cannot handle CIT-DISCOVER request from %s with version=%s", saddr, (version or "nil"))
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
