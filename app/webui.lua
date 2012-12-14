
module("Webui", package.seeall)

local lgid = "webui"

local hidden_password = "\001\001\001\001"

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


local function body_begin(client)
client:add_data([[
<body>
<script type="text/javascript"> 
function toggle(tf, group) 
{ 
    document.getElementById(group).style.visibility = (tf) ? "block" : "none"; 
}
function set_visibility(tf, group)
{
    document.getElementById(group).style.display = (tf) ? "" : "none"; 
} 
function enable_disable(tf, element) 
{ 
    document.getElementById(element).disabled = ! tf; 
}
</script> 
]])
end

local function body_end(client)
client:add_data([[
</body>
]])
end

---------------------------------------------------------------------------
-- Draw a config node
---------------------------------------------------------------------------

local function draw_node_label_start(client, node)
	client:add_data("<td width=30%>\n")
	client:add_data("<span class=label>" .. node.label .. "</span>\n")
end

local function draw_node_label_end(client)
	client:add_data("</td>\n")
end

local function draw_node_label(client, node)
	draw_node_label_start( client, node )
	draw_node_label_end( client )
end

local errors = {}

local function draw_node_value_data( client, node, ro, optarg )
	local id = node:full_id()

	if not optarg then optarg="" end

	if node:has_data() then
		local value = node:get()

		if node:is_writable() and not ro then

--			client:add_data("<input type='hidden' name='id' value=%q/>\n" % id)
			if node.type == "boolean" and node.appearance=="checkbox" then
				logf(LG_DBG,lgid,"displaying checkbox %s = %s", id, value)
				local is_checked = (value == "true") and "checked" or ""
				client:add_data("<input type='hidden' name='default-%s' value='off'/>\n" % { id })
				client:add_data("<input type='checkbox' name='set-%s' %s %s/>\n" % { id, optarg, is_checked })
			elseif node.type == "boolean" then
				local c1 = (value == "false") and "checked" or ""
				local c2 = (value == "true") and "checked" or ""
				client:add_data("<input type='radio' name='set-%s' value='false' %s %s/> No\n" % { id, c1, optarg })
				client:add_data("<input type='radio' name='set-%s' value='true' %s %s/> Yes\n" % { id, c2, optarg })
			elseif node.type == "enum" then
				client:add_data("<select name='set-%s' %s >\n" % {id, optarg})
				for item in node.range:gmatch("([^,]+)") do
					local sel = (item == value) and " selected" or ""
					client:add_data("<option value=%q%s>%s</option>\n" % { item, sel, item })
				end
				client:add_data("</select>\n")
			elseif node.type == "password" then
				--client:add_data("<input type='password' name='set-%s' size='15' value=%q %s/>\n" % {id, value, optarg })
				client:add_data("<input type='password' name='set-%s' size='15' value=%q %s/>\n" % {id, hidden_password, optarg })
			else
				if node.type == "ip_address" then
					size = 15
				elseif node.range then
					size = 0
					for c in node.range:gmatch("(%d+)") do
						local n = tonumber(c)
						if size<n then size=n end
					end
					if node.type == "number" then
						size = 1+math.floor(math.log(size) / math.log(10))
					end
				else
					size = 10
				end
				local maxlength = size
				if node.options and node.options:find("b") then
					--print("DEBUG: node[= " .. id .. "]='" ..  value .. "'")
					
					client:add_data("<input name='set-%s' maxlength='%d' size='%d' value='%s' %s/>\n" % {id, maxlength*4, (node.size or size*4), binstr_to_escapes(value,0,0), optarg })
				else
					-- show string as it is, we have to replace all '&' and '\'' 
					-- charracter with their html escape codes
					local v = binstr_to_escapes(value:gsub("[&']",
							function (c) 
								if c=="'" then 
									return "&#39;" 
								elseif c=="&" then
									return "&#38;"
								end 
							end ), 31, 256)
				
					client:add_data("<input name='set-%s' maxlength='%d' size='%d' value='%s' %s/>\n" % {id, maxlength, (node.size or size), v, optarg })
				end
			end

		else
			client:add_data(value)
		end
	end
