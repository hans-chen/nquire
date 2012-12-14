
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


-- vi: ft=lua ts=3 sw=3

