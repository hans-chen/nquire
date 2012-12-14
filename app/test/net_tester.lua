#!/usr/bin/lua

package.path = "../?.lua;./?.lua"
 
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

th:run( test_get_interface_ip, "test_get_interface_ip" )
th:run( test_get_interface_mac, "test_get_interface_mac" )