end


local function draw_node_value(client, node, ro, optarg)
	local id = node:full_id()
	if errors[id] then
		class = "node-error"
	else
		class = "node"
	end

	client:add_data("<td class=%s>\n" % class)
	draw_node_value_data( client, node, ro, optarg )
	client:add_data("</td>")
end



local function draw_node(client, node, ro, optarg, tr_arg)
	client:add_data("<tr " .. (tr_arg or "") .. ">\n")
	draw_node_label(client, node)
	draw_node_value(client, node, ro, optarg)
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


function box_start(client, page, title, extra)
	client:add_data("<fieldset " .. (extra or "") .. ">\n")
	client:add_data("<legend>" .. title .. "</legend>\n")
--	client:add_data("<input type=hidden name='p' value='%s'/>\n" % page)
	client:add_data("<table>\n")
end

local function box_end(client)
	client:add_data("</table>\n")
	client:add_data("</fieldset>\n")
end

local function form_start(client, extra)
	if extra then
		client:add_data("<form method='post' " .. extra .. ">\n")
	else
		client:add_data("<form method='post'>\n")
	end
end

local function form_end(client)
	client:add_data("<center>")
	client:add_data("<input type='submit' class=submit value='Apply settings'/>")
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
	draw_node(client, config:lookup("/dev/hardware"))
end

local function display_by_default( yes_do )
	return (yes_do and "" or "style='display:none'")
end

local function page_network(client, request)
	
	draw_css(client)
	body_begin(client);
	form_start(client)

	local itf_node = config:lookup("/network/interface")
	local ift_value = itf_node:get()

	local has_wlan = Network:wlan_is_available()
	local has_gprs = Network:gprs_is_available()
	local itf_config = config:get("/network/interface")

	if has_wlan or has_gprs or itf_config~="ethernet" then
--print("DEBUG: itf_node:get()=" .. ift_value)
--print("DEBUG: itf_node.range=" .. itf_node.range)
		box_start(client, "network", "Network interface")
			if not has_wlan and not has_gprs and itf_config~="ethernet" then
				client:add_data("<span class=label>WATCH OUT: " .. itf_config .. " hardware is not detected!</span>\n")
			end
			local extra = "onclick=\"set_visibility(this.value==" ..
				(has_wlan and "'wifi','wifisettings'" or "'gprs','gprssettings'") .. ");" ..
											"set_visibility(this.value!='gprs', 'dhcp_settings')\""
