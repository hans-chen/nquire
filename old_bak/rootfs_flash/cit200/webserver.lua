
-- 
-- HTTP server implementation
--

module("Webserver", package.seeall)

-- 
-- Handle request from client. This function parses the incoming request and
-- calls the handler function matching the given path. The handler function is
-- passed the client object, and can use the following methods to generate the
-- HTTP response:
--
-- client:add_data(...)         HTTP payload data to send, typically HTML
-- client:add_header(hdr, val)  Set HTTP header 'hdr' to 'val'
-- client:set_cache(n)          Mark the returned document as cachable for n seconds.
--
-- Example for serving .png images, using the cache
--
-- mod.webserver:register(".+.png", function(client, request)
--    client:set_header("Content-Type", "image/png")
-- 	client:set_cache(3600)
-- 	local fd = io.open("." .. request.path)
-- 	if fd then
-- 		client:add_data(fd:read("*a"))
-- 		fd:close()
-- 	end
-- 	return true
-- end)
--

local function handle_request(client, method, uri, headers, next_buf)

	local request = {
		method = method,
		header = {},
		param = {}
	}

	local response = {
		result = nil,
		header = {},
		data = {}
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

	logf(LG_INF, "webserver", "%s: %s %s", client.address, method, uri)

	-- Parse request headers

	for line in headers:gmatch("([^\r\n]+)") do
		local key, val = line:match("(%S+): (.+)")
		request.header[key] = val
	end



	-- Find handler for request

	for _, handler in pairs(client.webserver.handler_list) do

		if request.path:find(handler.path) then

			-- Call handler to generate HTTP response data and headers

			client.cache_time = -30758400;  -- 1 year ago 
			client.resp_data = {}
			client.resp_header = {}
			local ok, err = pcall(handler.fn, client, request, handler.fndata)

			-- Check if handler executed OK

			if ok then
				response.result = "200 OK"
				response.data = table.concat(client.resp_data)
				response.header = client.resp_header
				response.header["Expires"] = os.date("%a, %d %b %Y %H:%M:%S GMT", os.time() + client.cache_time)
			else
				response.result = "500 Error"
				response.data = "<h1>Error</h1>\nAn error occured while handling the request:<br><pre>" .. err
			end
			
		end
	end

	-- Generate 404 if no handler found
	
	if not response.result then
		response.result = "404 Not found"
		response.data = "<h1>Not found</h1>\nThe requested URL %s was not found on this server." % request.path
	end
				
	response.header["Content-Length"] = response.header["Content-length"] or #response.data
	response.header["Content-type"] = response.header["Content-type"] or "text/html; charset=iso-8859-1"
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
	
	client:send("HTTP/1.1 " .. response.result .. "\n")
	client:send(headers)
	client:send(response.data)

	if response.header["Connection"] == "Close" then
		client:close()
		logf(LG_DBG, "webserver", "Client closed, no keepalive")
		return
	end

end


--
-- Handle incoming HTTP requests
--

local function on_fd_client(event, client)
	
	if event.data.fd ~= client.fd then
		return
	end

	local data = client:recv()

	-- Check if remote connection closed
	
	if not data then
		logf(LG_DBG, "webserver", "Client closed connection")
		client:close()
		return
	end

	-- Add data to buffer
	
	client.buf = client.buf .. data

	-- Check if HTTP request(s) in buffer
	
	while true do

		local method, uri, headers, next_buf = client.buf:match("(%S+) (%S+).-[\r\n]+(%S.-)\r\n\r\n(.*)")

		if method then
			handle_request(client, method, uri, headers, next_buf)
			client.buf = next_buf
		else
			break
		end

	end

end


--
-- Handle data on server socket, creating new clients for incoming connections
--

local function on_fd_server(event, webserver)

	if event.data.fd ~= webserver.fd then
		return
	end
	my_test_time = sys.hirestime()
	local fd, address = net.accept(webserver.fd)

	logf(LG_DBG, "webserver", "New connection from %s", address)
	print(" ----  Debug Message: connect cost time: " .. sys.hirestime() - my_test_time)
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
		send = function(client, buf) return net.send(client.fd, buf) end,
		close = function(client) 
			net.close(client.fd)
			evq:unregister("fd", on_fd_client, client)
			evq:fd_del(client.fd)
			webserver.client_list[client] = nil
		end,
		add_data = function(client, data) client.resp_data[#client.resp_data+1] = tostring(data) end,
		set_header = function(client, key, val) client.resp_header[key] = val end,
		set_cache = function(client, seconds) client.cache_time = seconds end
	}

	evq:fd_add(client.fd)
	evq:register("fd", on_fd_client, client)
	webserver.client_list[client] = true
end


--
-- Start HTTP server
--

local function start(webserver)
	local port_list = { 80, 8000 }
	local s = net.socket("tcp")
	local port
	for _, try_port in ipairs(port_list) do
		local ok, err = net.bind(s, "0.0.0.0", try_port)
		if ok then 
			port = try_port
			break 
		else
			logf(LG_WRN, "webserver", "Bind to port 80 failed: %s", err)
		end
	end
	net.listen(s, 5)
	webserver.fd = s
	evq:fd_add(webserver.fd)
	evq:register("fd", on_fd_server, webserver)
	logf(LG_INF, "webserver", "HTTP server listening on port %q", port)
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
	net.close(webserver.fd)
	logf(LG_INF, "webserver", "HTTP server stopped")
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


--
-- Module registration 
--

function new()

	local webserver = {
		
		-- data
		
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

	return webserver

end

-- vi: ft=lua ts=3 sw=3
