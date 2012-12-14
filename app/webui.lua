
module("Webui", package.seeall)


local function draw_css(client)

	-- Draw one node

	client:add_data([[
	<head>
	<style>
	* { font-family: Arial, sans-serif; }
	a img { border: 0; }
	a { text-decoration: none; color: #004366; }
	body { margin: 0px; padding: 0px; }
	form { display: inline; }
	input { border: solid 1px #aaaaaa; }
	select { border: solid 1px #aaaaaa; }

	ul { 
		list-style: none; 
		padding-left: 0px;
		margin-left: 0px;
		margin-top: 50px;
	}

	li {
		font-weight: bold;
		margin-top: 10px;
		font-size: 1.1em;
		margin-left: 10px;
	}

	fieldset {
		width: 70%;
		padding: 15px;
		margin-top: 40px;
		margin-left: auto;
		margin-right: auto;
		margin-bottom: 20px;
		border: solid 2px #004366;
		-moz-border-radius: 8px;
	}

	.log {
		border-collapse: collapse;
		margin: 20px;
	}
	
	.log-dmp {
		vertical-align: top;
		font-family: mono;
		font-size: 0.8em;
		color: grey;
		border: solid 1px #dddddd;
		padding-left: 10px;
		padding-right: 10px;
	}

	.log-dbg {
		vertical-align: top;
		font-family: mono;
		font-size: 0.8em;
		color: grey;
		border: solid 1px #dddddd;
		padding-left: 10px;
		padding-right: 10px;
	}

	.log-inf {
		vertical-align: top;
		font-family: mono;
		font-size: 0.8em;
		color: black;
		border: solid 1px #dddddd;
		padding-left: 10px;
		padding-right: 10px;
	}

	.log-wrn {
		vertical-align: top;
		font-family: mono;
		font-size: 0.8em;
		color: red;
		border: solid 1px #dddddd;
		padding-left: 10px;
		padding-right: 10px;
	}

	legend {
		background-color: #004336;
		color: white;
		font-weight: bold;
		-moz-border-radius: 3px;
	}

	.error { background: #ff8888; border: solid 1px #aaaaaa; padding: 5px; }
	.label { 
		white-space: nowrap; 
		color: #004366; 
		margin-right: 30px; 
		font-weight: bold;
	}
	.node { }
	.node-error { border: solid 2px red; }
	.submit { margin: 10px; border: solid 1px outset; }
	.title { background: #eeeeff; padding: 15px; font-size: 1.5em; font-weight: bold; }

	.top { 
		width: 100%;
		height: 70px;
		margin: 0px;
		padding: 0px;
		background-image: url(top-gradient.jpg); 
		border-collapse: collapse;
	}

	.top-left {
		background-image: url(top-left.jpg); 
		background-repeat: no-repeat;
		width: 608px;
	}
	
	.top-right {
		background-image: url(top-right.jpg); 
		background-repeat: no-repeat;
		background-position: top right;
	}
	
	.bottom { 
		width: 100%;
		height: 70px;
		margin: 0px;
		padding: 0px;
		background-image: url(bottom-gradient.jpg); 
		border-collapse: collapse;
	}
	
	.bottom-left {
		background-image: url(bottom-left.jpg); 
		background-repeat: no-repeat;
		background-position: top left;
	}

	.progressbar-bg {
		border: solid 2px #004366;
		padding: 2px;
	}

	.progressbar-fg {
		color: orange;
		background-color: orange;
	}


	</style>
	</head>

	]])
end

---------------------------------------------------------------------------
-- Draw a config node
---------------------------------------------------------------------------


local function draw_node_label(client, node)
	client:add_data("<td width=30%>\n")
	client:add_data("<span class=label>\n")
	client:add_data(node.label)
	client:add_data("</span>\n")
	client:add_data("</td>\n")
end

local errors = {}

local function draw_node_value(client, node, ro)

	local id = node:full_id()

	if errors[id] then
		class = "node-error"
	else
		class = "node"
	end

	client:add_data("<td class=%s>\n" % class)
	if node:has_data() then
		local value = node:get()

		if node:is_writable() and not ro then

			client:add_data("<input type=hidden name='id' value=%q/>\n" % id)
			if node.type == "boolean" then
				local c1 = (value == "false") and "checked" or ""
				local c2 = (value == "true") and "checked" or ""
				client:add_data("<input type='radio' name='set-%s' value='false' %s> No " % { id, c1 })
				client:add_data("</input>")
				client:add_data("<input type='radio' name='set-%s' value='true' %s> Yes " % { id, c2 })
				client:add_data("</input>")
			elseif node.type == "enum" then
				client:add_data("<select name='set-%s'>\n" % id)
				for item in node.range:gmatch("([^,]+)") do
					local sel = (item == value) and " selected" or ""
					client:add_data("<option value=%q%s>%s</option>\n" % { item, sel, item })
				end
				client:add_data("</select>\n")
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
				client:add_data("<input name='set-%s' size=%d value=%q/>\n" % {id, size, value })
			end

		else
			client:add_data(value)
		end
	end
			
	client:add_data("</td>")
end



local function draw_node(client, node, ro)
	client:add_data("<tr>\n")
	draw_node_label(client, node)
	draw_node_value(client, node, ro)
	client:add_data("</tr>\n")
end





---------------------------------------------------------------------------
-- Helper functions
---------------------------------------------------------------------------

function humanize(s)
	s = s:gsub("[_]", " ")
	s = s:gsub("(.)(.+)", function(a, b) return a:upper() .. b:lower() end)
	return s
end


function box_start(client, page, title)
	client:add_data("<fieldset>\n")
	client:add_data("<legend>" .. title .. "</legend>\n")
	client:add_data("<input type=hidden name='p' value='%s'>\n" % page)
	client:add_data("<table>\n")
end

local function box_end(client)
	client:add_data("</table>\n")
	client:add_data("</fieldset>\n")
end

local function form_start(client, extra)
	if extra then
		client:add_data("<form " .. extra .. ">\n")
	else
		client:add_data("<form>\n")
	end
end

local function form_end(client)
	client:add_data("<center>")
	client:add_data("<input type='submit' class=submit value='Apply settings'>")
	client:add_data("</center>\n")
	client:add_data("</form>\n")
end

---------------------------------------------------------------------------
-- HTML pages
---------------------------------------------------------------------------

local function page_top(client, request)
	draw_css(client)
	client:add_data("<table class=top><tr>")
	client:add_data("<td class=top-left>&nbsp;</td>")
	client:add_data("<td class=top-right>&nbsp;</td>")
	client:add_data("</tr></table>\n")
end

local function page_bottom(client, request)
	draw_css(client)
	client:add_data("<table class=bottom><tr>")
	client:add_data("<td class=bottom-left>&nbsp;</td>")
	client:add_data("</tr></table>\n")
end


local function page_main(client, request)

	local name = config:lookup("/dev/name"):get()

	client:add_data([[
		<html>
		<title>]] .. name .. [[</title> 
		<noframes>
		<body>
		This page is designed to be viewed with a browser that supports frames.
		Please use another browser...</body></noframes>
		<frameset rows="71,*,70"  frameborder="0" border="0" framespacing="0">
		<frame src="/?p=top" noresize scrolling=no>
		<frameset cols="150,*"  frameborder="0" border="0" framespacing="0">
			<frame src="/?p=menu" noresize>
			<frame src="/?p=home" noresize name="main">
		</frameset>
		<frame src="/?p=bottom" noresize scrolling=no>
		</frameset>
		</body>
		</html>
	]])
end

	
local function page_menu(client, request)

	local item_list = { "home", "network", "messages", "scanner", "miscellaneous", "log", "reboot" }

	draw_css(client)

	client:add_data("<ul class=menu>")
	for _,item in ipairs(item_list) do
		client:add_data("<li class=menu><a href='?p=%s' target='main'>%s</li>" % { item, humanize(item) })
	end
	client:add_data("</ul>\n")

end


local function page_home(client, request)
	draw_css(client)
	box_start(client, "home", "Welcome")
	draw_node(client, config:lookup("/dev/name"), true)
	draw_node(client, config:lookup("/dev/serial"), true)
	draw_node(client, config:lookup("/dev/version"))
	draw_node(client, config:lookup("/dev/rfs_version"))
	draw_node(client, config:lookup("/dev/build"))
	draw_node(client, config:lookup("/dev/date"))
	draw_node(client, config:lookup("/dev/scanner/version"))
	draw_node(client, config:lookup("/network/macaddress"))
end


local function page_network(client, request)

	-- Find out if a wlan adapter is available. Dirty but this works:

	local have_wlan = false

	local fd = io.popen("iwconfig", "r")
	if fd then
		for l in fd:lines() do
			if l:match("wlan0") then
				have_wlan = true
			end
		end
		fd:close()
	end

	draw_css(client)
	form_start(client)

	if have_wlan then
		box_start(client, "network", "Network interface")
		draw_node(client, config:lookup("/network/interface"))
		box_end(client)
		
		box_start(client, "wifi", "Wifi")
		draw_node(client, config:lookup("/network/wifi/essid"))
		draw_node(client, config:lookup("/network/wifi/keytype"))
		draw_node(client, config:lookup("/network/wifi/key"))
		box_end(client)
	else
		config:lookup("/network/interface"):set("ethernet")
	end

	box_start(client, "network", "IP Settings")
	draw_node(client, config:lookup("/network/dhcp"))
	draw_node(client, config:lookup("/network/ip/address"))
	draw_node(client, config:lookup("/network/ip/netmask"))
	draw_node(client, config:lookup("/network/ip/gateway"))
	box_end(client)

	box_start(client, "network", "NQuire protocol settings")
	draw_node(client, config:lookup("/cit/udp_port"))
	draw_node(client, config:lookup("/cit/tcp_port"))
	draw_node(client, config:lookup("/cit/mode"))
	draw_node(client, config:lookup("/cit/remote_ip"))
	box_end(client)
	
	form_end(client)
end




local function page_messages(client, request)
	draw_css(client)

	local msg_list = { 
		{ count=3, id="idle" },
		{ count=2, id="error"}
	}
	local key_list = { "text", "xpos", "ypos", "valign", "halign", "size" }

	for _,msg in ipairs(msg_list) do

		local node = config:lookup("/cit/messages/%s" % msg.id)
		form_start(client)
		box_start(client, "messages", node.label)

		client:add_data("<tr>")
		for _,item in ipairs(key_list) do
			draw_node_label(client, config:lookup("/cit/messages/%s/1/%s" % { msg.id, item } ))
		end
		client:add_data("</tr>")
		for row = 1, msg.count do
			client:add_data("<tr>")
			for _,item in ipairs(key_list) do
				draw_node_value(client, config:lookup("/cit/messages/%s/%s/%s" % { msg.id, row, item } ))
			end
			client:add_data("</tr>")
		end
		-- 'dirty' trick but it won't work otherwise
		client:add_data("</table><table>\n")

		if msg.id == "idle" then
			draw_node(client, config:lookup("/cit/messages/idle/show_idle_picture"))
		end
		box_end(client)
		form_end(client)
	end

end

local function page_scanner( client, request )

	draw_css(client)
	form_start(client)

	box_start(client, "scanner", "Barcodes")
	if scanner.type == "2d" then
		draw_node(client, config:lookup("/dev/scanner/barcodes"))
	end
	draw_node(client, config:lookup("/dev/scanner/enable_barcode_id"))
	box_end(client)

	if scanner.type == "2d" then
		box_start(client, "scanner", "Scanning modes Imager")
		draw_node(client, config:lookup("/dev/scanner/illumination_led"))
		draw_node(client, config:lookup("/dev/scanner/reading_sensitivity"))
		draw_node(client, config:lookup("/dev/scanner/aiming_led"))
		box_end(client)
	end

	if scanner.type == "1d" then
		box_start(client, "scanner", "Scanning modes")
		draw_node(client, config:lookup("/dev/scanner/1d_scanning_mode"))
		box_end(client)
	end

	form_end(client)

end

local function page_miscellaneous(client, request)
	
	draw_css(client)
	form_start(client)

	box_start(client, "miscellaneous", "Device")
	draw_node(client, config:lookup("/dev/name"))
	box_end(client)

	box_start(client, "miscellaneous", "Authentication")
	draw_node(client, config:lookup("/dev/auth/enable"))
	draw_node(client, config:lookup("/dev/auth/username"))
	draw_node(client, config:lookup("/dev/auth/password"))
	box_end(client)
	
	box_start(client, "miscellaneous", "Text and messages")
	draw_node(client, config:lookup("/cit/messages/idle/timeout"))
	draw_node(client, config:lookup("/cit/messages/error/timeout"))
	draw_node(client, config:lookup("/cit/codepage"))
	box_end(client)

	box_start(client, "miscellaneous", "Interaction")
	draw_node(client, config:lookup("/dev/display/contrast"))
	draw_node(client, config:lookup("/dev/beeper/volume"))
	draw_node(client, config:lookup("/dev/beeper/beeptype"))
	box_end(client)
	
	form_end(client)

end

local function page_log(client, request)
	
	draw_css(client)

	local line = 1
	local f = io.popen("logread", "r")
	if f then
		box_start(client, "log", "System log")
		client:add_data("<table class=log>")
		for l in f:lines() do
			-- Jan  1 01:56:38 NEWLAND_CIT user.notice lua: inf webserver: 10.0.0.56: GET /bottom-left.jpg
			local level, component, msg = l:match("lua: (%S+) (%S-): (.+)")
			if level then
				client:add_data("<tr>")
				client:add_data(" <td class=log-%s>%d</td>" % { level, line } )
				client:add_data(" <td class=log-%s>%s</td>" % { level, level } )
				client:add_data(" <td class=log-%s>%s</td>" % { level, component } )
				client:add_data(" <td class=log-%s>%s</td>" % { level, msg } )
				client:add_data("</tr>\n")
				line = line + 1
			end
		end
		client:add_data("</table>")
		f:close()
		box_end(client)
	end
end


local function page_reboot(client, request)
	
	draw_css(client)

	box_start(client, "miscellaneous", "Device")

	client:add_data("Click the button below to reboot the device: <br><br>")
	client:add_data("<form>")
	client:add_data("<input type=hidden name=p value=rebooting>")
	client:add_data("<input type=submit value='Reboot'>")
	client:add_data("</form>")

	client:add_data("<br><br>Click the button below to reset factory default settings and reboot the device: <br><br>")
	client:add_data("<form>")
	client:add_data("<input type=hidden name=p value=defaults>")
	client:add_data("<input type=submit value='Defaults'>")
	client:add_data("</form>")
	box_end(client)

end


local function page_rebooting(client, request)
	
	draw_css(client)

	client:add_data([[

		<meta http-equiv='refresh' content="30; url=javascript:window.open('/','_top');">

		<br><br><br>
		The NQuire is now rebooting. This page will automatically attempt to
		reconnect after 30 seconds.<br><br>

		If the connection attempt is unsuccessful, or if the IP address of the
		device changes after the restart, the connection must be reopened
		manually. Enter the IP address of the device in the URL field (address
		bar) in your browser.<br><br>

		<script language=javascript>
			function progressbar(ticks, maxticks)
			{
				width = 100 * ticks / maxticks + 1;
				var div = document.getElementById("progressbar")
				div.innerHTML = "<center><table width=50%% class=progressbar-bg><tr><td class=progressbar-fg width=" + width + "%%>&nbsp;</td><td>&nbsp;</td></tr></table></center>";
				if(ticks < maxticks) {
					setTimeout("progressbar(" + (ticks+1) + "," + maxticks + ")", 1000);
				}
			}
		</script>

		<div id=progressbar>
			teller
		</div>
			
		<script language=javascript>
			progressbar(0, 30);
		</script>
	]])

	os.execute("reboot")
end


local function page_defaults(client, request)
	logf(LG_INF, "webui", "Removing cit.conf to restore factory default settings")
	local ok, err = os.execute("rm -f cit.conf")
	if not ok then
		logf(LG_WRN, "webui", "Could not remove cit.conf: %s", err)
	end
	page_rebooting(client, request)
end


---------------------------------------------------------------------------
-- Handle requests from web server
---------------------------------------------------------------------------

local function on_webserver(client, request)
	
	local applied_setting;

	errors = {}
	for key, val in pairs(request.param) do
		local id = key:match("^set%-(.+)")
		if id then
			local node = config:lookup(id)
			if node then 
				local ok = node:set(val)
				applied_setting = true		
				if not ok then 
					errors[id] = true
				end
			end
		end
	end

	if applied_setting then
		logf(LG_DMP,"webui","Initiating cit_idle_msg in 4 seconds")
		cit:show_message("Applying", "settings")
		evq:push("cit_idle_msg", nil, 4.0)
	end
	

	local pagehandlers = {
		top = page_top,
		bottom = page_bottom,
		main = page_main,
		menu = page_menu,
		home = page_home,
		network = page_network,
		messages = page_messages,
		scanner = page_scanner,
		miscellaneous = page_miscellaneous,
		log = page_log,
		reboot = page_reboot,
		rebooting = page_rebooting,
		defaults = page_defaults,
	}

	local p = request.param.p
	local handler
	if p and pagehandlers[p] then
		handler = pagehandlers[p]
	else
		handler = pagehandlers.main
	end
				
	client:set_header("Content-Type", "text/html; charset=UTF-8")
	
	handler(client, request)

end

function on_upgrade_welcome_image()
	local path_ftp_dir = "/home/ftp"

	local upgrade_busy = false

	local files, err = sys.readdir(path_ftp_dir)
	if not files then
		logf(LG_WRN, "webui", "Could not read directory %s: %s", path_ftp_dir, err)
		return true
	end

	local now = os.time()

	for _, file in ipairs(files) do

		-- is this the file we are looking for?
		if file == "welcome.gif" then
	
			logf(LG_DMP,"webui", "installing file %s", file)
		
			local filepath = path_ftp_dir .. "/" .. file
		
			-- Check if this is a regular file, not a directory or symlink
			local stat = sys.lstat(filepath)
			if stat.isreg then

				-- Calculate how long the file has not been modified and limit the file size to 100k
				local age = os.time() - stat.mtime
				if age>5 then
					if stat.size<100000 then
						-- mv file
						os.execute("rm -f /cit200/img/welcome.*")
						os.execute("mv " .. filepath .. " /cit200/img/")
						logf(LG_INF,"webui", "Installed %s", file)
						evq:push( "cit_idle_msg", nil, 0 )
					else
						-- remove file and log an error
						os.execute("rm -f " .. filepath)
						logf(LG_WRN,"webui", "File %s to large for use as welcome image. max=100kB", file)
					end
					return true
				end
			end
		end	
	end
	return true
end

function new()
	webserver:register("/", on_webserver)

	webserver:register(".+.jpg",
		function(client, request)
			local fname = request.path:match("([^/]+.jpg)")
			if fname then
				local fd = io.open("img/" .. fname)
				if fd then
					client:set_header("Content-Type", "image/jpg")
					client:add_data(fd:read("*a"))
					client:set_cache(3600)
					fd:close()
				end
			end
		end)
	
	-- regularly check for an uploaded welcome image
	evq:register("upgrade_welcome_image", on_upgrade_welcome_image)
	evq:push("upgrade_welcome_image", nil, 10.0)

end

-- vi: ft=lua ts=3 sw=3
