#!/usr/bin/lua

package.path = "../?.lua;./?.lua;module/?.lua"
 
require "tester"
require "net"

th = Tester.new()

local function test_get_interface_ip()
	local ip, err = net.get_interface_ip("eth0")
	print("ip(eth0)=" .. (ip or "nil") .. ", err=" .. (err or "nil"))
	local ip, err = net.get_interface_ip("none")
	print("ip(none)=" .. (ip or "nil") .. ", err=" .. (err or "nil"))
end

local function test_get_interface_mac()
	local mac, err = net.get_interface_mac("eth0")
	print("mac(eth0)=" .. (mac or "nil") .. ", err=" .. (err or "nil"))
	local mac, err = net.get_interface_mac("wlan0")
	print("mac(wlan0)=" .. (mac or "nil") .. ", err=" .. (err or "nil"))
	local mac, err = net.get_interface_mac("none")
	print("mac(none)=" .. (mac or "nil") .. ", err=" .. (err or "nil"))
end


local function test_gethostbyname()
	local function gethostbyname_report(host)
		local ips, errstr, errnr = net.gethostbyname(host)
		if ips == nil then
			print(host .. "= Error: " .. (errstr or "nil"))
		else
			print(host .. " = ", unpack(ips))
		end
	end
	
	gethostbyname_report( "1" )
	gethostbyname_report( "1.2" )
	gethostbyname_report( "1.2.3" )
	gethostbyname_report( "1.2.3.4" )
	gethostbyname_report( "1.2.3.4.5" )
	gethostbyname_report( "localhost" )
	gethostbyname_report( "www.vdtai.nl" )
	gethostbyname_report( "www.vdtai.nl/index.html" )
	gethostbyname_report( "www.newland-id.nl" )
	gethostbyname_report( "www.unknown42.nl" )
	
end


th:run( test_get_interface_ip, "test_get_interface_ip" )
th:run( test_get_interface_mac, "test_get_interface_mac" )
th:run( test_gethostbyname, "test_gethostbyname_test" )
