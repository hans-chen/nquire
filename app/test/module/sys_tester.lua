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

th:run( test_realtime, "test_realtime" )

