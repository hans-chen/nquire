#!/usr/bin/lua

-- simpledb_tester.lua

package.path = "../?.lua;?.lua;module/?.lua"

require "math"
require "strict"
require "format"
require "config"
require "log"
require "sys"
require "misc"

require "simpledb"

require "tester"
th = Tester.new()

logf_init(LG_DMP, true, true)

-- prepare:

local function trunk( x )
	return x - (x%1)
end

-- records = { [i] = value, ... }
local function create_csv(dir, table, collumns, n, records, random)
	local csv = dir .. "/" .. table .. ".csv"

	os.execute("mkdir -p " .. dir)

	-- create db file:	
	local f=io.open(csv,"w")

	f:write("# table " .. table .. " with " .. n .. (random and " random" or " ordered") ..  " content\n")
	f:write(collumns .. "\n")
	for i=1,n do
		if records[i] then
			f:write(records[i] .. "\n")
		else
			local x = random and trunk(math.random() * n * 100) or i
			f:write("A"..x..",f"..(x%11).."\n")
		end
	end			
	f:close()
end

local function call_offline_import_csv( dir, tables )
	os.execute( "mkdir -p " .. dir )
	os.execute( "offline_import_csv  " .. dir .. " " .. tables )
end


-- init environment

local function test_import_and_find()

	local dir = "tmp/db"
	local import_dir = "tmp/import"
	os.execute("rm -rf " .. dir .. " " .. import_dir)
	create_csv( import_dir, "t1", "bc,fm", 10, {[1]="abc,f10",[4]="000,first",[7]="zzz,last"}, true )
	create_csv( import_dir, "t2", "fm,out", 10, {[2]="abc,f10",[5]="000,first",[9]="zzz,last"}, true )
	call_offline_import_csv( dir, import_dir .. "/t1.csv " .. import_dir .. "/t2.csv" )

	local db = Simpledb.new( dir, { t1={}, t2={} } )
	db:open()

	for _,t in ipairs({"t1","t2"}) do
		for _,k in ipairs({"abc","000","zzz","none"}) do
			local f = db:find_record( t, k )

			print( "find(" .. t .. ","..k..")=" )
			if f then
				for i,v in pairs(f) do
					print("    ["..i.."]='"..v.."'")
				end
			else
				print(" NOT FOUND")
			end
		end
	end

	db:close()

end

local function test_write_read_table()

	local dir = "tmp/db"
	os.execute("rm -rf " .. dir)

	local db = Simpledb.new( dir, {} )
	db:open()

	db:write_table("address","www.vdtai.nl - +31 6 27535295")
	print("'" .. db:read_table("address") .. "'")

	db:close()
end


logf_init(4, false, true)

th:run( test_import_and_find, "test_import_and_find" )
th:run( test_write_read_table, "test_write_read_table" )


os.execute("rm tmp/offlinedb-*.zip; cp formats.csv tmp")
-- and create a small db import for testing
create_csv("tmp", "barcodes", "barcode,format,code", 10, 
	{
		[1]="5985618834859457,format1,CODE 11",
		[3]="1359629856213,format1,ITF 14",
		[9]="45612348973,format2,CODE 128",
	}, true)
os.execute("cd tmp && zip offlinedb.zip barcodes.csv formats.csv")
os.execute("cd tmp && cp offlinedb.zip offlinedb-`md5sum offlinedb.zip | cut -f1 -d\\  `.zip")

-- and create a big db import for testing
create_csv("tmp", "barcodes", "barcode,format,code", 50000, 
	{
		[1]="5985618834859457,format1,CODE 11",
		[3]="1359629856213,format1,ITF 14",
		[9]="45612348973,format2,CODE 128",
	}, true)
os.execute("cd tmp && zip offlinedb.zip barcodes.csv formats.csv")
os.execute("cd tmp && cp offlinedb.zip offlinedb-`md5sum offlinedb.zip | cut -f1 -d\\  `.zip")

