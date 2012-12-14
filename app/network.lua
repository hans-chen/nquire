--
-- Copyright © 2007 All Rights Reserved.
--

module("Network", package.seeall)

--
-- Open a file, or die with a fatal error message when failed
--

local function open_or_die(fname, mode)
	local fd,err = io.open(fname, mode)
	if not fd then
		logf(LG_WRN, "network", "Could not open file '%s': %s", fname, err)
		return io.open("/dev/null", mode)
	end
	return fd
end


--
-- Generate configuration files for ethernet
--

local function configure_ethernet(network)

	logf(LG_DBG, "network", "Configuring Ethernet connection")

	-- /etc/network/interfaces part
	
	local fd = open_or_die(network.fname_interfaces, "a")
	fd:write("auto eth0\n")

	local dhcp = config:get("/network/dhcp")

	if dhcp == "true" then
		fd:write("iface eth0 inet dhcp\n")
		fd:write("  vendor NQuire200\n")
	else
		fd:write("iface eth0 inet static\n")
		fd:write("  address " .. config:get("/network/ip/address") .. "\n")
		fd:write("  netmask " .. config:get("/network/ip/netmask") .. "\n")
		fd:write("  gateway " .. config:get("/network/ip/gateway") .. "\n")
	end
	fd:write("  pre-up killall udhcpc; true\n")
	fd:write("\n")
	fd:close()

	-- resolv.conf
	
	if dhcp == "false" then
		local fd = open_or_die(network.fname_resolv_conf, "w")
		fd:write("nameserver " .. config:get("/network/ip/ns1") .. "\n")
		fd:write("nameserver " .. config:get("/network/ip/ns2") .. "\n")
		fd:close()
	end

end


--
-- Generate configuration files for wifi
--

