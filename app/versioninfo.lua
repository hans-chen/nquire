--
-- Copyright © 2007 All Rights Reserved.
--

module("Versioninfo", package.seeall)



local path_ini_file = "/etc/cit.ini"


local function get_ini_key(fname, get_section, get_key)

	local fd, err = io.open(fname, "r")
	if not fd then
		logf(LG_WRN, "versioninfo", "Could not read file %s: %s", fname, err)
		return
	end

	local section = ""
	for l in fd:lines() do
		local tmp = l:match("%[(.-)%]") 
		if tmp then section = tmp end
		local key, val = l:match("(%S+)%s*=%s*(.+)")
		if key and val then
			if get_section == section and get_key == key then
				fd:close()
				return val
			end
		end
	end

	fd:close()
end


local function set_ini_key(fname, set_section, set_key, set_value)

	local fd_in, err = io.open(fname, "r")
	if not fd_in then
		logf(LG_WRN, "versioninfo", "Could not read file %s: %s", fname, err)
		return
	end
	
	local fd_out, err = io.open(fname .. ".tmp", "w")
	if not fd_out then
		fd_in:close()
		logf(LG_WRN, "versioninfo", "Could not write file %s: %s", fname, err)
		return
	end

	local section = ""
	for l in fd_in:lines() do
		local tmp = l:match("%[(.-)%]") 
		if tmp then 
			section = tmp 
			fd_out:write("\n[" .. section .. "]\n")
		end
		local key, val = l:match("(%S+)%s*=%s*(.+)")
		if key and val then
			if set_section == section and set_key == key then
				print("*** updating")
				fd_out:write("\t" .. set_key .. " = " .. set_value .. "\n")
			else
				fd_out:write(l .. "\n")
			end
		end
	end

	fd_out:write("\n")
	fd_in:close()
	fd_out:close()

	local ok, err = os.rename(fname .. ".tmp", fname)
	if not ok then
		logf(LG_WRN, "versioninfo", "Could not rename ini file: %s", err)
	end
end


--
-- Pre-get handler: read rfs version from ini file
--

local function on_get_rfs_version(node)
	local serial = get_ini_key(path_ini_file, "version", "rootfs")
	if serial then
		node:setraw(serial)
	else
		node:setraw("unknown")
	end
end

--
-- Pre-get handler: read serial from ini file
--

local function on_get_serial(node)
	local serial = get_ini_key(path_ini_file, "serial number", "sn")
	if serial then
		node:setraw(serial)
	else
		node:setraw("unknown")
	end
end

--
-- Post-set handler: write serial to ini file
--

local function on_set_serial(node)
	local serial = node:get()
	print("****** ON SET SERIAL", serial)
	set_ini_key(path_ini_file, "serial number", "sn", serial)
end


--
-- Constructor
--

local function init(versioninfo)

	-- Read serial number and rfs version from ini file
	
	local serial = get_ini_key(path_ini_file, "serial number", "sn")
	local rfs_version = get_ini_key(path_ini_file, "version", "rootfs")
	local firmware_version = get_ini_key(path_ini_file, "version", "firmware")
	local hardware_version = get_ini_key(path_ini_file, "version", "hardware")

	-- Store in db
	
	config:lookup("/dev/serial"):setraw(serial)
	config:lookup("/dev/rfs_version"):setraw(rfs_version)
	config:lookup("/dev/firmware"):setraw(firmware_version)
	config:lookup("/dev/hardware"):setraw(hardware_version)

	-- 'set' watch on db for setting device serial number

	config:add_watch("/dev/serial", "set", on_set_serial)

end
	
function new()
	local self = {
		init = init
	}
	return self
end

-- vi: ft=lua ts=3 sw=3 
