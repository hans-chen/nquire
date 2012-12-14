

module("Discovery", package.seeall)

local lgid = "discovery"

local discovery_address = "239.255.255.250"
local discovery_port = 19200


local function gen_reply_v1(self, seperator)

	local reply = { }
	
	-- Get some info from the database
	
	-- note that label is a customer interface api, so it should not be changed
	-- without changing the discovery version
	local keys = 
		{ 
			{key="/dev/name", label="Device name"},
			{key="/dev/serial", label="Serial number"},
			{key="/dev/hardware", label="Hardware version"},
			{key="/dev/firmware", label="Firmware version"},
			{key="/dev/version", label="Application version"},
			{key="/dev/build", label="Application build nr"},
			{key="/dev/rfs_version", label="Root file system version"},
			{key="/network/current_ip", label="IP-Address"},
			{key="/network/macaddress", label="MAC-Address"},
			{key="/network/macaddress_eth0", label="MAC-ethernet"},
			{key="/network/macaddress_wlan0", label="MAC-wifi"},
			{key="/dev/scanner/version", label="scanner"},
			{key="/dev/mifare/modeltype", label="mifare-model"},
			{key="/dev/touch16/name", label="touch-pad"},
			{key="/dev/mmcblk", label="micro-sd"}
		}

	for _, kl in ipairs(keys) do
		local val = config:get(kl.key)
		if #val > 0 then
			table.insert(reply, kl.label .. ": " .. val)
		end
	end
		
	local reply = table.concat(reply, seperator)
	logf(LG_DBG,lgid, "Discover Reply=%s", reply)

	return reply
end


local function on_fd_read(event, self)
	
	if event.data.fd ~= self.fd then
		return
	end

	local data, saddr, sport = net.recvfrom(self.fd, 4096)

	if data and data:match("CIT%-DISCOVER%-REQUEST") then
		logf(LG_INF, lgid, "Received CIT-DISCOVER request from %s %s", saddr, sport)
		local version = data:match("Version:%s*(%d+)")
		if version == "1" then
			local reply = "CIT-DISCOVER-RESPONSE\n" .. self:generate_reply("\n")
			local response_port = data:find("RESPONSE%-TO%-SENDER%-PORT") and sport or discovery_port
			local response_addr = data:find("RESPONSE%-TO%-SENDER%-ADDRESS") and saddr or discovery_address
			logf(LG_DBG, lgid, "sending response to %s:%d", response_addr, response_port )
			net.sendto(self.fd, reply, response_addr, response_port)
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
		generate_reply = gen_reply_v1,
	}

	return self
end


-- vi: ft=lua ts=3 sw=3
