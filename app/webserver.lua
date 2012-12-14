
-- 
-- HTTP server implementation
--

module("Webserver", package.seeall)


local lgid = "webserver"

-- 
-- Handle request from client. This function parses the incoming request and
-- calls the handler function matching the given path. The handler function is
-- passed the client object, and can use the following methods to generate the
-- HTTP response:
--
-- client:add_data(...)         HTTP payload data to send, typically HTML
-- client:add_header(hdr, val)  Set HTTP header 'hdr' to 'val'
--
-- Example for serving .png images, using the cache
--
-- mod.webserver:register(".+.png", function(client, request)
--    client:set_header("Content-Type", "image/png")
-- 	local fd = io.open("." .. request.path)
-- 	if fd then
-- 		client:add_data(fd:read("*a"))
-- 		fd:close()
-- 	end
-- 	return true
-- end)
--


local function set_keepalive( sock )
	local result, errstr = net.setsockopt(sock, "SO_KEEPALIVE", 1);
	if not result then
		logf(LG_WRN, lgid, "setsockopt SO_KEEPALIVE: %s", errstr);
	end
end


-- return: remaining next_buf
local function handle_request(client, method, uri, headers, next_buf)

	logf(LG_DBG,lgid,"handle_request(client.address=%s, method='%s',uri='%s')", client.address, method or "nil", uri or "nil")

	local request = {
		method = method,
		header = {},
		param = {}
	}

	local response = {
		result = nil,
		header = {},
		data = {},
	}

	-- split request uri into path and CGI parameters
	
	local path, query = string.match(uri, "([^%?]+)%??(.*)")
	request.path = path
	request.query = query
	if query then
		string.gsub(query, "([^&=]+)=([^&;]*)[&;]?", 
			function(name, attr) 
				request.param[url_decode(name)] = url_decode(attr) 
			end
		)
	end

	logf(LG_DBG, lgid, "path=%s, query=%s", path, query)

	-- Parse request headers

	for line in headers:gmatch("([^\r\n]+)") do
		local key, val = line:match("(%S+): (.+)")
		request.header[key] = val
	end

	if config:get("/dev/auth/enable") == "true" then
		request.auth_ok = false
		if request.header["Authorization"] then
			local auth = string.match(request.header["Authorization"], "Basic (.+)")
			if auth then
				local username, password = base64.decode(auth):match("(.-):(.+)")
				if username == config:get("/dev/auth/username") and 
						validate_password( config:get("/dev/auth/encrypted"), password) then
					request.auth_ok = true
				end
			end
		end
	else
		request.auth_ok = true
	end

	if method == "POST" then
		request.post_data = next_buf:sub(1, request.header["Content-Length"])
		next_buf = next_buf:sub( request.header["Content-Length"]+1 )
	end
	
	-- Find handler for request

	if request.auth_ok then

		for _, handler in pairs(client.webserver.handler_list) do

			logf(LG_DMP, lgid, "handler.path %s", handler.path)
			if request.path:find(handler.path) then

				-- Call handler to generate HTTP response data and headers

				client.resp_data = {}
				client.resp_header = {}
				local ok, retval = safecall(handler.fn, client, request, handler.fndata)

				-- Check if handler executed OK

				if ok then
					if retval=="Authorization" then
						request.auth_ok = false
						logf(LG_DBG,lgid,"Honering authorisation")
					else
						response.result = "200 OK"
						response.data = table.concat(client.resp_data)
