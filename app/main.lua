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
require "touch16"
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
require "gpio"

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
	print("usage: nquire [options]")
	print("")
	print("   -d          Daemonize")
	print("   -h          Show this help")
	print("   -l LEVEL    Set log level to LEVEL")
	print("   -n          Don't (re)configure the ethernet network")
	print("   -v          Show version and exit")
	print("   -D          debug mode (some extra debug functions)")
	print()
	print("Create /etc/nowatchdog for starting the device without watchdog")
end

---------------------------------------------------------------------------
-- Main code starts here
---------------------------------------------------------------------------

-- workaround for image bug (required for gprs lock option and peers/gprs file)
os.execute( "mkdir -p /var/lock /etc/ppp/peers" )

-- copy images:
os.execute( "cd /cit200/img/ftp && for f in `ls -1 *gif`; do if ! test -f /mnt/img/$f; then cp $f /mnt/img/; chmod 777 /mnt/img/$f; fi done" )

-- workaround for missing SOL_TCP defintions:

-- very quick failure for testing purposes
--os.execute( "echo 10 > /proc/sys/net/ipv4/tcp_keepalive_time" )
--os.execute( "echo 2 > /proc/sys/net/ipv4/tcp_keepalive_intvl" )
--os.execute( "echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes" )

os.execute( "echo 60 > /proc/sys/net/ipv4/tcp_keepalive_time" )
os.execute( "echo 20 > /proc/sys/net/ipv4/tcp_keepalive_intvl" )
os.execute( "echo 6 > /proc/sys/net/ipv4/tcp_keepalive_probes" )

-- Parse cmdline arguments

opt = getopt( {...} , "Ddhl:np:v")

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

-- Setup logging (depends on nothing)
logf_init(opt.l and #opt.l > 0 and opt.l or LG_INF, true, true)

local mac = sys.get_macaddr("eth0")
if mac == "00:05:f4:11:22:33" then
	logf(LG_WRN,lgid, "Problematical mac-address detected (00:05:f4:11:22:33). Consult the heldpdesk.")
end

-- Create event queue (depends on: log)
evq = Evq.new()

-- Create configuration object and load config from file (depends on: log, evq)
config = Config.new("schema/root.schema", "cit.conf")

-- and register changes in loglevel here (and not in log.lua itself),
-- because logging can not depend on config:
config:add_watch("/cit/loglevel", "set", function () 
		set_loglevel( tonumber(config:get("/cit/loglevel") ) ) end )
if not opt.l or #opt.l == 0 then
	set_loglevel( config:get("/cit/loglevel") )
end

-- beeper, this creates a seperate process using fork, so it should be opened 
-- BEFORE display, otherwise excesive memory is used by dpydrv
-- (depends on: config, log)
beeper = Beeper.new()

-- read /etc/cit.ini (depends on: log, config)
versioninfo = Versioninfo.new()
versioninfo:init()

-- initialize display (depends on: log, evq, config)
display = Display.new()

-- log hw and version info

local mac_eth0 = sys.get_macaddr("eth0")
logf(LG_INF, lgid, "Ethernet mac %s", mac_eth0)

local mac_wlan0 = sys.get_macaddr("wlan0")
if mac_wlan0 and mac_wlan0 ~= "??:??:??:??:??:??" then 
	logf(LG_INF, lgid, "Wifi mac %s", mac_wlan0) 
end

local serial = config:get("/dev/serial")
logf(LG_INF, lgid, "Device serial nr: %s", config:get("/dev/serial") )
logf(LG_INF, lgid, "Root filesystem version: %s", config:get("/dev/rfs_version") )
logf(LG_INF, lgid, "Firmware version: %s", config:get("/dev/firmware") )

local version, build, date = sys.version()
logf(LG_INF, lgid, "Application version: %s, build %s, %s", version, build, date)

-- set read-only items in configuration
config:lookup("/dev/version"):setraw(version)
config:lookup("/dev/build"):setraw(build)
config:lookup("/dev/date"):setraw(date)

-- Open all peripherals

logf(LG_INF,lgid,"Open all periferals")

led = Led.new()
led:set("blue", "off")
led:set("yellow", "off")

-- gpio access class:
gpio = Gpio.new()
gpio:open()

-- turn on periferal power:
logf(LG_INF,lgid,"Turn on periferal power")
if not gpio:set_pin(18, 1) then
	logf(LG_WRN,lgid,"Error turning on periferal power. Scanner possibly not operational")
end
sys.sleep(1)

-- Setup network
network = Network.new()

-- create scanner
scanner = Scanner_2d.new()
if not scanner then
	-- so we assume it is a 1d scanner
	scanner = Scanner_1d.new()
	if not scanner then
		logf(LG_FTL,lgid,"No scanner device detected")
	end
end
-- innitialisation in event queue
evq:push("reinit_scanner",nil,2)

-- Create optional devices (will become nil when device is not found)

-- TODO: HW detection does not always work
scanner_rf = Scanner_rf.new()

-- stdin devices:
keyboard = Touch16.new()
if keyboard then
	keyboard:open()
end

-- scanner_hid is used in keyboard emulation mode 
scanner_hid = Scanner_hid.new()
scanner_hid:open()

webserver = Webserver.new()
webserver:start()

-- Create web interface CGI
webui = Webui.new( )

-- Play startup sound
beeper:play(config:get("/dev/beeper/tune_startup"))

-- Start discovery service as soon as network is up
discovery = Discovery.new()
discovery_sg15 = Discovery_sg15.new()

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
Upgrade.new(nil,nil,"cit.conf")

-- Configure network

network:configure()
network:up()

-- Create cit statemachine and start

cit = CIT.new()
cit:start()

-- Register term signals for ^C

evq:signal_add("SIGINT")
evq:signal_add("SIGTERM")
evq:signal_add("SIGPIPE")
evq:register("signal", on_signal)

-- do not start the watchdog when /etc/nowatchdog exists
-- Note: this is only meant to be used for debug-purposes!
local fd = io.open("/etc/nowatchdog", "r")
if fd then
	fd:close()
	logf(LG_WRN,lgid,"/etc/nowatchdog found: Not starting watchdog.")
else
	-- Create watchdog interface
	logf(LG_INF,lgid,"Start watchdog")
	watchdog = Watchdog.new()
	watchdog:start()
end	

-- Initialisation finished, go into main loop.
logf(LG_INF, lgid, "Starting main event loop")

while running do
	safecall( evq.pop, evq, true )
end

-- Cleanup

beeper:play(config:get("/dev/beeper/tune_shutdown"))
webserver:stop()
if keyboard then keyboard:close() end
scanner:close(true)
if scanner_rf then scanner_rf:close(true) end
display:close()
led:set("blue", "off")
led:set("yellow", "off")

logf(LG_INF, lgid, "Done, bye bye")

-- vi: ft=lua ts=3 sw=3
--