--print("DEBUG: extra=".. extra)
			if has_gprs or itf_config == "gprs" then
				itf_node.range = "ethernet,gprs"
			elseif has_wlan or itf_config == "wifi" then
				itf_node.range = "ethernet,wifi"
			else
				itf_node.range = "ethernet"
			end
			draw_node(client, itf_node, false, extra)
		box_end(client)

		if has_wlan then
			box_start(client, "wifi", "Wifi", "id='wifisettings' " .. 
					display_by_default(ift_value=="wifi") )
				draw_node(client, config:lookup("/network/wifi/essid"))
				draw_node(client, config:lookup("/network/wifi/keytype"))
				draw_node(client, config:lookup("/network/wifi/key"))
			box_end(client)
		end

		if has_gprs then
			box_start(client, "gprs", "Gprs", "id='gprssettings' " ..  
					display_by_default(ift_value=="gprs") )
				draw_node(client, config:lookup("/network/gprs/pin"))
				draw_node(client, config:lookup("/network/gprs/username"))
				draw_node(client, config:lookup("/network/gprs/password"))
				draw_node(client, config:lookup("/network/gprs/apn"))
				draw_node(client, config:lookup("/network/gprs/number"))
			box_end(client)
		end
	else
		--config:lookup("/network/interface"):set("ethernet")
	end


	box_start(client, "network", "IP Settings", "id='dhcp_settings'")
		draw_node(client, config:lookup("/network/dhcp"),false,"onclick='set_visibility(this.value==\"false\",\"static_ip_settings\")'")
		client:add_data("<table id='static_ip_settings' " .. 
				display_by_default(config:lookup("/network/dhcp"):get()=="false" and 
										ift_value~="gprs") .. ">")
			draw_node(client, config:lookup("/network/ip/address"))
			draw_node(client, config:lookup("/network/ip/netmask"))
			draw_node(client, config:lookup("/network/ip/gateway"))
		client:add_data("</table>")
	box_end(client)

	box_start(client, "network", "NQuire protocol settings")
		local mode = config:get("/cit/mode")
		draw_node(client, config:lookup("/cit/udp_port"), false, "id='udp_port'" .. 
				(mode:find("TCP") and " disabled" or "") )
		draw_node(client, config:lookup("/cit/tcp_port"), false, "id='tcp_port'" .. 
				(mode=="UDP" and " disabled" or "") )
		draw_node(client, config:lookup("/cit/mode"), false, "onchange=\"enable_disable(this.value!='UDP','tcp_port');enable_disable(this.value!='TCP server' && this.value!='TCP client' && this.value!='TCP client on scan','udp_port');enable_disable(this.value!='TCP server','remote_ip') \"" )
		draw_node(client, config:lookup("/cit/remote_ip"), false, "id='remote_ip'" .. 
				(mode=="TCP server" and " disabled" or "") )
	box_end(client)
	
	form_end(client)
	body_end(client);
end




local function page_messages(client, request)
	draw_css(client)
	body_begin(client);

	local msg_list = { 
		{ count=3, id="idle" },
		{ count=2, id="error"}
	}
	local key_list = { "text", "xpos", "ypos", "valign", "halign", "size" }

	form_start(client)
	
	for _,msg in ipairs(msg_list) do

		local node = config:lookup("/cit/messages/%s" % msg.id)
		box_start(client, "messages", node.label)

		client:add_data("<tr>")
		for _,item in ipairs(key_list) do
			draw_node_label(client, config:lookup("/cit/messages/%s/1/%s" % { msg.id, item } ))
		end
		client:add_data("</tr>")
		for row = 1, msg.count do
			client:add_data("<tr>")
			for _,item in ipairs(key_list) do
				local extra = ""
				if item == "xpos" or item == "ypos" then 
					extra = "id='" .. msg.id .. item .. row .. "'"; 
					if item=="xpos" and config:lookup("/cit/messages/%s/%s/halign" % { msg.id, row } ).value~="left" then
						extra = extra .. " disabled"
					end
					if item=="ypos" and config:lookup("/cit/messages/%s/%s/valign" % { msg.id, row } ).value~="top" then
						extra = extra .. " disabled"
					end
				end
				if item == "valign" then 
					extra = "onchange='enable_disable(value==\"top\", \"" .. msg.id .. "ypos" .. row .. "\")'"; 
				end
				if item == "halign" then 
					extra = "onchange='enable_disable(value==\"left\", \"" .. msg.id .. "xpos" .. row .. "\")'";
				end
				local node = config:lookup("/cit/messages/%s/%s/%s" % { msg.id, row, item } )
				draw_node_value(client, node, false, extra)
			end
			client:add_data("</tr>")
		end

		if msg.id == "idle" then
			client:add_data("<tr>")
			
			local idle_picture_show = config:lookup("/cit/messages/idle/picture/show")
			draw_node_label_start(client, idle_picture_show)
			draw_node_value_data(client, idle_picture_show,false, "onclick=\"enable_disable(this.checked,'xpos');enable_disable(this.checked,'ypos')\" id='show_idle_picture'")
			draw_node_label_end( client )
			--local enabled = config:lookup("/cit/messages/idle/picture/show"):get() == "true"
			draw_node_value(client, config:lookup("/cit/messages/idle/picture/xpos"), false, "id='xpos'")
			draw_node_value(client, config:lookup("/cit/messages/idle/picture/ypos"), false, "id='ypos'")

			client:add_data("</tr>\n")
		end

		client:add_data("</tr>\n")
		box_end(client)
	end

	box_start(client, "messages", config:lookup("/cit/messages/fontsize").label)
		draw_node(client, config:lookup("/cit/messages/fontsize/small"))
		draw_node(client, config:lookup("/cit/messages/fontsize/large"))
	box_end(client)

	form_end(client)

