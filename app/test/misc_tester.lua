#!/usr/bin/lua

-- misc_tester.lua

package.path = "../?.lua;?.lua"
 
require "misc"
require "sys"

require "tester"
th = Tester.new()


local function test_binstr_to_escapes()

	local function tst( s, low, high, extra  )
		local t = binstr_to_escapes(s, low, high, extra)
		print("dump(s)=" .. dump(s) .. ": binstr_to_escapes(s)='" .. t  .. "'")
		if s ~= escapes_to_binstr(t, extra) then
			print("translate back fails")
		end
	end
	
	tst( "\031\032\127\128" )
	tst( "\047\048\063\064", 48,64 )
	tst( "\"",nil,nil, "\"" )
	tst( "\a" )
	tst( "\b" )
	tst( "\c" )
 	tst( "\e" )
	tst( "\f" )
	tst( "\n" )
 	tst( "\r" )
 	tst( "\t" )
 	tst( "\v" )
	tst( "\\" )
	tst( "\\\\Q" )
	tst( "\\\\" )
	tst( "\\\n" )
	tst( "a\nb" )
	tst( "n\\xm" )
	tst( "n\\x1m" )
	tst( "n\\x12m" )
	tst( "\\x" )
	tst( "\\x1" )
	tst( "\\x12" )
	

	-- and a real life translation
	tst( "text=\"bla\"", nil,nil,"\"" )
	
end

local function test_escapes_to_binstr()

	local function tst( s, extra )
		local t = escapes_to_binstr(s, extra)
		print("s='" .. s .. "': dump(escapes_to_binstr(s))=" .. dump(t) )
		if s ~= binstr_to_escapes( t, extra ) then
			print("translate back fails")
		end
	end

	tst( "\\xn" )
	tst( "\\xan" )
	tst( "\\x18n" )
	tst( "\\a" )
	tst( "\\b" )
	tst( "\\c" )
 	tst( "\\e" )
	tst( "\\f" )
	tst( "\\n" )
 	tst( "\\r" )
 	tst( "\\t" )
 	tst( "\\v" )
	tst( "\\" )
	tst( "\\\\" )
	tst( "\\\\\\n" )
	tst( "a\\nb" )

end

local function test_fetch_value()

	local function tst( s, is_string )
		local v,r = fetch_value(s, is_string)
		print((is_string and "String: " or "") .. 
				"s='" .. s .. "', v='" .. v .. "', r='" .. (r or "nil") .. "'")
	end
	
	tst( "abc" )
	tst( "abc def", true )
	tst( "abc def", false )

	tst( "\"abc def\"", true )
	tst( "abc \"def\"", true )
	tst( " abc \"def\"", true )
	
	-- and a few real life test strings:
	tst( "1 ; /a = bla" )
	tst( " \" abc def \" ; /b = 42 ", true )

end

local function test_find_file()
	local function tst( file, pwd )
		print( "Search '" .. file .. "' in '" .. (pwd or "") .. "': " .. (find_file( file, pwd ) or "nil"))
	end
	tst( "Makefile" )
	tst( "Makefile", "img" )
	tst( "Makefile", "img:." )
	tst( "Makefile", ".:img" )
	tst( "anim1.gif", "img" )
	tst( "anim1.gif", ".:img" )
	tst( "anim1.gif", "nonexistdir:img:." )
	tst( "anim1.gif", "img:." )
	
	tst( "nonexist" )
	tst( "anim1.gif", ".:verified" )
	tst( "anim1.gif", ".:nonexistdir" )
end

th:run( test_binstr_to_escapes, "test_binstr_to_escapes" )
th:run( test_escapes_to_binstr, "test_escapes_to_binstr" )
th:run( test_fetch_value, "test_fetch_value" )
th:run( test_find_file, "test_find_file" )