-- TODO: remove DEBUG
--for i,l in ipairs(client.resp_data) do
--	print("resp_data " .. i .. ": " .. l)
--end
			
						response.header = client.resp_header
					end
				else
					response.result = "500 Error"
					response.data = "<h1>Error</h1>\nAn error occured while handling the request:<br><pre>" .. retval
				end
				
			end
		end

		-- Generate 404 if no handler found
		
		if not response.result then
			response.result = "404 Not found"
			response.data = "<h1>Not found</h1>\nThe requested URL %s was not found on this server." % request.path
		end
	end
	if not request.auth_ok then
		response.result = "401 Authorization Required"
		response.header["WWW-Authenticate"] = "Basic realm=\"Please authenticate\""
		response.data = "<h1>Authorization required</h1>\n"
	end
				
	response.header["Content-Length"] = response.header["Content-Length"] or #response.data
	response.header["Content-Type"] = response.header["Content-Type"] or "text/html; charset=iso-8859-1"
	response.header["Connection"] = response.header["Connection"] or request.header["Connection"]
	response.header["Connection"] = response.header["Connection"] or "Close"
	
	-- Concatenate all headers into HTTP format
	local h = {}
	for k, v in pairs(response.header) do
		h[#h+1] = k .. ": " .. v .. "\n"
	end
	h[#h+1] = "\n"
	local headers = table.concat(h)

	-- Send result to client

	if		client:send("HTTP/1.1 " .. response.result .. "\n") and
			client:send(headers) and
			client:send(response.data) then
		if response.header["Connection"] == "Close" then
			client:close()
			logf(LG_DBG, lgid, "Client closed, no keepalive")
		end
	else
		logf(LG_WRN,lgid,
[[ Buffer overflow in tcp stack while sending http data: Connection terminated.
This is possibly caused by a (very) bad (wifi) connection. ]] )
		client:close()	
		next_buf = ""
	end

	return next_buf
end


--
-- Handle incoming HTTP requests
--

local function on_fd_client(event, client)
	
	if event.data.fd ~= client.fd then
		return
	end

	local data, err = client:recv()

	-- Check if remote connection closed
	
	if not data then
		logf(LG_DBG, lgid, "%s", (err or "recv error"))
		client:close()
		return
	end

	-- Add data to buffer
	
	client.buf = client.buf .. data

	-- Check if HTTP request(s) in buffer
	
	while true do

		local offset = client.buf:find("\r\n\r\n")

		if offset then
			local buf = client.buf:sub(1, offset)
			local next_buf = client.buf:sub(offset+4)

			--print("DEBUG: buf='" .. buf .. "'")

			local method, uri, headers = buf:match("^(%S+) (%S+).-[\r\n]+(%S.+)")
			--logf(LG_DMP,lgid,"request headers:\n%s", dump(headers or "<nil>"))
			logf(LG_DBG,lgid,"http %s request: '%s'", method or "<nil>", uri)

			if method=="GET" then
				next_buf = handle_request(client, method, uri, headers, next_buf)
			elseif method=="POST" then
				local content_length = headers:match("Content[-]Length:%s+(%d+)")+0
				logf(LG_DBG, lgid, "Content-Length=%d", content_length)
				logf(LG_DBG, lgid, "#next_buf=%d", #next_buf)
				if content_length and content_length>#next_buf then
					-- TODO: test this exception from normal operation
					logf(LG_DBG, lgid, "Not all data received. Next time better")
					break
				end
				next_buf = handle_request(client, method, uri, headers, next_buf)
			else
				logf(LG_WRN,lgid, "Could not handle http request [[%s]]", buf)
			end
			client.buf = next_buf
		else
			break
		end

	end
	logf(LG_DMP, lgid, "debugging - on_fd_client:ready")
end


--
-- Handle data on server socket, creating new clients for incoming connections
--

local function on_fd_server(event, webserver)

	if event.data.fd ~= webserver.fd then
		return
	end

	-- sendbuffersize 17000 required for sending the log-page
	local fd, address = net.accept(webserver.fd, 170000)
	set_keepalive( fd )

	logf(LG_DBG, lgid, "New connection from %s", address)

	local client = {

		-- data
	
		address = address,
		webserver = webserver,
		fd = fd,
		buf = "",
		evq_handler = nil,
		resp_data = {},
		resp_header = {},

		-- methods

		recv = function(client, len) return net.recv(client.fd, len or 4096) end,
		send = function(client, buf) 
				logf(LG_DMP, lgid, "before net.send(fd=%d,#=%d,%s)", client.fd, #buf, buf:sub(1,40) .. (#buf>40 and "..." or ""))
				local n, errmsg = net.send(client.fd, buf)
				if errmsg then
					logf(LG_WRN, lgid, "Sending data to http client: %s", errmsg)
				else
					logf(LG_DMP, lgid, "after net.send() : sent=%d", n or -1)
				end
				return n == #buf
			end,
		close = function(client)
			logf(LG_DMP, lgid, "client:close(fd=%d)", client.fd)
			net.shutdown(client.fd,"RDWR") 
			net.close(client.fd)
			evq:unregister("fd", on_fd_client, client)
			evq:fd_del(client.fd)
			webserver.client_list[client] = nil
		end,
		add_data = function(client, data) client.resp_data[#client.resp_data+1] = tostring(data) end,
		-- TODO:
		flush = function(client) end,
		set_header = function(client, key, val) client.resp_header[key] = val end,
	}

	evq:fd_add(client.fd)
	evq:register("fd", on_fd_client, client)
	webserver.client_list[client] = true
end


--
-- Start HTTP server
--

local function start(webserver, port)
	local s = net.socket("tcp")
	local ok, err = net.bind(s, "0.0.0.0", port)
	if err then
		logf(LG_WRN,lgid,"Could not bind webserver to port %d", port)
		return false
	end
	net.listen(s, 5)
	webserver.fd = s
	evq:fd_add(webserver.fd)
	evq:register("fd", on_fd_server, webserver)
	logf(LG_INF, lgid, "HTTP server listening on port %q", port)
	return true
end


--
-- Stop HTTP server
--

local function stop(webserver)
	for client, _ in pairs(webserver.client_list) do
		client:close()
	end
	evq:unregister("fd", on_fd_server, webserver)
	evq:fd_del(webserver.fd)
	local r, msg = net.shutdown(webserver.fd, "RDWR")
	if msg then
		logf(LG_WRN,lgid,"Error shutting down webserver socket: %s", msg)
	end
	net.close(webserver.fd)
	logf(LG_INF, lgid, "HTTP server stopped")
end


--
-- Register handler for given URL
--

local function register(webserver, path, fn, fndata)
	local handler = {
		path = "^" .. path .. "$",
		fn = fn,
		fndata = fndata,
	}

	webserver.handler_list[#webserver.handler_list+1] = handler
end



function url_decode(field)
	field = string.gsub(field, '%+', ' ')
	return string.gsub(field, '%%(%x%x)',
	function(xx) return string.char(tonumber(xx, 16)) end) 
end


function url_encode(s)
	if s == nil then return "" end
	local aFunction = function( aValue ) return string.format( "&#%02d;", string.byte( aValue ) ) end
	s = string.gsub( s, "([\'\"&<>%c])", aFunction )  
	return s
end

-- handle a request for static data
local function on_request(client, request, mimetype)
	local fname = request.path:match("^(/.+%.%a+)$")
	if fname then
		local fpath = client.webserver.root .. fname
		local fd = io.open(fpath)
		if fd then
			logf(LG_DBG,lgid,"Sending %s, with mimetype %s", fname, mimetype)
			client:set_header("Content-Type", mimetype)
			client:set_header("Cache-Control", "public, max-age=3600")

			client:add_data(fd:read("*a"))
			fd:close()
			return true
		else
			logf(LG_WRN,lgid,"Could not find %s", fpath)
			return false
		end
	else
		logf(LG_WRN,lgid,"No match for %s", request.path)
		return false
	end
end

--
-- Module registration 
--

function new( root_dir )

	local webserver = {
		
		-- data
		root = root_dir,
		fd = nil,
		client_list = {},
		evq_handler = nil,
		handler_list = {},
	
		-- methods
		
		register = register,
		start = start,
		stop = stop,
		url_decode = url_decode,
		url_encode = url_encode,
	}

	-- close all http client connections:
	evq:register( "network_reconfigure", 
		function (node,webserver)
			logf(LG_DBG,lgid,"Closing all http client connections because network settings changed.")
			for client, _ in pairs(webserver.client_list) do
				client:close()
			end
		end, webserver)

	webserver:register("/?favicon%.ico", on_request, "image/x-icon")
	webserver:register("/?.+%.jpg", on_request, "image/jpeg")
	webserver:register("/?.+%.png", on_request, "image/png")
	webserver:register("/?.+%.css", on_request, "text/css")

	return webserver

end

-- vi: ft=lua ts=3 sw=3
