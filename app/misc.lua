
--
-- Copyright © 2007. All Rights Reserved.
--

local lgid = "misc"

--
--- Run cmd in background
--
-- @param cmd         command to execute
-- @param cb_sigchld  callback function called when child terminates
-- @param cb_data     callback function called when data recevied from child
-- @param userdata    opaque object passed to callback functions
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
			logf(LG_FTL, lgid, "Pipe failed: %s", err)
		end
	else
		proc.fd_parent = nil
		proc.fd_child = sys.open("/dev/null", "w")
	end

	-- Fork child process
	
	local pid, err = sys.fork()
	if not pid then
		logf(LG_FTL, lgid, "Fork failed: %s", err)
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
			logf(LG_WRN, lgid, "runbg data callback read error: ", err)
		end
	end

	-- evq handler for proc's sigchld signal

	local function on_proc_signal(event, proc)
		local signum = event.data.signal
		if signum ~= "SIGCHLD" then return end

		local info, err = sys.waitpid(proc.pid)
		if not info then
			logf(LG_WRN, lgid, "waitpid: %s", err)
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

-- fetch 2 byte coded little endian number from a string starting at start_pos
-- in: data
--     start_pos
-- return: the value of the fetched little endian coded number
function peek_big_endian_short( data, start_pos )
	local g1, g2 = string.byte( data, start_pos, start_pos+1 )
	return	g2 + g1*0x100;
end

-- set a 2 byte coded little endian number from a byte-array starting at pos
function poke_big_endian_short( data, start_pos, value )
	local v0 = value % 0x100;
	local v1 = (value-v0) / 0x100;
	return ssub( data, start_pos, string.char( v1, v0 ) )
end

-- fetch 4 byte coded little endian number from a string starting at start_pos
-- in: data
--     start_pos
-- return: the value of the fetched little endian coded number
function peek_big_endian_long( data, start_pos )
	local g3, g2, g1, g0 = string.byte( data, start_pos, start_pos+3 )
	return	g0 + g1*0x100 + g2*0x10000 + g3 *0x1000000;
end

-- set a 4 byte coded little endian number from a byte-array starting at pos
function poke_big_endian_long( data, start_pos, value )
	local v0 = value % 0x100;
	local v1 = ((value-v0) / 0x100) % 0x100;
	local v2 = ((value-v0-v1) / 0x10000) % 0x100;
	local v3 = ((value-v0-v1-v2) / 0x1000000) % 0x100;
	return ssub( data, start_pos, string.char( v3,v2,v1,v0 ) )
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
		conf.interface = interface
		conf.data = fd:read("*a")
		conf.inet = { conf.data:match("inet addr:(%d+)%.(%d+)%.(%d+)%.(%d+)") }
		conf.mask = { conf.data:match("Mask:(%d+)%.(%d+)%.(%d+)%.(%d+)") }
		local m1,m2,m3,m4,m5,m6 = conf.data:match("HWaddr (%x+):(%x+):(%x+):(%x+):(%x+):(%x+)")
		conf.mac = { 
				m1 and tonumber(m1, 16) or nil,
				m2 and tonumber(m2, 16) or nil,
				m3 and tonumber(m3, 16) or nil,
				m4 and tonumber(m4, 16) or nil,
				m5 and tonumber(m5, 16) or nil,
				m6 and tonumber(m6, 16) or nil }
		
		fd:close()
		return conf
	else
		return nil
	end
end

function dump( buf, maxlines )
	local out = ""
	local txt = ""
	local cpl = 16
	for i=1,#buf do
		if i % cpl == 1 then out = out .. string.format("%05d  ",(i-1)) end
		local c = buf:sub(i,i)
		local b = c:byte()
		out = out .. string.format( "%02x ", b )
		txt = txt .. ((b<32 or b>=128) and "." or c)
		if i==#buf then
			return out .. "    " .. txt
		elseif i % cpl == 0 then 
			out = out .. "    " .. txt .. "\n"
			if maxlines ~= nil then
				maxlines = maxlines - 1
				if maxlines==0 then 
					return out
				end
			end
			txt = ""
		end
	end
	return out
end

function od( txt )
	return txt:gsub( ".", function(c) return string.format("%02x ", c:byte()) end )
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

function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

-- Change all non printable charracters in a string to hex escape codes
-- The '\' charracter is always escaped as '\\' (and is not translated to \xnn)
-- All 'extra' charracters are also escaped, just like the '\' charracter.
-- binstr_to_escapes('a"c',nil,nil,'"')  ==> "a\"c"
-- Extra is meant to be used for escaping quote's but can be any charracter.
-- But: do not use 'n' or 'x' for extra because these have a special 
-- meaning when translating back: '\n'=new line and '\xnn' represents the 
-- charracter with asci-value nn hexadecimal.
-- @param txt - the text to be translated
-- @param low - charracter 0..string.char(low) are translated to \xnn (default 32)
-- @param high - charracter string.char(high)..256 are translated to \xnn (default 128)
-- @param extra - extra charracters that are to be escaped as \<c> (eg for escaping a '"')
function binstr_to_escapes( txt, low, high, extra )
	if low==nil then low = 32 end
	if high==nil then high = 128 end
	local en = "[n\\\n" .. (extra or "") .. "]" or nil
	local r = ""
	for i=1,#txt do
		local c = txt:sub(i,i)
		local n = txt:sub(i+1,i+1)
		if c == "\\" and (n:find(en) or n=="x" and txt:sub(i+2,i+2):find("%x") and txt:sub(i+3,i+3):find("%x") ) then
			r = r .. "\\\\"
		elseif c == "\n" then
			r = r .. "\\n"
		elseif c:byte()<low or c:byte()>=high then
			r = r .. string.format("\\x%02x", c:byte())
		elseif extra and #extra>0 and string.find(c,"[" .. extra .. "]") then
			r = r .. string.format("\\%s", c)
		else
			r = r .. c
		end
	end
	return r
