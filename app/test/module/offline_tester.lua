#!/usr/bin/lua

-- offline_tester.lua

package.path = "../?.lua;?.lua;module/?.lua"

require "strict"
require "format"
require "config"
require "log"
require "evq"
require "sys"
require "misc"

require "offline"

require "tester"
th = Tester.new()

logf_init(LG_DMP, true, true)

-- prepare:

local function create_csv(dir)
	local bc_csv = dir .. "barcodes.csv"
	local fmt_csv = dir .. "formats.csv"

	-- create db file:	
	local dbf=io.open(bc_csv,"w")
	dbf:write("# nquire simple offline barcode database csv file\n")
	dbf:write(",format_id,v1,v2,v3\n")
	dbf:write("B1,format1,B1,1\\x2c1\n")
	dbf:write("B,format1,B,1\\x2c1\n")
	dbf:write("B00,format2,B00,1\\x2c1,par3\n")
	dbf:write("C,format2,C,1\\x2c1,par_3\n")
	dbf:write("A,format3\n")
	dbf:close()

	dbf=io.open(fmt_csv,"w")
	dbf:write("# nquire simple offline formats csv file\n")
	dbf:write("format1,v1=${v1}, v2=${v2}\n")
	dbf:write("format2,v1=${v1}, v2=${v2}, v3=${v3}\n")
	dbf:write("format3,Escape code demo: 123=\\x31\\x32\\x33\n")
	dbf:close()
end

local db = nil
local function open_and_import_db()
	os.execute("rm -rf tmp/db")
	db = Offline.new({"tmp"}, "tmp/db")
	db:start()

	-- force loading of import csv files
	evq:push("offline_timer", nil, -1)

	print("db opened: " .. (db.good and "OK" or "NOK"))
end

local function close_db()
	db:stop()
end

local function test_number_of_barcodes()
	create_csv("tmp/")
	open_and_import_db()

	print("number of barcodes=" .. db:get_number_of_barcodes())
	
	close_db()
end

local function test_get_barcode_by_idx()
	create_csv("tmp/")
	open_and_import_db()

	for i=0,5 do 
		print("#" .. i .. "=" .. (db:get_barcode_by_idx(i) or "nil"))
	end

	close_db()
end

local function test_search_barcode_def()
	create_csv("tmp/")
	open_and_import_db()

	for i,bc in ipairs({"A","B","B00","B1","C","none","C","B1","B00","B","A","A1","B01"}) do
		print(bc .. " ==> " .. 
			(db:search_barcode_def(bc,0,db:get_number_of_barcodes()) or "nil") )
	end

	close_db()
end

local function test_offline_get()
	create_csv("tmp/")
	open_and_import_db()

	local function test_offline_get(bc)
		local r = db:get_barcode_response(bc)
		print("bc='" .. bc .. "', response='" .. binstr_to_escapes(r or "<nil>") .. "'")
	end

	test_offline_get("A")
	test_offline_get("B00")
	test_offline_get("B")
	test_offline_get("B1")
	test_offline_get("C")
	test_offline_get("c")
	test_offline_get("deafdeef")

	close_db()
end

-- init environment
evq = Evq.new()
config = Config.new("schema/root.schema", "cit.conf", "cit-ext.conf" )


th:run( test_number_of_barcodes, "test_number_of_barcodes" )
th:run( test_get_barcode_by_idx, "test_get_barcode_by_idx" )
th:run( test_search_barcode_def, "test_search_barcode_def" )
th:run( test_offline_get, "test_offline_get" )
--th:run( test_, "test_" )