client:add_data([[
<script type="text/javascript"> 
	enable_disable(document.getElementById('show_idle_picture').checked, 'xpos');
	enable_disable(document.getElementById('show_idle_picture').checked, 'ypos');
</script> 
]])

	body_end(client);
end

local function page_scanner( client, request )

	draw_css(client)
	body_begin(client);
	form_start(client)

	box_start(client, "scanner", "Barcodes")
	if scanner.type == "em2027" then
		local onof = "onclick='"
		local n = 1;
		for _,code in ipairs(scanner.enable_disable) do
			if does_firmware_support( code ) and is_2d_code(code.name) then
				onof = onof .. "set_visibility(this.value==\"1D and 2D\",\"2d_code_" .. n .. "\");"
				n = n + 1
			end
		end
		onof = onof .. "'"
		
		draw_node(client, config:lookup("/dev/scanner/barcodes"), false, onof )
		draw_node(client, config:lookup("/dev/scanner/multi_reading_constraint"))
	end
	draw_node(client, config:lookup("/dev/scanner/prevent_duplicate_scan_timeout"))

	draw_node(client, config:lookup("/dev/scanner/enable_barcode_id"))

	client:add_data("<tr><td colspan='2'><hr/><td></tr>")

	-- enable/disable scanning codes
	for _,code in ipairs(scanner.enable_disable) do
		if does_firmware_support( code ) and not is_2d_code(code.name) then
			local node = config:lookup("/dev/scanner/enable-disable/" .. code.name)
			if node then
				logf(LG_DMP, lgid, "showing code %s", code.name)
				draw_node(client, node)
			else
				logf(LG_DBG, lgid, "Code '%s' is no configuration item.", code.name)
			end
		end
	end

	if scanner.type == "em2027" then
		local display_style = ""
		if config:lookup("/dev/scanner/barcodes").value == "1D only" then
			display_style = " style='display:none'"
		end
		local n = 1
		for _,code in ipairs(scanner.enable_disable) do
			if does_firmware_support( code ) and is_2d_code(code.name) then
				local node = config:lookup("/dev/scanner/enable-disable/" .. code.name)
				if node then
					logf(LG_DMP, lgid, "showing code %s", code.name)
					draw_node(client, node, nil, nil, ("id='2d_code_" .. tostring(n)) .. "'" .. display_style )
					n = n + 1
				else
					logf(LG_WRN, lgid, "Code '%s' not found in the configuration", code.name)
				end
			end
		end
	end

	box_end(client)

	if scanner.type == "em2027" then
		box_start(client, "scanner", "Scanning modes Imager")
		--draw_node(client, config:lookup("/dev/scanner/default_illumination_leds"))
		draw_node(client, config:lookup("/dev/scanner/illumination_led"))
		draw_node(client, config:lookup("/dev/scanner/reading_sensitivity"))
		draw_node(client, config:lookup("/dev/scanner/aiming_led"))
		box_end(client)
	end

	if scanner.type == "em1300" then
		box_start(client, "scanner", "Scanning modes")
		draw_node(client, config:lookup("/dev/scanner/default_illumination_leds"))
		draw_node(client, config:lookup("/dev/scanner/1d_scanning_mode"))
		box_end(client)
	end

	if Scanner_rf:is_available() then
		box_start(client, "scanner", "Mifare scanner")
			draw_node(client, config:lookup("/dev/mifare/key_A"))
			draw_node(client, config:lookup("/dev/mifare/relevant_sectors"))
			draw_node(client, config:lookup("/dev/mifare/cardnum_format"))
			draw_node(client, config:lookup("/dev/mifare/send_cardnum_only"))
			draw_node(client, config:lookup("/dev/mifare/sector_data_format"))
			draw_node(client, config:lookup("/dev/mifare/prevent_duplicate_scan_timeout"))
			draw_node(client, config:lookup("/dev/mifare/msg/access_violation/text"))
			draw_node(client, config:lookup("/dev/mifare/msg/incomplete_scan/text"))
		box_end(client)
	end

	form_end(client)
	body_end(client);

