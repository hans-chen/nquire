--
-- Copyright © 2007 All Rights Reserved.
--

module("Led", package.seeall)


local function writesys(fname, data)
	local fd, err = io.open(fname, "w")
	if not fd then
		logf(LG_WRN, "led", "Could not open %s: %s", fname, err)
		return
	end
	fd:write(data)
	fd:close()
end



local function set(led, id, state)

	if id ~= "blue" and id ~= "yellow" then
		logf(LG_WRN, "led", "Unknown led %q", id)
		return
	end

	local path = "/sys/class/leds/led-%s/" % id

	if state == "on" then
		writesys(path .. "trigger", "none")
		writesys(path .. "brightness", "1")
	elseif state == "off" then
		writesys(path .. "trigger", "none")
		writesys(path .. "brightness", "0")
	elseif state == "blink" then
		writesys(path .. "trigger", "timer")
		writesys(path .. "delay_on", "200")
		writesys(path .. "delay_off", "200")
	elseif state == "flash" then
		writesys(path .. "trigger", "timer")
		writesys(path .. "delay_on", "100")
		writesys(path .. "delay_off", "900")
	else
		logf(LG_WRN, "led", "Unknown status %q", state)
	end

end


--
-- Constructor
--

function new()

	local led = {
		-- methods
		set = set
	}

	return led

end

-- vi: ft=lua ts=3 sw=3
	
