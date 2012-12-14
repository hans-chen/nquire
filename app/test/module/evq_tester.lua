#!/usr/bin/lua

package.path = "../?.lua;./?.lua;module/?.lua"
 
require "strict"
require "format"
require "log"
require "sys"
require "evq"

require "tester"
th = Tester.new()

local function dump_evq( q )
	local cq=0
	for _,_ in pairs(q.queue) do cq=cq+1 end
	print("#q.queue=" .. cq)
	
	local ch=0
	for type,handler in pairs(q.handler_list) do 
		ch=ch+1 
		for i,h in pairs(handler) do
			print("handler_list[" .. type .. "].type=" .. type)
		end
	end
	print("#q.handler_list=" .. ch)

	local cf=0
	for _,_ in pairs(q.fd_list) do cf=cf+1 end
	print("#q.fd_list=" .. cf)
end


local eq = Evq:new()

local function test_push_pop()

	dump_evq( eq )
	eq:push( "bla" )
	dump_evq( eq )
	eq:pop()
	dump_evq( eq )

	eq:push( "bla" )
	eq:push( "bla" )
	dump_evq( eq )
	eq:pop()
	dump_evq( eq )
	eq:pop()
	dump_evq( eq )

end

local function test_un_register()

	local function myeventhandler()
		print("Handled event")
	end

	dump_evq( eq )

	eq:register("bla",myeventhandler)
	dump_evq( eq )
	eq:unregister("bla",myeventhandler)
	dump_evq( eq )

	eq:register("bla",myeventhandler)
	dump_evq( eq )

	eq:register("blabla",myeventhandler)
	dump_evq( eq )
	eq:unregister("bla",myeventhandler)
	dump_evq( eq )
	eq:unregister("blabla",myeventhandler)
	dump_evq( eq )

end


th:run( test_push_pop, "test_push_pop" )
th:run( test_un_register, "test_un_register" )


