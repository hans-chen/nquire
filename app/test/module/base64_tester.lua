#!/usr/bin/lua

-- misc_tester.lua

package.path = "../?.lua;?.lua;module/?.lua"

require "base64"

require "tester"
th = Tester.new()

local function encode_decode( s )
	local c = base64.encode(s)
	local d = base64.decode(c)
	print("'" .. s .. "' =encode=> '" .. c .. "' =decode=> '" .. d .. "'")
end

local function test_encode_decode1()
	encode_decode( "123\002\037\\" )
end

local function test_encode_decode2()
	encode_decode( "<enter/>" )
	encode_decode( "<enter pwd='MySecret'/>" )
	encode_decode( "<exit/>" )
	encode_decode( "<reconnect/>" )
end

th:run( test_encode_decode1, "test_encode_decode1" )
th:run( test_encode_decode2, "test_encode_decode2" )


