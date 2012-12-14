#!/usr/bin/lua

-- misc_tester.lua

package.path = "../?.lua;?.lua;module/?.lua"
 
require "scanner"

require "tester"
th = Tester.new()


local function test_no_duplicate_barcode_prefixes()

	for i,prefix_def_i in ipairs( prefixes ) do
		--print("BC: " .. prefix_def_i.name)
		local from_here = false
		for j,prefix_def_j in ipairs( prefixes ) do
			--print("BC comp: " .. prefix_def_j.name)
			if prefix_def_i.name == prefix_def_j.name then
				from_here = true
			elseif from_here then

				if prefix_def_i.prefix_1d ~= "?" and prefix_def_i.prefix_1d == prefix_def_j.prefix_1d then
					print("ERROR: prefix_1d duplicate for " .. prefix_def_i.name .. " with " .. prefix_def_j.name )
				end
				if prefix_def_i.prefix_2d == prefix_def_j.prefix_2d then
					print("ERROR: prefix_2d duplicate for " .. prefix_def_i.name .. " with " .. prefix_def_j.name )
				end
				if prefix_def_i.prefix_hid == prefix_def_j.prefix_hid then
					print("ERROR: prefix_hid duplicate for " .. prefix_def_i.name .. " with " .. prefix_def_j.name )
				end
				if prefix_def_i.prefix_out == prefix_def_j.prefix_out then
					print("WARNING: prefix_out duplicate for " .. prefix_def_i.name .. " with " .. prefix_def_j.name )
				end
			
			end
		end
	end
	
end

local function test_enable_disable_HR100()

	for i,ed in ipairs( enable_disable_HR100 ) do
		local found = find_prefix_def( ed.name )
		print(ed.name .. " has prefix definition " .. (found and found.prefix_1d or "nil   --  ERROR") )
	end

end

local function test_enable_disable_HR200()

	for i,ed in ipairs( enable_disable_HR200 ) do
		local found = find_prefix_def( ed.name )
		print(ed.name .. " has prefix definition " .. (found and found.prefix_2d or "nil   -- ERROR") )
	end

end

local function test_2d_codes()
	-- just show which codes are 2d: verify output manually

	for i,p in ipairs( prefixes ) do
		if p.layout == "2D" then
			print( p.name .. " = 2D" )
		end
	end

end

th:run( test_no_duplicate_barcode_prefixes, "no_duplicate_barcode_prefixes" )
th:run( test_enable_disable_HR100, "enable_disable_HR100" )
th:run( test_enable_disable_HR200, "enable_disable_HR200" )
th:run( test_2d_codes, "2d_codes" )

