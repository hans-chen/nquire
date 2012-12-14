--
-- Copyright © 2007 All Rights Reserved.
--

module("Watchdog", package.seeall)


local function on_wdt_timer(event, wdt)
	wdt.fd:write("\n")
	wdt.fd:flush()
	return true
end


local function start(wdt)

	local fd, err = io.open("/dev/watchdog", "w")
	if not fd then
		logf(LG_WRN, "watchdog", "Could not open watchdog device: %s", err)
		return
	end

	wdt.fd = fd

	evq:register("wdt_timer", on_wdt_timer, wdt)
	evq:push("wdt_timer", wdt, 1.0)
end



--
-- Constructor
--

function new()

	local wdt = {

		-- data
		fd = nil,

		-- methods
		start = start,
	}

	return wdt

end

-- vi: ft=lua ts=3 sw=3
	