end

local function page_miscellaneous(client, request)
	
	draw_css(client)
	body_begin(client);
	form_start(client)

	box_start(client, "miscellaneous", "Device")
	draw_node(client, config:lookup("/dev/name"))
	box_end(client)

	box_start(client, "miscellaneous", "Authentication")
	draw_node(client, config:lookup("/dev/auth/enable"),false,"onclick=\"enable_disable(value=='true', 'auth_username');enable_disable(value=='true', 'auth_password');enable_disable(value=='true', 'auth_password_shadow')\"")
	local extra = config:lookup("/dev/auth/enable").value=="true" and "" or " disabled";
	draw_node(client, config:lookup("/dev/auth/username"), false, " id='auth_username'" .. extra)
	draw_node(client, config:lookup("/dev/auth/password"), false, " id='auth_password'" .. extra)
	draw_node(client, config:lookup("/dev/auth/password_shadow"), false, " id='auth_password_shadow'" .. extra)
	box_end(client)
	
	box_start(client, "miscellaneous", "Programming barcode security")
	draw_node(client, config:lookup("/cit/programming_mode_timeout"))
	draw_node(client, config:lookup("/dev/barcode_auth/enable"),false,"onclick=\"enable_disable(value=='true', 'security_code')\"")
	local extra = config:lookup("/dev/barcode_auth/enable").value=="true" and "" or " disabled";
	draw_node(client, config:lookup("/dev/barcode_auth/security_code"), false, " id='security_code'" .. extra)
	box_end(client)

	box_start(client, "miscellaneous", "Text and messages")
	draw_node(client, config:lookup("/cit/messages/idle/timeout"))
	draw_node(client, config:lookup("/cit/messages/error/timeout"))
	draw_node(client, config:lookup("/cit/codepage"))
	draw_node(client, config:lookup("/cit/message_separator"))
	box_end(client)

	box_start(client, "miscellaneous", "Interaction")
	draw_node(client, config:lookup("/dev/display/contrast"))
	draw_node(client, config:lookup("/dev/beeper/volume"))
	draw_node(client, config:lookup("/dev/beeper/beeptype"))
	draw_node(client, config:lookup("/cit/disable_scan_beep"))
	box_end(client)

	box_start(client, "miscellaneous", "GPIO")
	draw_node(client, config:lookup("/dev/gpio/prefix"))
	draw_node(client, config:lookup("/dev/gpio/method"),false,"onclick=\"enable_disable(this.value=='Poll','poll_delay')\"" )
	local gpio_poll_delay_disabled = config:get("/dev/gpio/method")=="Poll" and "" or " disabled";
	draw_node(client, config:lookup("/dev/gpio/poll_delay"),false," id='poll_delay'" .. gpio_poll_delay_disabled)
	box_end(client)
	
	if config:get("/dev/touch16/name") ~= "" then
		box_start(client, "miscellaneous", "Touch screen")
		draw_node(client, config:lookup("/dev/touch16/prefix"))
		draw_node(client, config:lookup("/dev/touch16/timeout"))
		draw_node(client, config:lookup("/dev/touch16/keyclick"))
		draw_node(client, config:lookup("/dev/touch16/minimum_click_delay"))
		draw_node(client, config:lookup("/dev/touch16/send_active_keys_only"))
		box_end(client)
	end
	
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
			-- change above to this when logging should be with time string
			-- also see log.lua (doing syslog)
			--local time, level, component, msg = l:match("lua: (%d+:%d+:%d+%.%d+) (%S+) (%S-): (.+)")
			if level then
				client:add_data("<tr>")
				client:add_data(" <td class=log-%s>%d</td>" % { level, line } )
				--client:add_data(" <td class=log-%s>%s</td>" % { level, time } )
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
	client:add_data("<form method='post'>")
	client:add_data("<input type=hidden name=p value=rebooting>")
	client:add_data("<input type=submit value='Reboot'>")
	client:add_data("</form>")

	client:add_data("<br><br>Click the button below to reset factory default settings and reboot the device: <br><br>")
	client:add_data("<form method='post'>")
	client:add_data("<input type=hidden name=p value=defaults>")
	client:add_data("<input type=submit value='Defaults'>")
	client:add_data("</form>")
	box_end(client)

