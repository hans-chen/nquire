#!/usr/bin/lua

--
-- Copyright © 2007 All Rights Reserved.
--

require "strict"
require "getopt"
require "format"
require "log"
require "config"
require "base64"
require "evq"
require "webserver"
require "misc"
require "webui"
require "network"
require "net"
require "beeper"
require "scanner"
require "sg15"
require "display"
require "beepthread"
require "sys"

---------------------------------------------------------------------------
-- Some event callback functions
---------------------------------------------------------------------------

local running = true

--
-- 'signal' event hander
-- 

local function on_signal(event)
	local signal = event.data.signal
	if signal == "SIGINT" or signal == "SIGTERM" then
		logf(LG_INF, "main", "Received signal %s, exiting", signal)
		running = false
	end
end


--
-- Usage
--

local function usage()
	print("usage: validator [options]")
	print("")
	print("   -d          Daemonize")
	print("   -f          Lists all available fonts and exits")
	print("   -h          Show this help")
	print("   -l LEVEL    Set log level to LEVEL")
	print("   -n          Don't (re)configure the network")
	print("   -v          Show version and exit")
end

---------------------------------------------------------------------------
-- Main code starts here
---------------------------------------------------------------------------
-- parameter for process 
NL_PROCESS_Y = 110
NL_PROCESS_H =  10
-- Parse cmdline arguments
sys.system("process 10 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
local opt = getopt( {...} , "dfhl:np:v") 

if not opt then
	usage()
	os.exit(1)
end

if opt.h then
	usage()
	os.exit(0)
end

if opt.v then
	local build = sys.version()
	print("Validator build %s" % build )
	os.exit(0)
end

-- Daemonize if requested
sys.system("process 20 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
if opt.d then
	sys.daemonize()
end

-- Create event queue
sys.system("process 30 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
evq = Evq.new()
evq:signal_add("SIGINT")
evq:signal_add("SIGTERM")
evq:register("signal", on_signal)

-- Create configuration object and load config from file
sys.system("process 40 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
config = Config.new("schema/root.schema", "cit.conf")
	
config:add_watch("/dev/version", "get", function(node)
	local version, build, data = sys.version()
	node:set(build)
end)


-- Setup logging
sys.system("process 50 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
if not opt.l or #opt.l == 0 then
	opt.l = LG_INF
end

logf_init(opt.l, 
	opt.d and true or false, 
	opt.d and false or true)

do
	local serial = sys.get_macaddr("eth0")
	local build, date = sys.version()
	logf(LG_INF, "main", "Validator serial %s build %s %s", serial, build, date)
end

-- Open all peripherals

-- display = Display.new()

if opt.f then
	for _, family in ipairs(display:list_fonts()) do
		print(family.name)
	end
	os.exit(0)
end
sys.system("process 60 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
scanner = Scanner.new()
webserver = Webserver:new()
webserver:start()

webui = Webui:new()

beeper = Beeper.new()

-- Setup network unless user requested not to

sys.system("process 70 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
if opt.n then
	config:set("/network/interface", "off")
end

network = Network:new()

-- Play startup sound

sys.system("process 80 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
beeper:play(config:get("/dev/beeper/tune_startup"))

-- Configure network
sys.system("process 85 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
network:configure()
network:up()

-- Create validator statemachine and start
sys.system("process 90 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
display = Display.new()
sg15 = SG15.new()
sg15:start()


-- Start timer for global usage
sys.system("process 95 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
evq:register("timer_1hz", function() return true end)
evq:push("timer_1hz", nil, 1.0)

-- Initialisation finished, go into main loop
sys.system("process 100 " .. NL_PROCESS_Y .." " .. NL_PROCESS_H)
logf(LG_INF, "main", "Starting main event loop")

while running do
	evq:pop(true)
end

-- Cleanup

beeper:play(config:get("/dev/beeper/tune_shutdown"))
scanner:close()
display:clear("txtimg")
display:update()
display:close()

logf(LG_INF, "main", "Done, bye bye")

-- vi: ft=lua ts=3 sw=3
--
