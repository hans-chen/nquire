
--
-- Copyright © 2007. All Rights Reserved.
--


--
--- Run cmd in background
--
-- @param cmd command to execute
-- @param cb_sigchld callback function called when child terminates
-- @param cb_data callback function called when data recevied from child
-- @param opaque object passed to callback functions
-- @return pid of child process

function runbg(cmd, cb_sigchld, cb_data, userdata)

	-- Table with info about child process
	
	local proc = {
		cb_sigchld = cb_sigchld,	-- sigchld callback function
		cb_data = cb_data,			-- data callback function
		pid = nil,						-- PID of child
		fd_parent = nil,				-- parent end fd of pipe
		fd_child = nil,				-- child end fd of pipe
		userdata = userdata,			-- opaque object for callbacks
	}

	-- If data callback is passed, we need to pipe stdout/stderr of child.
	-- if no callback is given, use /dev/null for stdin/stdout/stderr
	
	if cb_data then
		proc.fd_parent, proc.fd_child = sys.pipe()
		if not proc.fd_parent then
			logf(LG_FTL, "misc", "Pipe failed: %s", err)
		end
	else
		proc.fd_parent = nil
		proc.fd_child = sys.open("/dev/null", "w")
	end

	-- Fork child process
	
	local pid, err = sys.fork()
	if not pid then
		logf(LG_FTL, "misc", "Fork failed: %s", err)
	end
	proc.pid = pid

	-- Handle child

	if proc.pid == 0 then

		local fd = sys.open("/dev/null", "rw")
		sys.dup2(fd, 0)
		sys.dup2(proc.fd_child, 1)
		sys.dup2(proc.fd_child, 2)
		for i = 3, 64 do sys.close(i) end

		-- Close all but stdin/stdout/stderr
		
		for i = 3, 64 do sys.close(i) end

		-- Exec new child process

		local rv, err = sys.exec(cmd)
		print("Exec '%q' failed : %s" % { cmd, err })
		os.exit(1)
	end

	-- Handle parent
	
	sys.close(proc.fd_child)

	-- evq handler for proc's fd data
	
	local function on_proc_fd_read(event, proc)
		local fd = event.data.fd
		if fd ~= proc.fd_parent then return end
		local buf, err = sys.read(proc.fd_parent, 1024)
		if buf then
			if #buf > 0 then
				if proc.cb_data then
					proc.cb_data(buf, proc.userdata)
				end
			else
				sys.close(proc.fd_parent)
				evq:fd_del(proc.fd_parent)
				evq:unregister("fd", on_proc_fd_read, proc)
			end
		else
			logf(LG_WRN, "misc", "runbg data callback read error: ", err)
		end
	end

	-- evq handler for proc's sigchld signal

	local function on_proc_signal(event, proc)
		local signum = event.data.signal
		if signum ~= "SIGCHLD" then return end

		local info, err = sys.waitpid(proc.pid)
		if not info then
			logf(LG_WRN, "misc", "waitpid: %s", err)
			return
		end

		if info.ifexited then
			if proc.cb_sigchld then
				proc.cb_sigchld(info.exitstatus, proc.userdata)
			end
			evq:unregister("signal", on_proc_signal, proc)
		end
	end

	if cb_data then
		evq:fd_add(proc.fd_parent, "r")
		evq:register("fd", on_proc_fd_read, proc)
	end

	evq:register("signal", on_proc_signal, proc)

	return proc.pid
end


--
-- Protected call with stack traceback
--

function safecall(fn, ...)

	local arg = {...}

	-- xpcall() does not somehow not support function parameters, so we create a 
	-- wrapper which gets called instead to pass the arguments to the given
	-- function

	local function wrapper()
		return fn(unpack(arg))
	end

	local function errhandler(err)
		local errmsg = debug.traceback("Error: " .. err, 3)
		logf(LG_WRN, "safecall", errmsg)
		return errmsg
	end

	return xpcall(wrapper, errhandler)

end


function ssub( s, start, insertion )
	return s:sub( 1, start-1 ) .. insertion .. s:sub( start+#insertion )
end

-- fetch 2 byte coded little endian number from a string starting at start_pos
-- in: data
--     start_pos
-- return: the value of the fetched little endian coded number
function peek_little_endian_short( data, start_pos )
	local g1, g2 = string.byte( data, start_pos, start_pos+1 )
	return	g1 + g2*0x100;
end

-- set a 2 byte coded little endian number from a byte-array starting at pos
function poke_little_endian_short( data, start_pos, value )
	local v0 = value % 0x100;
	local v1 = (value-v0) / 0x100;
	return ssub( data, start_pos, string.char( v0,v1 ) )
end

-- fetch 4 byte coded little endian number from a string starting at start_pos
-- in: data
--     start_pos
-- return: the value of the fetched little endian coded number
function peek_little_endian_long( data, start_pos )
	local g1, g2, g3, g4 = string.byte( data, start_pos, start_pos+3 )
	return	g1 + g2*0x100 + g3*0x10000 + g4 *0x1000000;
end

-- set a 4 byte coded little endian number from a byte-array starting at pos
function poke_little_endian_long( data, start_pos, value )
	local v0 = value % 0x100;
	local v1 = ((value-v0) / 0x100) % 0x100;
	local v2 = ((value-v0-v1) / 0x10000) % 0x100;
	local v3 = ((value-v0-v1-v2) / 0x1000000) % 0x100;
	return ssub( data, start_pos, string.char( v0,v1,v2,v3 ) )
end

function ifconfig(interface)

	local fd;
	
	fd = io.popen("/sbin/ifconfig " .. interface)
	if fd then
		local conf = {
			interface = nil,
			data = nil,
			inet = nil,
			mask = nil,
			mac = nil
		}
		conf.interface = "eth0"
		conf.data = fd:read("*a")
		conf.inet = { conf.data:match("inet addr:(%d+)%.(%d+)%.(%d+)%.(%d+)") }
		conf.mask = { conf.data:match("Mask:(%d+)%.(%d+)%.(%d+)%.(%d+)") }
		local m1,m2,m3,m4,m5,m6 = conf.data:match("HWaddr (%x+):(%x+):(%x+):(%x+):(%x+):(%x+)")
		conf.mac = { ("0x" .. m1)+0, ("0x" .. m2)+0, ("0x" .. m3)+0, ("0x" .. m4)+0, ("0x" .. m5)+0, ("0x" .. m6)+0 } 
		
		fd:close()
		return conf
	else
		return nil
	end
end

function dump( buf, maxlines )
	local out = ""
	for i=1,#buf do
		if i % 8 == 1 then out = out .. (i-1) .. "\t" end
		out = out .. string.format( "0x%02x ", string.byte( buf, i ) )
		if i % 8 == 0 then 
			if maxlines ~= nil then
				maxlines = maxlines - 1
				if maxlines==0 then 
					return out
				end
			end
			out = out .. "\n"
		end
	end
	return out
end

-- table comparion
-- return: ==0 --> tables are the same, ~=0 --> tables are not the same
function tablecmp( t1, t2 )
	if #t1 ~= #t2 then
		return -1
	end
	for i=1, #t1 do
		if t1[i] ~= t2[i] then
			return -1
		end
	end
	return 0
end


-- vi: ft=lua ts=3 sw=3

