--
-- Copyright © 2007 All Rights Reserved.
--

LG_FTL = 1
LG_WRN = 2
LG_INF = 3
LG_EVT = 4
LG_DBG = 5
LG_DMP = 6


local logf_level = LG_INF
local logf_busy = false
local logf_to_syslog = true
local logf_to_stderr = true


local level_info = { 
	[LG_FTL] = { "ftl", "\027[7;31m",  2 },
 	[LG_WRN] = { "wrn", "\027[31m",  4 },
 	[LG_INF] = { "inf", "\027[1m",  5 },
  	[LG_EVT] = { "evt", "\027[1m", 6 },
	[LG_DBG] = { "dbg", "\027[22m", 7 },
 	[LG_DMP] = { "dmp", "\027[1;30m", 7 },
}


function set_loglevel( level )
	logf_level = tonumber(level)
end


function logf_init(level, to_syslog, to_stderr)
	logf_level = tonumber(level)
	logf_to_syslog = to_syslog
	logf_to_stderr = to_stderr
end


function _logf(level, class, file, line, msg)

	if logf_busy then
		if level == LG_FTL then
			os.exit(1)
		end
		return
	end

	if level > logf_level then
		return
	end

	local levelstr = level_info[level][1]
	local levelcolor = level_info[level][2]
	local levelsyslog = level_info[level][3]

	-- Split into separate lines
	
	for msg in string.gmatch(msg, "([^\n]+)") do
	
		-- Fix unprintable chars
		
		msg = msg:gsub("(%c)", function(c) return "<%02x>" % c:byte() end )

		-- Log to console
		
		logf_busy = true
		local sec,min,hour = sys.realtime()
		
		if logf_to_stderr then
			local longmsg = "%-8.8s %4d:%-12.12s: %s" % { class, line, file, msg }
			local isatty = sys.isatty()
			io.write( "%02d:%02d:%06.3f %s[%s] %s%s\n" % {
				hour,min,sec,
				isatty and levelcolor or "", 
				levelstr, 
				longmsg,
				isatty and "\027[0m" or ""
			})
		end
			
		-- Log to syslog

		if logf_to_syslog then
			local longmsg = "%s %s: %s" % { levelstr, class, msg }
			--longmsg = ("%02d:%02d:%06.3f " % { hour,min,sec }) .. longmsg
			sys.syslog(levelsyslog, longmsg)
		end

	end

	-- Push log event for warnings (cannot not: not dependency to evq allowed)
	-- TODO: find out why this was here? It seems to have no function
	--evq:push("log", { level=level, class=class, msg = msg} )
	
	-- Fatal messages abort the application.
	
	if level == LG_FTL then
		error("Fatal error")
	end

	logf_busy = false

end


function logf(level, class, msg, ...)

	msg = msg % {...}

	local line = debug.getinfo(2, "l").currentline or 0
	local file = debug.getinfo(2, "S").source or "??"

	local tmp = string.match(file, "[@\.\/]*(.+)")
	if tmp then file = tmp end

	_logf(level, class, file, line ,msg)

end

-- vi: ft=lua ts=3 sw=3