local function configure_wifi(network)

	logf(LG_DBG, "network", "Configuring wifi connection")
	
	local dhcp = config:get("/network/dhcp")
	local key = config:get("/network/wifi/key")
	local keytype = config:get("/network/wifi/keytype")
	local essid = config:get("/network/wifi/essid")

	-- Create wpa_supplicant.conf in /tmp
	
	local fd = open_or_die("/tmp/wpa_supplicant.conf", "w")

	fd:write("network={\n")
	fd:write("	ssid=\"%s\"\n" % essid)
	fd:write("	scan_ssid=1\n")

	if keytype == "off" then
		fd:write("	key_mgmt=NONE\n")
	elseif keytype == "WEP" then
		fd:write("	key_mgmt=NONE\n")
		fd:write("	wep_key0=%s\n" % key)
		fd:write("	wep_tx_keyidx=0\n")
	elseif keytype == "WPA / WPA2" then
		fd:write("	key_mgmt=WPA-PSK\n")
		fd:write("	psk=\"%s\"\n" % key)
	end
	fd:write("}\n")
	fd:close()


	-- /etc/network/interfaces part. The double setting of the SSID is 
	-- a workaround for the rt73 not associating right away. The wonders of
	-- wifi :(
	
	local fd = open_or_die(network.fname_interfaces, "a")
	
	if dhcp == "true" then
		fd:write("iface wlan0 inet dhcp\n")
	else
		fd:write("iface wlan0 inet static\n")
		fd:write("  address " .. config:get("/network/ip/address") .. "\n")
		fd:write("  netmask " .. config:get("/network/ip/netmask") .. "\n")
		fd:write("  gateway " .. config:get("/network/ip/gateway") .. "\n")
	end
	fd:write("  pre-up killall udhcpc; true\n")
	fd:write("  pre-up killall wpa_supplicant; true\n")
	fd:write("  pre-up wpa_supplicant -B -iwlan0 -c/tmp/wpa_supplicant.conf\n")
	fd:write("  pre-down killall wpa_supplicant; true\n")

	fd:write("\n")
	fd:close()

	-- resolv.conf
	
	if dhcp == "false" then
		local fd = open_or_die(network.fname_resolv_conf, "w")
		fd:write("nameserver " .. config:get("/network/ip/ns1") .. "\n")
		fd:write("nameserver " .. config:get("/network/ip/ns2") .. "\n")
		fd:close()
	end

end


--
-- Generate configuration files for GPRS network
--

local function configure_gprs(network)
	
	logf(LG_DBG, "network", "Configuring GPRS connection")

	
	-- /etc/interfaces section
	
	local fd = open_or_die(network.fname_interfaces, "a")
	fd:write(string.format([[
iface gprs inet ppp
  pre-up echo -en "\nAT+CPIN=%04d\n" > %s
  provider gprs

]],tonumber(config:get("/network/gprs/pin")),
	config:get("/dev/modem/device")))
	fd:close()

	-- PPPD peer options file
	
	local fd = open_or_die(network.fname_peer, "w")
	fd:write(string.format([[
user %s
%s %s
connect %s
disconnect %s
crtscts 
lock
updetach
hide-password
defaultroute
usepeerdns
holdoff 3
ipcp-accept-local
lcp-echo-failure 8
lcp-echo-interval 3
noauth
noipdefault
novj
novjccomp
nodeflate
nobsdcomp
replacedefaultroute
persist
lcp-echo-interval 3
lcp-echo-failure 12
	]], 
	config:get("/network/gprs/username"),
	config:get("/dev/modem/device"),
	config:get("/dev/modem/baudrate"),
	network.fname_chat_connect,
	network.fname_chat_disconnect))
	fd:close()

	-- Connect script

	local fd = open_or_die(network.fname_chat_connect, "w")
	fd:write(string.format([[
#!/bin/sh -e
exec chat -v\
        ABORT BUSY\
        ABORT DELAYED\
        ABORT "NO ANSWER"\
        ABORT "NO DIALTONE"\
        ABORT VOICE\
        ABORT ERROR\
        ABORT RINGING\
        TIMEOUT 3\
        "" ATZ\
        OK-\\k\\k\\k\\d+++ATH-OK ATE1\
        TIMEOUT 30\
        OK AT+CGDCONT=1,\"IP\",\"%s\",,0,0\
        OK ATD%s\
        CONNECT \d\c
	]], 
	config:get("/network/gprs/apn"),
	config:get("/network/gprs/number")))
	fd:close()
	os.execute("chmod +x " .. network.fname_chat_connect)

	-- Disconnect script

	local fd = open_or_die(network.fname_chat_disconnect, "w")
	fd:write([[
#!/bin/sh -e
/usr/sbin/chat -v\
	ABORT OK\
	ABORT BUSY\
	ABORT DELAYED\
	ABORT "NO ANSWER"\
	ABORT "NO CARRIER"\
	ABORT "NO DIALTONE"\
	ABORT VOICE\
	ABORT ERROR\
	ABORT RINGING\
	TIMEOUT 12\
	"" \\k\\k\\k\\d+++ATH\
	"NO CARRIER-AT-OK" ""
	]])
	fd:close()
	os.execute("chmod +x " .. network.fname_chat_disconnect)

	-- Chap secrets

	local fd = open_or_die(network.fname_chap_secrets, "w")
	fd:write(string.format("%s \"\" %s\n",
		config:get("/network/gprs/username"),
		config:get("/network/gprs/password")
	))
	fd:close()

end



-- 
-- Configure network by writing out various network configuration files
--

local function configure(network)

	local interface = config:get("/network/interface") 

	if interface ~= "off" then
		logf(LG_INF, "network", "Configuring network interface %q", interface)
		
		local fd = open_or_die(network.fname_interfaces, "w")
		fd:write("# Auto-generated by validator application, do not edit\n")
		fd:write("\n")
		fd:write("auto lo\n")
		fd:write("iface lo inet loopback\n")
		fd:write("\n")
		fd:close()

		configure_ethernet(network)
		--configure_gprs(network)
		configure_wifi(network)
	else
		logf(LG_INF, "network", "Not configuring network")
		evq:push("network_up")
		--led:set("blue", "on")
		network.is_up = true
	end
end

-- return true for carrier up
local function get_carrier_status()
	-- TODO: is this ok or should I close this file somehow?
	return io.input ( "/sys/class/net/eth0/carrier" ):read(1) == "1";
end

--
-- Bring up network
--
local network_is_initialized = false
local function up(network)

	-- Don't update network configuration if we're running from NFS
	logf(LG_DMP, "network", "upping network" )
	network_is_initialized = false

	local mounts = io.open("/proc/mounts"):read("*a")
	if mounts:match("root / nfs") then
		logf(LG_WRN, "network", "Root filesystem is on NFS, not configuring network")
		return
	end

	local interface = config:get("/network/interface")

	local cmd = "ifdown -f wlan0; ifdown -f eth0; "

	if interface == "ethernet" then
		cmd = cmd .. "ifup -f eth0"
	else
		cmd = cmd .. "ifup -f wlan0"
	end
		
	logf(LG_INF, "network", "Bringing up network %s interface", interface)

	logf(LG_DMP, "network", "Running %q", cmd)
	runbg(cmd, 
		function(status)
			if status ~= 0 then
				logf(LG_WRN, "network", "An error occured configuring the network")
			else
				network_is_initialized = true
			end
		end,
		function(data)
			logf(LG_DMP, "network", "ifup> %s", data)
			network_is_initialized = true
		end)

	evq:push("network_down")
	--led:set("blue", "flash")
	network.is_up = false
end


local function get_macaddress(node)
	local serial = sys.get_macaddr("eth0")
	node:setraw(serial)
end


local function get_current_ip_addr()
	local fd = io.popen("/sbin/ifconfig")
	local ipaddr = nil
	if fd then
		local tmp = fd:read("*a")
		local tmp = tmp:match("inet addr:(%S+)")
		if tmp then
			ipaddr = tmp
		end
		fd:close()
	end
	return ipaddr
end


local function get_current_ip(node)
	local ipaddr = get_current_ip_addr()
	if ipaddr then
		node:setraw(ipaddr)
	else
		node:setraw("?")
	end
end


-- TODO: implement an event based solution
local led_status = "off"
local carrier_status = false
local function on_check_network_status_timer( network )
	local new_led_status = "flash"
	local current_carrier_status = get_carrier_status()

	if network_is_initialized then
		local interface = config:get("/network/interface")
		if interface == "ethernet" and current_carrier_status == true or interface ~= "ethernet" then 
			if get_current_ip_addr() then
				new_led_status = "on"
			end
		end

	end
	if carrier_status and current_carrier_status == false then
		if config:get("/network/interface") == "ethernet" then
			logf(LG_WRN, "network", "Network error: carrier lost")
		end
	end
	carrier_status = current_carrier_status

	if new_led_status ~= led_status then
		led_status = new_led_status;
		led:set("blue", led_status)
		if led_status == "on" then
			logf(LG_INF,"network","Network is up")
			network.is_up = true
			evq:push("network_up")
		else
			logf(LG_INF,"network","Network is down")
		end
	end

	return true;
end

--
-- Constructor
--

function new()

	local network = {

		-- data
		fname_resolv_conf     = "/etc/resolv.conf",
		fname_interfaces      = "/etc/network/interfaces",
		fname_peer            = "/etc/ppp/peers/gprs",
		fname_chat_connect    = "/etc/ppp/gprs-connect-chat",
		fname_chat_disconnect = "/etc/ppp/gprs-disconnect-chat",
		fname_chap_secrets    = "/etc/ppp/chap-secrets",
		is_up = false,

		-- methods
		configure = configure,
		up = up,
	}
	
	evq:signal_add("SIGCHLD")

	local function	reconfigure(node, network) 
		print("Reconfiguring network")
		network:configure()
		network:up()
	end

	config:add_watch("/network/macaddress", "get", get_macaddress, network)
	config:add_watch("/network/current_ip", "get", get_current_ip, network)
	config:add_watch("/network", "set", reconfigure, network)
	config:add_watch("/dev/modem", "set", reconfigure, network)

	evq:register("check_network_status_timer", on_check_network_status_timer)
	evq:push("check_network_status_timer", network, 5.0)

	return network
end
	

-- vi: ft=lua ts=3 sw=3 
