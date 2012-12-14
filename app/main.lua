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
require "scanner_1d"
require "scanner_2d"
require "scanner_rf"
require "scanner_hid"
require "cit"
require "display"
require "beepthread"
require "sys"
require "discovery"
require "discovery_sg15"
require "upgrade"
require "versioninfo"
require "led"
require "watchdog"

---------------------------------------------------------------------------
-- Some event callback functions
---------------------------------------------------------------------------

local running = true

local lgid = "main"

--
-- 'signal' event hander
-- 

local function on_signal(event)
	local signal = event.data.signal
	if signal == "SIGINT" or signal == "SIGTERM" then
		logf(LG_INF, lgid, "Received signal %s, exiting", signal)
		running = false
	end
	if signal == "SIGPIPE" then
		logf(LG_DBG, lgid, "SIGPIPE recieved, ignoring")
	end
end


--
-- Usage
--

local function usage()
	print("usage: validator [options]")
	print("")
	print("   -d          Daemonize")
	print("   -h          Show this help")
	print("   -l LEVEL    Set log level to LEVEL")
	print("   -n          Don't (re)configure the ethernet network")
	print("   -w          Don't start the watchdog")
	print("   -v          Show version and exit")
end

---------------------------------------------------------------------------
-- Main code starts here
---------------------------------------------------------------------------

-- workaround for image bug (required for gprs lock option and peers/gprs file)
os.execute( "mkdir -p /var/lock /etc/ppp/peers" )

-- Parse cmdline arguments

opt = getopt( {...} , "wdhl:np:v") 

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
	print("NQuire build %s" % build )
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
	local mac = sys.get_macaddr("eth0")
	local f_serial = io.popen("cit_sn -r | grep Serial | cut -d: -f2")
	local serial = f_serial:read()
	f_serial:close()
	local version, build, date = sys.version()
	logf(LG_INF, lgid, "Using mac %s, serial %s, version %s, build %s, %s", (mac or "nil"), (serial or "nil"), (version or "nil"), (build or "nil"), (date or "nil"))
end

local mac = sys.get_macaddr("eth0")
if mac == "00:05:f4:11:22:33" then
	logf(LG_WRN,lgid, "Problematical mac-address detected (00:05:f4:11:22:33). Contact the heldpdesk.")
end

-- Open all peripherals

logf(LG_INF,lgid,"Open all periferals")

led = Led:new()
led:set("blue", "off")
led:set("yellow", "off")

display = Display.new()

-- turn on periferal power:
logf(LG_INF,lgid,"Turn on periferal power")
local ok, err = sys.gpio_set(18, 1)
sys.sleep(1)
if not ok then
	logf(LG_WRN,lgid,"Error turning on periferal power. Scanner possibly not operational")
end

if Scanner_1d:is_available() then
	scanner = Scanner_1d:new()
elseif Scanner_2d:is_available() then
	scanner = Scanner_2d:new()
else
	logf(LG_ERR,lgid,"Unknown barcode scanner type.")
end

Scanner_hid:new()

if Scanner_rf:is_available() then
	scanner_rf = Scanner_rf:new()
end

-- Create web server 

webserver = Webserver:new()
webserver:start()

-- Create web interface CGI

webui = Webui:new( )

beeper = Beeper.new()

-- Setup network
network = Network:new()

-- Play startup sound

beeper:play(config:get("/dev/beeper/tune_startup"))

-- Start discovery service as soon as network is up
discovery = Discovery:new()
discovery_sg15 = Discovery_sg15:new()

evq:register("network_up", function()
	logf(LG_INF, lgid, "Starting discovery service")
	discovery:start()
	discovery_sg15:start()
end)

evq:register("network_down", function()
	logf(LG_INF, lgid, "Stopping discovery service")
	discovery:stop()
	discovery_sg15:stop()
end)

-- Start upgrade process
logf(LG_INF,lgid,"Start upgrade service")

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

-- Initialisation finished, go into main loop.

logf(LG_INF, lgid, "Starting main event loop")

-- option -w: don't start watchdog
if not opt.w then
	-- Create watchdog interface
	logf(LG_INF,lgid,"Start watchdog")
	watchdog = Watchdog:new()
	watchdog:start()
end

while running do
	evq:pop(true)
end

-- Cleanup

beeper:play(config:get("/dev/beeper/tune_shutdown"))
scanner:close()
if Scanner_rf.is_available() and scanner_rf then
	scanner_rf:close()
end
display:clear()
display:update()
display:close()
led:set("blue", "off")
led:set("yellow", "off")

logf(LG_INF, lgid, "Done, bye bye")

-- vi: ft=lua ts=3 sw=3
--
