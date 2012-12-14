
module("Webui", package.seeall)


local function draw_css(client)

	-- Draw one node

	client:add_data([[
	<head>
	<style>
	* { font-family: sans; }
	a img { border: 0; }
	a { text-decoration: none; }
	body { margin: 0px; padding: 0px; }
	form { display: inline; }
	input { border: solid 1px #dddddd; }
	select { border: solid 1px #dddddd; }
	ul { list-style: none; padding-left: 20px; margin-top: 20px; }
	li .menu {
		padding: 20px;
	}

	fieldset { 
		margin-top: 20px; 
		margin-left: auto; 
		margin-right: auto; 
		width: 80%; 
		border-bottom: none; 
		border-left: none; 
		border-right: none; 
		border-top: solid 6px blue;
	}
	legend {
		padding: 5px;
		margin-left: 20px;
	}

	.error { background: #ff8888; border: solid 1px #aaaaaa; padding: 5px; }
	.label { white-space: nowrap; color: blue; margin-right: 30px; }
	.node { }
	.node-error { border: solid 2px red; }
	.submit { margin: 10px; border: solid 1px outset; }
	.title { background: #eeeeff; padding: 15px; font-size: 1.5em; font-weight: bold; }
	</style>
	</head>

	]])
end

---------------------------------------------------------------------------
-- Draw a config node
---------------------------------------------------------------------------


local function draw_node_label(client, node)
	client:add_data("<td width=30%>")
	client:add_data("<span class=label>")
	client:add_data(node.label)
	client:add_data("</span>")
	client:add_data("</td>")
end

local errors = {}

local function draw_node_value(client, node, ro)

	local id = node:full_id()

	if errors[id] then
		class = "node-error"
	else
		class = "node"
	end

	client:add_data("<td class=%s>" % class)
	if node:has_data() then
		local value = node:get()

		if node:is_writable() and not ro then

			client:add_data("<input type=hidden name='id' value=%q>" % id)
			if node.type == "boolean" then
				local c1 = (value == "false") and "checked" or ""
				local c2 = (value == "true") and "checked" or ""
				client:add_data("<input type='radio' name='set-%s' value='false' %s> No " % { id, c1 })
				client:add_data("<input type='radio' name='set-%s' value='true' %s> Yes " % { id, c2 })
			elseif node.type == "enum" then
				client:add_data("<select name='set-%s'>" % id)
				for item in node.range:gmatch("([^,]+)") do
					local sel = (item == value) and " selected" or ""
					client:add_data("<option value=%q%s>%s</option>" % { item, sel, item })
				end
				client:add_data("</select>")
			else
				if node.type == "ip_address" then
					size = 15
				else
					size = 10
				end
				if node.range then
					local tmp = node.range:match(":(%d+)")
					if tmp then 
						if node.type == "number" then
							size = math.floor(math.log(tmp) / math.log(10))
						else
							size = tmp
						end
					end
				end
				client:add_data("<input name='set-%s' size=%d value=%q>" % {id, size, value })
			end

		else
			client:add_data(value)
		end
	end
			
	client:add_data("</td>")
end



local function draw_node(client, node, ro)
	client:add_data("<tr>")
	draw_node_label(client, node)
	draw_node_value(client, node, ro)
	client:add_data("</tr>")
end


local function draw_submit(client)
	client:add_data("<tr>")
	client:add_data("<td colspan=2 align=center>")
	client:add_data("<input type='submit' class=submit value='Apply'>")
	client:add_data("</td>")
	client:add_data("</tr>")
end



---------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------

function humanize(s)
	s = s:gsub("[_]", " ")
	s = s:gsub("(.)(.+)", function(a, b) return a:upper() .. b:lower() end)
	return s
end


function page_start(client, page, title)
	client:add_data("<fieldset>")
	client:add_data("<legend>" .. title .. "</legend>")
	client:add_data("<form>")
	client:add_data("<input type=hidden name='p' value='%s'>" % page)
	client:add_data("<table>")
end

local function page_end(client)
	client:add_data("</table>")
	client:add_data("</form>")
	client:add_data("</fieldset>")
end

---------------------------------------------------------------------------
-- HTML pages
---------------------------------------------------------------------------


local function page_main(client, request)

	client:add_data([[
		<html>
		<title>Newland CIT</title> 
		<noframes>
		<body>
		This page is designed to be viewed with a browser that supports frames.
		Please use another browser...</body></noframes>
		<frameset cols="150,*"  frameborder="0" border="1" framespacing="0">
		<frame src="/?p=menu" noresize>
		<frame src="/?p=home" noresize name="main">
		</frameset>
		</body>
		</html>
	]])
end

	
local function page_menu(client, request)

	local item_list = { "home", "network", "wifi", "messages", "miscellaneous" }

	draw_css(client)
	client:add_data("<ul class=menu>")
	for _,item in ipairs(item_list) do
		client:add_data("<li class=menu><a href='?p=%s' target='main'>%s</li>" % { item, humanize(item) })
	end
	client:add_data("</ul>")

end


local function page_home(client, request)
	draw_css(client)
	page_start(client, "home", "Welcome")
	draw_node(client, config:lookup("/dev/name"), true)
	draw_node(client, config:lookup("/dev/version"))
	draw_node(client, config:lookup("/network/macaddress"))
end


local function page_network(client, request)
	draw_css(client)
	
	page_start(client, "network", "Network interface")
	draw_node(client, config:lookup("/network/interface"))
	draw_submit(client)
	page_end(client)

	page_start(client, "network", "IP Settings")
	draw_node(client, config:lookup("/network/dhcp"))
	draw_node(client, config:lookup("/network/ip/address"))
	draw_node(client, config:lookup("/network/ip/netmask"))
	draw_node(client, config:lookup("/network/ip/gateway"))
	draw_submit(client)
	page_end(client)

	page_start(client, "network", "SG15 protocol settings")
	draw_node(client, config:lookup("/sg15/udp_port"))
	draw_node(client, config:lookup("/sg15/tcp_port"))
	draw_node(client, config:lookup("/sg15/remote_ip"))
	draw_submit(client)
	page_end(client)
end


local function page_wifi(client, request)
	draw_css(client)

	page_start(client, "wifi", "Wifi")
	draw_node(client, config:lookup("/network/wifi/essid"))
	draw_node(client, config:lookup("/network/wifi/keytype"))
	draw_node(client, config:lookup("/network/wifi/key"))
	draw_submit(client)
	page_end(client)
end


local function page_messages(client, request)
	draw_css(client)

	local msg_list = { 
		{ count=3, id="idle" },
		{ count=2, id="error"}
	}
	local key_list = { "text", "xpos", "ypos", "valign", "halign", "size" }

	for _,msg in ipairs(msg_list) do

		local node = config:lookup("/sg15/messages/%s" % msg.id)
		page_start(client, "messages", node.label)

		client:add_data("<tr>")
		for _,item in ipairs(key_list) do
			draw_node_label(client, config:lookup("/sg15/messages/%s/1/%s" % { msg.id, item } ))
		end
		client:add_data("</tr>")
		for row = 1, msg.count do
			client:add_data("<tr>")
			for _,item in ipairs(key_list) do
				draw_node_value(client, config:lookup("/sg15/messages/%s/%s/%s" % { msg.id, row, item } ))
			end
			client:add_data("</tr>")
		end
		draw_submit(client)
		page_end(client)
	end
	
end


local function page_miscellaneous(client, request)
	
	draw_css(client)

	page_start(client, "miscellaneous", "Device")
	draw_node(client, config:lookup("/dev/name"))
	draw_submit(client)
	page_end(client)

--	page_start(client, "miscellaneous", "Display settings")
--	draw_node(client, config:lookup("/dev/display/reverse"))
--	draw_submit(client)
--	page_end(client)
	
	page_start(client, "miscellaneous", "Text and messages")
	draw_node(client, config:lookup("/sg15/messages/idle/timeout"))
	draw_node(client, config:lookup("/sg15/messages/error/timeout"))
	draw_node(client, config:lookup("/sg15/codepage"))
	draw_submit(client)
	page_end(client)

end


---------------------------------------------------------------------------
-- Handle requests from web server
---------------------------------------------------------------------------

local function on_webserver(client, request)

	errors = {}
	for key, val in pairs(request.param) do
		local id = key:match("^set%-(.+)")
		if id then
			local node = config:lookup(id)
			if node then 
				local ok = node:set(val)
				if not ok then 
					errors[id] = true
				end
			end
		end
	end

	local pagehandlers = {
		main = page_main,
		menu = page_menu,
		home = page_home,
		network = page_network,
		wifi = page_wifi,
		messages = page_messages,
		miscellaneous = page_miscellaneous
	}

	local p = request.param.p
	local handler
	if p and pagehandlers[p] then
		handler = pagehandlers[p]
	else
		handler = pagehandlers.main
	end
	
	handler(client, request)

end



function new()
	webserver:register("/", on_webserver)

	webserver:register(".+.png", function(client, request)
		local fname = request.path:match("([^/]+.png)")
		if fname then
			local fd = io.open("img/" .. fname)
			if fd then
				client:set_header("Content-Type", "image/png")
				client:add_data(fd:read("*a"))
				client:set_cache(3600)
				fd:close()
			end
		end
	end)
end

-- vi: ft=lua ts=3 sw=3
