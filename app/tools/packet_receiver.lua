#!/usr/bin/lua

--
-- Copyright © 2007 All Rights Reserved.
--

-- listen to udp port 9000 and print received packet content

require "strict"
require "format"
require "log"
require "evq"
require "sys"
require "net"

logf_init(LG_DBG, true, true)
evq = Evq.new()

local function on_udp( event, sock )
	if event.data.fd ~= sock then return end
	
	local txt, addr, port = net.recvfrom(sock, 1024)
	print("Received UDP from " .. addr .. "." .. port .. ": " .. txt )
	net.sendto( sock, txt, addr, port )
	
end


local sock = net.socket("udp")
net.bind(sock, "0.0.0.0", 9000);
evq:fd_add(sock)
evq:register("fd", on_udp, sock)

while 0 do
	evq:pop(true)
	sys.sleep(0.01)
	for i=0,500000 do end
end

evq:unregister("fd", on_udp)
evq:fd_del(sock)
net.close(sock)
