

module("Discovery", package.seeall)


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
	
	local fd = io.popen("/sbin/ifconfig eth0")
	if fd then
		local data = fd:read("*a")
		local addr = data:match("inet addr:(%S+)")
		if addr then
			table.insert(reply, "IP-Address: " .. addr)
		end
		local addr = data:match("HWaddr (%S+)")
		if addr then
			table.insert(reply, "MAC-Address: " .. addr)
		end
		fd:close()
	end

	local reply = table.concat(reply, "\n")
	return reply
end


local function on_fd_read(event, self)
	
	if event.data.fd ~= self.fd then
		return
	end

	local data, saddr, sport = net.recvfrom(self.fd, 4096)

	if data and data:match("CIT%-DISCOVER%-REQUEST") then
		local version = data:match("Version: (%d+)")
		if version == "1" then
			logf(LG_INF, "discovery", "Received CIT-DISCOVER request from %s:%d", saddr, sport)
			local reply = gen_reply_v1()
			net.sendto(self.fd, reply, saddr, sport)
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
		net.setsockopt(fd, "IP_ADD_MEMBERSHIP", "239.255.255.250")
		net.bind(fd, "0.0.0.0", 19200)
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
