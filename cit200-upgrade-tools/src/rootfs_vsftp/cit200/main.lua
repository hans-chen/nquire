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
require "cit"
require "display"
require "beepthread"
require "sys"
require "discovery"
require "upgrade"
require "versioninfo"

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
	if signal == "SIGPIPE" then
		logf(LG_DBG, "main", "SIGPIPE recieved, ignoring")
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

-- Parse cmdline arguments

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

if opt.d then
	sys.daemonize()
end

-- Create event queue

evq = Evq.new()

-- Create configuration object and load config from file

config = Config.new("schema/root.schema", "cit.conf")

local version, build, date = sys.version()
config:lookup("/dev/version"):set(version)
config:lookup("/dev/build"):set(build)
config:lookup("/dev/date"):set(date)

-- Setup logging

if not opt.l or #opt.l == 0 then
	opt.l = LG_INF
end

logf_init(opt.l, true, true)

do
	local serial = sys.get_macaddr("eth0")
	local build, date = sys.version()
	logf(LG_INF, "main", "Validator serial %s build %s %s", serial, build, date)
end

-- Open all peripherals

display = Display.new()

if opt.f then
	for _, family in ipairs(display:list_fonts()) do
		print(family.name)
	end
	os.exit(0)
end

scanner = Scanner.new()

webserver = Webserver:new()
webserver:start()

webui = Webui:new()

beeper = Beeper.new()

-- Setup network unless user requested not to

if opt.n then
	config:set("/network/interface", "off")
end

network = Network:new()

-- Play startup sound

beeper:play(config:get("/dev/beeper/tune_startup"))

-- Start discovery service as soon as network is up
	
discovery = Discovery:new()

evq:register("network_up", function()
	logf(LG_INF, "main", "Network is up, starting discovery service")
	discovery:start()
end)

evq:register("network_down", function()
	logf(LG_INF, "main", "Network is down, stopping discovery service")
	discovery:stop()
end)

-- Start upgrade process

Upgrade:new()
Versioninfo:new()

-- Configure network

network:configure()
network:up()

-- Create validator statemachine and start

cit = CIT.new()
cit:start()

-- Start timer for global usage

evq:register("timer_1hz", function() return true end)
evq:push("timer_1hz", nil, 1.0)

-- Register term signals for ^C

evq:signal_add("SIGINT")
evq:signal_add("SIGTERM")
evq:signal_add("SIGPIPE")
evq:register("signal", on_signal)

-- Initialisation finished, go into main loop

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
