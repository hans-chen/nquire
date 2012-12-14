#!/usr/bin/lua

-- generate_example_dbs.lua

package.path = "../?.lua;?.lua"

require "math"
require "strict"
require "format"

local function trunk( x )
	return x - (x%1)
end

local function record_gt( a, b )
	local ka = a:match("^\"?(.-)\"?,")
	local kb = b:match("^\"?(.-)\"?,")
	return ka<kb
end

-- records = { [i] = value, ... }
local function create_csv(dir, tablename, collumns, n, special_records, random, ordered)
	local csv = dir .. "/" .. tablename .. ".csv"

	os.execute("mkdir -p " .. dir)

	-- make table
	local records = {}
	for i=1,n do
		if special_records[i] then
			table.insert(records,special_records[i])
		else
			local x = random and trunk(math.random() * n * 100) or i
			table.insert(records,"A"..x..",f"..(x%11))
		end
	end			

	if ordered then
		table.sort(records, record_gt)
	end

	-- create db file:	
	local f=io.open(csv,"w")
	f:write("# table " .. tablename .. " with " .. n .. (random and " random" or " ordered") ..  " content\n")
	f:write(collumns .. "\n")
	for i=1,n do
		f:write(records[i] .. "\n")
	end			
	f:close()
end


-- create a small random db import for testing
create_csv("tmp", "formats", "format,response", 4, 
	{
		[1]=[[format1,\x1b\x42\x30\x1b\x25\x1b\x2e\x30barcode=${barcode}\nformat=${format}\ncode=${code}\x03]],
		[2]=[["format2","\x1b\x42\x30\x1b\x25\x1b\x2e\x30This is nice!!!\nbarcode=${barcode}\nformat=${format}\ncode=${code}\x03"]],
		[3]=[[format4,"\x1b\x25f4:format=${format},\nbc=""${barcode}""\x03"]],
		[4]=[[format3,"\x1b\x25f3:format=${format},\nbc=""${barcode}""\x03"]],
	}, true, true)
create_csv("tmp", "barcodes", "barcode,format,code", 10, 
	{
		[1]="5985618834859457,format1,CODE 11",
		[3]="1359629856213,format1,ITF 14",
		[9]="45612348973,format2,CODE 128",
	}, true, true)
os.execute("cd tmp && zip offlinedb.zip barcodes.csv formats.csv")
os.execute("cd tmp && mv offlinedb.zip offlinedb-small-`md5sum offlinedb.zip | cut -f1 -d\\  `.zip")

-- and create a big db (not ordered) import for testing
create_csv("tmp", "barcodes", "barcode,format,code", 50000, 
	{
		[1]="5985618834859457,format1,CODE 11",
		[10000]="1359629856213,format2,ITF 14",
		[12000]="Newland,format4,CODE 93",
		[50000]="45612348973,format3,CODE 128",
	}, true)
os.execute("cd tmp && zip offlinedb.zip barcodes.csv formats.csv")
os.execute("cd tmp && mv offlinedb.zip offlinedb-big-`md5sum offlinedb.zip | cut -f1 -d\\  `.zip")

-- and create a big db ordered import for testing
create_csv("tmp", "barcodes", "barcode,format,code", 50000, 
	{
		[1]="5985618834859457,format1,CODE 11",
		[10000]="1359629856213,format1,ITF 14",
		[12000]="45612348973,format2,CODE 128",
		[50000]="Newland,format4,CODE 93",
	}, true, true)
os.execute("cd tmp && zip offlinedb.zip barcodes.csv formats.csv")
os.execute("cd tmp && mv offlinedb.zip offlinedb-big_ordered-`md5sum offlinedb.zip | cut -f1 -d\\  `.zip")

