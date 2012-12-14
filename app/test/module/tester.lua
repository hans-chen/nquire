
module("Tester", package.seeall)

local function start( th, name )
	print( "\n# *** Start test '" .. name .. "'" )
end

local function run( th, test, name )
	-- TODO: why does info not have a name field?
	local info = debug.getinfo(test,"n")
	local name = (info.name or name or "nil")
	th:start(name)
	test()
end

function new( )
	local t = {
		run = run,
		start = start,
	}
	print( "# *** Running " .. debug.getinfo(2).short_src .. "\n" )
	return t
end