end

function show_page_rebooting( client, intro, delay )
		client:add_data([[

			<meta http-equiv='refresh' content="30; url=javascript:window.open('/','_top');">

			<br><br><br> ]] .. intro .. [[<br><br>

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
					if(ticks <= maxticks) {
						setTimeout("progressbar(" + (ticks+1) + "," + maxticks + ")", 1000);
					}
				}
			</script>

			<div id=progressbar>
				teller
			</div>
			
			<script language=javascript>
				progressbar(0, ]] .. delay .. [[ );
			</script>
		]])
end

local function page_rebooting(client, request)
	
	draw_css(client)

	if Upgrade.upgrade_busy then
		logf(LG_INF, "upgrade", "Upgrade in progress")

		show_page_rebooting( client, [[
			The NQuire is currently upgrading its software. A reboot will be
			performed after the upgrade. This page will automatically attempt to
			reconnect after 100 seconds. ]], 100 )
	else
		show_page_rebooting( client, [[
			The NQuire is now rebooting. This page will automatically attempt to
			reconnect after 40 seconds. ]], 40 )

		os.execute("reboot")
	end
end


local function page_defaults(client, request)
	cit:restore_defaults()
	page_rebooting(client, request)
end


---------------------------------------------------------------------------
-- Handle requests from web server
---------------------------------------------------------------------------

