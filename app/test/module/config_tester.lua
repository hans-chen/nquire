#!/usr/bin/lua

package.path = "../?.lua;./?.lua;module/?.lua"
 
require "strict"
require "getopt"
require "format"
require "log"
require "config"
require "base64"
require "evq"
require "config_node"
require "sys"
require "misc"
require "upgrade-stub"

require "tester"
th = Tester.new()

os.execute( "rm config_tester.conf" )

logf_init(LG_INF, true, true)
--logf_init(LG_DMP, true, true)
evq = Evq.new()

local function test1()
	local config = Config.new("module/config_tester.schema", "config_tester.conf" )

	local function tst( s, ... )
		th:start("config:set_config_item('" .. s .. "')")

		print("Before:")
		for i,item in ipairs({...}) do
			print(item .. " = \"" .. config:get(item) .. "\"")
		end
		config:set_config_item(s)
		print("After:")
		for i,item in ipairs({...}) do
			print(item .. " = \"" .. config:get(item) .. "\"")
		end
	end

	tst( "/group1/number1 = 3", "/group1/number1")
	tst( "/group1/enum1 = \"three\"", "/group1/enum1" )
	tst( "/group1/enum1 = \"one\" ; /group1/string1 = \"blabla\"", "/group1/enum1", "/group1/string1" )
	tst( "/group1/enum1 = \"two\" /group1/string1 = \"blat\"", "/group1/enum1", "/group1/string1") 
	tst( "/group1/string1 = \"a\\bc\"", "/group1/string1")
	tst( "/group1/string1 = \"\\xabq\"", "/group1/string1")
	tst( "/group1/string1 = \"\\xaq\"", "/group1/string1")
	tst( '/group1/string1 = "a\\"b"', "/group1/string1")
	tst( "/group1/string1 = \"\\n\"", "/group1/string1")

	th:start("save_db")

	config:save_db( "config_tester.conf1" )

	-- and print the new configfile contents for verification
	print("Configfile:")
	local fd = io.open("config_tester.conf1", "r")
	local txt = fd:read("*all")
	fd:close()
	print(txt)

	local function on_group1_string1(node, data)
		print("on_group1_string1, data=" .. data .. ", value=" .. node:get())
	end

	config:add_watch("/group1/string1", "set", on_group1_string1,"mydata")

	print("before set: bla")
	config:set( "/group1/string1", "blabla" )
	print("after set, now pop:")
	for i=1,14 do
	evq:pop(true)
	end

	print("before set: direct")
	config:set( "/group1/string1", "direct", true )
	print("after set")
	evq:pop()
	evq:pop()
end


local function test2()

	-- now a real-life test:
	os.execute("ln -s ../schema .")
	os.execute("rm -f cit.conf")

	-- first time should create a new file with default settings
	local config1 = Config.new("schema/root.schema", "cit.conf" )
	-- and again should load from cit.conf
	local config1 = Config.new("schema/root.schema", "cit.conf" )

	print("/dev/mifare/key_A = " .. config1:get("/dev/mifare/key_A"))
	print("/dev/mifare/relevant_sectors = " .. config1:get("/dev/mifare/relevant_sectors"))

	local node = config1:lookup("/dev/mifare/relevant_sectors")
	local function tst( r )
		print("range(\"" .. r .. "\") = " .. (node.range( r ) and "true" or "false"))
	end
	tst("1")
	tst("0")
	tst("15")
	tst("16")
	tst("0,15")
	tst("0,16")
	tst("0:0")
	tst("15:2")
	tst("0:3")
	tst("15:3")
	tst("16:0")

	tst("0:0,0:1,0:2")
	tst("15:0,15:1,15:2")
	
end

test1()
test2()
