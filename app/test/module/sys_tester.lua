#!/usr/bin/lua

package.path = "../?.lua;?.lua;module/?.lua"
 
require "sys"
require "tester"

th = Tester.new()

local function test_realtime()
	local sec,min,hour,day,month,year = sys.realtime()
	for i=1,1000000 do
		sec,min,hour,day,month,year = sys.realtime()
		--print( year .. "-" .. month .. "-" .. day .. " " .. hour .. ":" .. min .. ":" .. sec )
		if sec>=60 then
			print("error")
		end
	end
end

local function test_get_mac()
	print("Mac eth0 (with if is up) = " .. sys.get_macaddr("eth0"));
	os.execute("sudo ifconfig eth0 down; ifconfig | grep HWaddr");
	print("Mac eth0 (with if is down) = " .. (sys.get_macaddr("eth0") or "nil"));
	os.execute("sudo ifconfig eth0 up");
end

th:run( test_realtime, "test_realtime" )

th:run( test_get_mac, "test_get_mac" )