end

-- translate an escaped string to it's binary original
-- 
-- Translated are:
-- \xnn  translates to the asci charracter with ascii value 0xnn
--       there should be exact 2 hexadecimal digits!
-- \n    new line = '\x0a'
-- \c    translates to "\c" where c can be any charracter except 'n' or 'x'
function escapes_to_binstr( txt, extra )
	return txt:gsub( "\\(.)(%x?%x?)",
		function(c,x)
			--print("c='" .. c .. "', x='" .. x .. "'")
			if c=="x" and x and #x==2 then
				return string.char(tonumber(x,16))
			elseif c=='n' then
				return string.char(0x0a) .. x
			elseif c=="\\" then
				return "\\" 
			elseif extra and c:find("[" .. extra .. "]") then
				return c .. x
			else
				return "\\" .. c .. x
			end
		end)
end

--
-- Get the first string that is a variable, possible with quotes and escaped 
-- content. The value can be quoted or not. Charracters can be escaped (eg a 
-- space in a non-quoted string or a quote in a quoted string
-- A non-string value can also be ended with a ";" charracter
-- spaces and quotes are stripped
-- return value, remaining string
--
function fetch_value( s, is_string )
	local i = s:find("[^%s]")
	if not i then 
		return nil
	end
	local use_quotes = s:sub(i,i) == "\"" and is_string
	if use_quotes then i=i+1 end
	local v = ""
	--print("s=" .. s .. ", #s=" .. #s .. ", i=" .. i)
	
	while i<=#s and 
			(use_quotes and s:sub(i,i)~="\"" or
			not is_string and not use_quotes and not s:sub(i,i):match("[%s;]") or
			is_string and not use_quotes) do
		local c = s:sub(i,i)
		--print("c=" .. c .. ", i=" .. i)
		if c == "\\" then
			v = v .. s:sub(i,i+1)
			i=i+2
		else
			v = v .. c
			i=i+1
		end
	end
	if use_quotes then i=i+1 end
	local r = s:sub(i)
	return v, #r>0 and r or nil
end


--
-- encrypt a password
--
local secret_salt = "12345678"

function set_password_salt( salt )
	secret_salt = salt
end

function encrypt_password( pwd )
	-- using a fixed secret salt value
	local f = io.popen( string.format("makepasswd -e shmd5 -p '%s' -s '%s' | cut -c%d-", pwd, secret_salt, #pwd+2) )
	local shadow = assert(f:read('*a'):sub(1,-2))
	f:close()
	
	local salt, crypted = shadow:match("%$1%$([%w.]+)%$(.+)")
	logf(LG_DBG, lgid, "encrypted password = '%s'", crypted)

	return shadow, salt, crypted
end

function make_shadow_password( encrypted )
	return "$1$" .. secret_salt .. "$" .. encrypted
end

--
-- validate the password against the pwd using a secret salt,
-- return true when matched, false when no match
function validate_password( encrypted, pwd )
	local shadow, salt, pwd_encrypted = encrypt_password( pwd )
	return pwd_encrypted == encrypted
end


-- date-time format should be: 'YYYY.MM.DD-hh:mm:ss'
function set_date_time( date_time )
	if date_time and date_time:match("^%d%d%d%d%.%d%d%.%d%d%-%d%d:%d%d:%d%d$") then
		os.execute("date " .. date_time .. " ; hwclock -w")
		return true
	else
		return false
	end
end

-- returned format is: 'YYYY.MM.DD-hh:mm:ss'
function get_date_time()
	local fd = io.popen("hwclock -s ; date +%Y.%m.%d-%T")
	local now = fd:read("*line")
	fd:close()
	return now
end


--
-- Translate string to given codepage
--

function to_utf8(text, page)

	local xlat = codepage_to_utf8[page]

	if xlat then
		local out = {}
		for _, c in ipairs( { string.byte(text, 1, #text) } ) do
			if c ~= 0 then
				out[#out+1] = xlat[c] or string.char(c)
			end
		end
		local out = table.concat(out, "")
		return out
	else
		return text
	end
end

--
-- look for filename in path and return the expanded file-path
-- directories in path are collumn ':' seperated
--
function find_file( filename, path )
	local dirs = path and path:split( ":" ) or {"."}
	for i,p in ipairs(dirs) do
		local fp = p .. "/" .. filename
		local stat = sys.lstat( p .. "/" .. filename )
		if stat then
			return fp
		end
	end
	return nil
end

-- vi: ft=lua ts=3 sw=3