local function on_webserver(client, request)
	
	logf(LG_DMP, lgid, "request.method=%s, request.post_data=%s", request.method, (request.post_data or "nil") )
	local applied_setting;
	local retval = ""

	if not Upgrade.upgrade_busy then
		-- Watch out: this only works as long as the pages do not post binary data 
		if request.method=="POST" and request.post_data then
			string.gsub(request.post_data, "([^&=]+)=([^&;]*)[&;]?", 
				function(name, attr) 
					request.param[webserver.url_decode(name)] = webserver.url_decode(attr) 
				end
			)
		end

		errors = {}
		-- since a checkbox is only received when it is checked, the false value 
		-- is faked with a hidden value of which the key starts with "default-" instead of "set-"
		local keyvalues = {}
		for key, val in pairs(request.param) do
			local id = key:match("^set%-(.+)$")
			if id then
				keyvalues[id] = escapes_to_binstr( val )
			else
				local cb_id = key:match("^default%-(.+)$")
				if cb_id and not request.param["set-" .. cb_id] then
					keyvalues[cb_id] = "false"
				end
			end
		end

		for key, value in pairs(keyvalues) do
			logf(LG_DMP,lgid,"keyvalue['%s'] = '%s'", key, value)
		end
	
		-- and special validation for the password
		if keyvalues["/dev/auth/enable"] and keyvalues["/dev/auth/enable"]=="true" then

			-- so this is the misc page with authentication enabled
			local usr = keyvalues["/dev/auth/username"]
			local pwd = keyvalues["/dev/auth/password"]
			local pwd_shadow = keyvalues["/dev/auth/password_shadow"]

			-- reject when just changed from authentication disabled or username is
			-- changed and passwords did not change or differ
			if (config:get("/dev/auth/enable") == "false" or usr ~= config:get("/dev/auth/username")) and
					(pwd == hidden_password or pwd ~= pwd_shadow) or usr=="" or pwd == "" then
				logf(LG_DBG,lgid,"password is not entered but authentication or user is changed.")
				errors["/dev/auth/username"] = true
				errors["/dev/auth/password"] = true
				errors["/dev/auth/password_shadow"] = true
				errors["/dev/auth/enable"] = true
		
			-- ignore when user and password are not changed:
			-- this only happens direct after authorisation because the browser will 
			-- re-send the page-request
			elseif usr == config:get("/dev/auth/username") and
					pwd == config:get("/dev/auth/password") then
				keyvalues["/dev/auth/enable"] = nil
				keyvalues["/dev/auth/username"] = nil
				keyvalues["/dev/auth/password"] = nil
				keyvalues["/dev/auth/password_shadow"] = nil
				keyvalues["/dev/auth/encrypted"] = nil
			
			-- accept when passwords are entered:
			elseif pwd ~= hidden_password then
				local shadow, salt, crypted = encrypt_password( pwd )
				keyvalues["/dev/auth/encrypted"] = escapes_to_binstr( crypted )
			end
		elseif keyvalues["/dev/auth/enable"] == "false" then
			--keyvalues["/dev/auth/username"] = ""
			keyvalues["/dev/auth/encrypted"] = ""
			keyvalues["/dev/auth/password"] = ""
			keyvalues["/dev/auth/password_shadow"] = ""
		end

		-- now actualy set all values
		for key, value in pairs(keyvalues) do
			local node = config:lookup(key)
			if node then 
				if node.type=="boolean" and node.appearance=="checkbox" and value~="false" then
					value="true"
				end
				if errors[key] then
					logf(LG_DBG,lgid,"Webui data entry error on field %s", key)
				else
					local prev_value = node:get()
					if prev_value ~= value then
						if not node:set( value ) then
							logf(LG_WRN,lgid,"Error setting node %s from '%s' to '%s'", key, node:get(), value)
							errors[key] = true
						else
							logf(LG_DBG,lgid,"changed node %s from '%s' to '%s'", key, prev_value, value)
							applied_setting = true
						end
					end
				end
			end
		end

		-- TODO: should this also be done when there are errors?
		if applied_setting then
			logf(LG_DBG,lgid,"Applied settings")
			-- notify other modules (touch16) before the screen is cleared
			evq:push("apply_settings", nil, -1) 
			display:set_font( nil, 18, nil )
			display:show_message("Applying", "settings")
			evq:push("cit_idle_msg", nil, 4.0)
		end
		
		if keyvalues["/dev/auth/encrypted"] and keyvalues["/dev/auth/encrypted"]~="" then
			-- so the password is changed, inform the webserver of this so 
			-- the client has to authenticate:
			logf(LG_DBG,lgid,"Requesting authorisation")
			retval = "Authorization"
		end

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
	if Upgrade.upgrade_busy then
		handler = page_rebooting
	elseif p and pagehandlers[p] then
		handler = pagehandlers[p]
	else
		handler = pagehandlers.main
	end
				
	client:set_header("Content-Type", "text/html; charset=UTF-8")
	client:set_header("Expires", "")
	client:set_header("Cache-control", "no-cache, must-revalidate, proxy-revalidate")
	
	handler(client, request)

	return retval

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
	
end

-- vi: ft=lua ts=3 sw=3
