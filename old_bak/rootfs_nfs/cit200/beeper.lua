
--
-- Copyright ? 2007 All Rights Reserved.
--


--
--- Beeper device
--
-- Handles beepers through linux console or /dev/dsp
--

module("Beeper", package.seeall)



--
--- Initialize beeper device.
--
-- This function looks up the beeper device from the config file, opens
-- and initialize the device
--
-- @param beeper beeper object

local function init(beeper)
	local device = config:get("/dev/beeper/device")
	logf(LG_DBG, "beeper", "Opening beeper on device %s", device)
	beeper.beepthread, err = beepthread.new(device)
	if not beeper.beepthread then
		logf(LG_WRN, "beeper", "Can't open beeper %s: %s", device, err)
	end
end


--
--- Play a tone on the beeper
--
-- This function parses a 'song string' and plays this on the beeper. The 
-- song string format is similar to the 'play' command in GW-BASIC.

local function play(beeper, song)

	if not beeper.beepthread then
		return
	end

	local note = 0
	local oct = 2
	local deflen = 8
	local tempo = 120

	logf(LG_DMP, "beeper", "Playing %s", song)

	for char, mod, num, dot in string.gmatch(song, "([cdefgabpotdl><])([#\-]?)(%d*)(%.?)") do

		num = tonumber(num) 
		local len = num or deflen
		if dot == '.' then len = len/1.5 end

		local note = string.find("c d ef g a b", char)
		if note then
			if mod == '#' then note = note+1 end
			if mod == '-' then note = note-1 end
			local freq = 110 * math.pow(1.0594630943592953, note + oct*12 + 5)
			beeper.beepthread:beep(freq, (4 * 60 / tempo) / len)
		end

		if char == 'p' then
			beeper.beepthread:beep(0, (4 * 60 / tempo) / len)
		end

		if char == 'o' then oct = num or 3 end
		if char == 't' then tempo = num or 120 end
		if char == 'l' then deflen = num or 16 end
		if char == '<' then oct = oct-1 end
		if char == '>' then oct = oct+1 end
	end
end


--
--- constructor.
--
-- Generates a new beeper object
--

function new()

	local beeper = {
		
		-- data
		beepthread = nil,

		-- methods
		init = init,
		play = play,
	}

	beeper:init()

	config:add_watch("/dev/beeper/device", "set", 
		function(node, beeper)
			if beeper.beepthread then
				beeper.beepthread:free()
			end
			beeper:init()
		end,
		beeper)

	return beeper
end


-- vi: ft=lua ts=3 sw=3

