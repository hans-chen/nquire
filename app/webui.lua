
module("Webui", package.seeall)

local lgid = "webui"

local hidden_password = "\001\001\001\001"

local function draw_head(client)

	-- Draw one node

	client:add_data([[
<head>
<link rel="icon" href="favicon.ico" type="image/x-icon"> 
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<link rel="stylesheet" type="text/css" href="cit.css" />
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

<DIV ID="dek"></DIV>

<SCRIPT TYPE="text/javascript">
<!--
// the popup position.
Xoffset=-60;
Yoffset= 20;

var old,skn,iex=(document.all),yyy=-1000;

var ns4=document.layers
var ns6=document.getElementById&&!document.all
var ie4=document.all

if (ns4)
skn=document.dek
else if (ns6)
skn=document.getElementById("dek").style
else if (ie4)
skn=document.all.dek.style
if(ns4)document.captureEvents(Event.MOUSEMOVE);
else{
skn.visibility="visible"
skn.display="none"
}
document.onmousemove=get_mouse;

function popup(msg,bak){
var content="<TABLE  WIDTH=250 BORDER=1 BORDERCOLOR=black CELLPADDING=2 CELLSPACING=0 "+
"BGCOLOR="+bak+"><TD ALIGN=left><FONT COLOR=black SIZE=2>"+msg+"</FONT></TD></TABLE>";
yyy=Yoffset;
 if(ns4){skn.document.write(content);skn.document.close();skn.visibility="visible"}
 if(ns6){document.getElementById("dek").innerHTML=content;skn.display=''}
 if(ie4){document.all("dek").innerHTML=content;skn.display=''}
}

function get_mouse(e){
var x=(ns4||ns6)?e.pageX:event.x+document.body.scrollLeft;
skn.left=x+Xoffset;
var y=(ns4||ns6)?e.pageY:event.y+document.body.scrollTop;
skn.top=y+yyy;
}

function kill(){
yyy=-1000;
if(ns4){skn.visibility="hidden";}
else if (ns6||ie4)
skn.display="none"
}

//-->
</SCRIPT>

]])
end

local function body_end(client)
client:add_data([[
</body>
]])
end

local function to_html_escapes( value )
	return value:gsub("[;&#\"'%<>]",
		function (c) 
			return "&#" .. string.byte(c) .. ";"
		end )
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

			popup = ""
			if node.comment then
				-- the comment should be written in html (with escape codes),
				-- so the actual string we pass through to the popup function should be escaped:
				local html_comment = to_html_escapes(node.comment)
				popup = "onMouseOver=\"popup('" .. html_comment .. "','lightgreen')\"; onMouseOut=\"kill()\""
			end


--			client:add_data("<input type='hidden' name='id' value=%q/>\n" % id)
			if node.type == "boolean" and node.appearance=="checkbox" then
				logf(LG_DBG,lgid,"displaying checkbox %s = %s", id, value)
				local is_checked = (value == "true") and "checked" or ""
				client:add_data("<input type='hidden' name='default-%s' value='off'/>\n" % { id })
				client:add_data("<input type='checkbox' name='set-%s' %s %s %s/>\n" % { id, optarg, is_checked, popup })
			elseif node.type == "boolean" then
				local c1 = (value == "false") and "checked" or ""
				local c2 = (value == "true") and "checked" or ""
				client:add_data("<input type='radio' name='set-%s' value='false' %s %s %s/> No\n" % { id, c1, optarg, popup })
				client:add_data("<input type='radio' name='set-%s' value='true' %s %s %s/> Yes\n" % { id, c2, optarg, popup })
			elseif node.type == "enum" then
				client:add_data("<select name='set-%s' %s %s>\n" % {id, optarg, popup})
				for item in node.range:gmatch("([^,]+)") do
					local sel = (item == value) and " selected" or ""
					client:add_data("<option value=%q%s>%s</option>\n" % { item, sel, item })
				end
				client:add_data("</select>\n")
			elseif node.type == "password" then
				--client:add_data("<input type='password' name='set-%s' size='15' value=%q %s/>\n" % {id, value, optarg })
				client:add_data("<input type='password' name='set-%s' size='15' value=%q %s %s/>\n" % {id, hidden_password, optarg, popup })
			else
				local maxlength = 10
				if node.range then
					local rmax = 0
					for c in node.range:gmatch("(%d+)") do
						local n = tonumber(c)
						if rmax<n then rmax=n end
					end
					if node.type == "number" then
						maxlength = 1+math.floor(math.log(rmax) / math.log(10))
					else
						maxlength = rmax
					end
				end
				
				local size = node.size or maxlength>=40 and 40 or maxlength<3 and 3 or maxlength
				if node.type == "ip_address" then
					size = 15
					maxlength = 15
				elseif node.type == "number" and not node.size then
					size = maxlength
				end

				-- To show string as it is, we have to replace some charracters
				-- first replace everything under string.char(32) by a human-readable escape code
				local v_esc = binstr_to_escapes(value,31,256)
				-- than replace all charracters that are ambious in html
				local v_html = to_html_escapes( v_esc )
			
				client:add_data("<input name='set-%s' maxlength='%d' size='%d' value='%s' %s %s/>\n" % {id, maxlength, size+2, v_html, optarg, popup })
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
	draw_head(client)
	client:add_data("<table class=top><tr>")
	client:add_data("<td class=top-left>&nbsp;</td>")
	client:add_data("<td class=top-right>&nbsp;</td>")
	client:add_data("</tr></table>\n")
end

local function page_bottom(client, request)
	draw_head(client)
	client:add_data("<table class=bottom><tr>")
	client:add_data("<td class=bottom-left>&nbsp;</td>")
	client:add_data("</tr></table>\n")
end


local function page_main(client, request)

	local name = config:lookup("/dev/name"):get()

	client:add_data([[
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
	]])
end

	
local function page_menu(client, request)

	local item_list = { "home", "network", "messages", "scanner", "miscellaneous", "log", "reboot" }

	draw_head(client)

	client:add_data("<ul class=menu>")
	for _,item in ipairs(item_list) do
		client:add_data("<li class=menu><a href='?p=%s' target='main'>%s</li>" % { item, humanize(item) })
	end
	client:add_data("</ul>\n")

end


local function page_home(client, request)
	draw_head(client)
	body_begin(client)
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
	if Scanner_rf.is_available() then
		draw_node(client, config:lookup("/dev/mifare/modeltype"))
	end
	box_end(client)
	body_end(client)
end

local function display_by_default( yes_do )
	return (yes_do and "" or "style='display:none'")
end


local function page_network(client, request)
	draw_head(client)
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
			local extra = "onChange=\"set_visibility(this.value==" ..
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
		draw_node(client, config:lookup("/network/dhcp"),false,"onClick='set_visibility(this.value==\"false\",\"static_ip_settings\")'")
		client:add_data("<table id='static_ip_settings' " .. 
				display_by_default(config:lookup("/network/dhcp"):get()=="false" and 
										ift_value~="gprs") .. ">")
			draw_node(client, config:lookup("/network/ip/address"))
			draw_node(client, config:lookup("/network/ip/netmask"))
			draw_node(client, config:lookup("/network/ip/gateway"))
			draw_node(client, config:lookup("/network/ip/ns1"))
			draw_node(client, config:lookup("/network/ip/ns2"))
		client:add_data("</table>")
	box_end(client)

	box_start(client, "network", "NQuire protocol settings")
		local mode = config:get("/cit/mode")
		draw_node(client, config:lookup("/cit/udp_port"), false, "id='udp_port'" .. 
				(mode:find("TCP") and " disabled" or "") )
		draw_node(client, config:lookup("/cit/tcp_port"), false, "id='tcp_port'" .. 
				(mode=="UDP" and " disabled" or "") )
		draw_node(client, config:lookup("/cit/mode"), false, "onChange=\"enable_disable(this.value!='UDP','tcp_port');enable_disable(this.value!='TCP server' && this.value!='TCP client' && this.value!='TCP client on scan','udp_port');enable_disable(this.value!='TCP server','remote_ip') \"" )
		draw_node(client, config:lookup("/cit/remote_ip"), false, "id='remote_ip'" .. 
				(mode=="TCP server" and " disabled" or "") )
	box_end(client)
	
	form_end(client)
	body_end(client);
end


local function page_messages(client, request)
	draw_head(client)
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
					extra = "onChange='enable_disable(value==\"top\", \"" .. msg.id .. "ypos" .. row .. "\")'"; 
				end
				if item == "halign" then 
					extra = "onChange='enable_disable(value==\"left\", \"" .. msg.id .. "xpos" .. row .. "\")'";
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
			draw_node_value_data(client, idle_picture_show,false, "onClick=\"enable_disable(this.checked,'xpos');enable_disable(this.checked,'ypos')\" id='show_idle_picture'")
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

	draw_head(client)
	body_begin(client);
	form_start(client)

	box_start(client, "scanner", "Barcodes")
	if scanner.type == "em2027" then
		local onof = "onChange='"
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
				logf(LG_DBG, lgid, "showing code %s", code.name)
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
					logf(LG_DBG, lgid, "showing code %s", code.name)
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
	
	box_start(client, "extscanner", "External scanner")
	draw_node(client, config:lookup("/dev/extscanner/raw"))
	box_end(client)
	

	if Scanner_rf:is_available() then
		box_start(client, "scanner", "Mifare scanner")
			draw_node(client, config:lookup("/dev/mifare/key_A"))
			draw_node(client, config:lookup("/dev/mifare/relevant_sectors"))
			draw_node(client, config:lookup("/dev/mifare/cardnum_format"))
			draw_node(client, config:lookup("/dev/mifare/send_cardnum_only"))
			draw_node(client, config:lookup("/dev/mifare/sector_data_format"))
			draw_node(client, config:lookup("/dev/mifare/sector_data_seperator"))
			draw_node(client, config:lookup("/dev/mifare/suppress_beep"))
			draw_node(client, config:lookup("/dev/mifare/prevent_duplicate_scan_timeout"))
			draw_node(client, config:lookup("/dev/mifare/msg/access_violation/text"))
			draw_node(client, config:lookup("/dev/mifare/msg/incomplete_scan/text"))
			draw_node(client, config:lookup("/dev/mifare/msg/transaction_error_message"))
		box_end(client)
	end

	form_end(client)
	body_end(client);

end


local function page_miscellaneous(client, request)
	
	draw_head(client)
	body_begin(client);
	form_start(client)

	box_start(client, "miscellaneous", "Device")
	draw_node(client, config:lookup("/dev/name"))
	box_end(client)

	box_start(client, "miscellaneous", "Authentication")
	draw_node(client, config:lookup("/dev/auth/enable"),false,"onClick=\"enable_disable(value=='true', 'auth_username');enable_disable(value=='true', 'auth_password');enable_disable(value=='true', 'auth_password_shadow')\"")
	local extra = config:lookup("/dev/auth/enable").value=="true" and "" or " disabled";
	draw_node(client, config:lookup("/dev/auth/username"), false, " id='auth_username'" .. extra)
	draw_node(client, config:lookup("/dev/auth/password"), false, " id='auth_password'" .. extra)
	draw_node(client, config:lookup("/dev/auth/password_shadow"), false, " id='auth_password_shadow'" .. extra)
	box_end(client)
	
	box_start(client, "miscellaneous", "Programming barcode security")
	draw_node(client, config:lookup("/cit/programming_mode_timeout"))
	draw_node(client, config:lookup("/dev/barcode_auth/enable"),false,"onClick=\"enable_disable(value=='true', 'security_code')\"")
	local extra = config:lookup("/dev/barcode_auth/enable").value=="true" and "" or " disabled";
	draw_node(client, config:lookup("/dev/barcode_auth/security_code"), false, " id='security_code'" .. extra)
	box_end(client)

	box_start(client, "miscellaneous", "Text and messages")
	draw_node(client, config:lookup("/cit/messages/idle/timeout"))
	draw_node(client, config:lookup("/cit/messages/error/timeout"))
	draw_node(client, config:lookup("/cit/codepage"))
	draw_node(client, config:lookup("/cit/message_separator"))
	draw_node(client, config:lookup("/cit/message_encryption"))
	local emtn = config:lookup("/cit/enable_message_tag")
	draw_node(client, emtn, false, "onClick=\"enable_disable(value=='true', 'message_tag')\"")
	draw_node(client, config:lookup("/cit/message_tag"), false, " id='message_tag'" .. (emtn.value=="true" and "" or " disabled"))
	box_end(client)

	box_start(client, "miscellaneous", "Interaction")
	draw_node(client, config:lookup("/dev/display/contrast"))
	draw_node(client, config:lookup("/dev/beeper/volume"))
	draw_node(client, config:lookup("/dev/beeper/beeptype"))
	draw_node(client, config:lookup("/cit/disable_scan_beep"))
	box_end(client)

	box_start(client, "miscellaneous", "GPIO")
	draw_node(client, config:lookup("/dev/gpio/prefix"))
	draw_node(client, config:lookup("/dev/gpio/method"),false,"onChange=\"enable_disable(this.value=='Poll','poll_delay')\"" )
	local gpio_poll_delay_disabled = config:get("/dev/gpio/method")=="Poll" and "" or " disabled";
	draw_node(client, config:lookup("/dev/gpio/poll_delay"),false," id='poll_delay'" .. gpio_poll_delay_disabled)
	box_end(client)
	
	if config:get("/dev/touch16/name") ~= "" then
		box_start(client, "miscellaneous", "Touch screen")
		draw_node(client, config:lookup("/dev/touch16/prefix"))
		draw_node(client, config:lookup("/dev/touch16/timeout"))
		draw_node(client, config:lookup("/dev/touch16/keyclick"))
		draw_node(client, config:lookup("/dev/touch16/invert"))
		draw_node(client, config:lookup("/dev/touch16/minimum_click_delay"))
		draw_node(client, config:lookup("/dev/touch16/send_active_keys_only"))
		box_end(client)
	end
	
	form_end(client)
	body_end(client);

end


local function page_log(client, request)
	
	draw_head(client)
	body_begin(client);
	
	local line = 1
	local f = io.popen("logread", "r")
	if f then
		box_start(client, "log", "System log")
		client:add_data("<table class=log>")
		for l in f:lines() do
			-- Jan  1 01:56:38 NEWLAND_CIT user.notice lua: inf webserver: 10.0.0.56: GET /bottom-left.jpg
			--local level, component, msg = l:match("lua: (%S+) (%S-): (.+)")
			-- change above to this when logging should be with time string
			-- also see log.lua (doing syslog)
			local datetime, level, component, msg = l:match("^(%a+%s+%d%d? %d%d:%d%d:%d%d) .*lua: (%S+) (%S-): (.+)")
			if level then
				client:add_data("<tr>")
				client:add_data(" <td class=log-%s>%d</td>" % { level, line } )
				--client:add_data(" <td class=log-%s>%s</td>" % { level, datetime } )
				client:add_data(" <td class=log-%s>%s</td>" % { level, level } )
				client:add_data(" <td class=log-%s>%s</td>" % { level, component } )
				client:add_data(" <td class=log-%s>%s</td>" % { level, to_html_escapes(msg) } )
				client:add_data("</tr>\n")
				client:flush()
				line = line + 1
			end
		end
		client:add_data("</table>")
		f:close()
		box_end(client)
	else
		logf(LG_WRN,lgid,"Could not read the log")
		client:add_data("<table>ERROR: could not read the system log</table>")
	end

	body_end(client);
end


local function page_reboot(client, request)
	
	draw_head(client)
	body_begin(client);

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

	body_end(client);

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
	
	draw_head(client)
	body_begin(client)

	show_page_rebooting( client, [[
		The NQuire is now rebooting. This page will automatically attempt to
		reconnect after 40 seconds. ]], 40 )

	os.execute("reboot")

	body_end(client);

end


local function page_defaults(client, request)
	cit:restore_defaults()
	page_rebooting(client, request)
end


---------------------------------------------------------------------------
-- Handle requests from web server
---------------------------------------------------------------------------

local function on_webserver(client, request)
	
	logf(LG_DBG, lgid, "request.method=%s, request.post_data=%s", request.method, (request.post_data or "nil") )
	local applied_setting;
	local retval = ""

	-- Watch out: this only works as long as the pages do not post binary data 
	if request.method=="POST" and request.post_data then
		string.gsub(request.post_data, "([^&=]+)=([^&;]*)[&;]?", 
			function(name, attr) 
				request.param[webserver.url_decode(name)] = webserver.url_decode(attr) 
			end
		)
	end

	errors = {}
	local skip = {}
	
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
		logf(LG_DBG,lgid,"keyvalue['%s'] = '%s'", key, value)
	end

	-- and special validation for the password
	if keyvalues["/dev/auth/enable"] and keyvalues["/dev/auth/enable"]=="true" then

		-- so this is the misc page with authentication enabled
		local usr = keyvalues["/dev/auth/username"]
		local pwd = keyvalues["/dev/auth/password"]
		local pwd_shadow = keyvalues["/dev/auth/password_shadow"]

		logf(LG_DBG,lgid,"/dev/auth/username=%s, usr=%s, pwd=%s, shadow=%s", config:get("/dev/auth/username"), usr, pwd, pwd_shadow)

		-- skip when nothing is changed:
		if		config:get("/dev/auth/enable") == "true" and 
				usr == config:get("/dev/auth/username") and
				pwd == hidden_password and
				pwd_shadow == pwd then
			logf(LG_DBG,lgid,"Nothing changed to authentication")
			skip["/dev/auth/enable"] = true
			skip["/dev/auth/username"] = true
			skip["/dev/auth/password"] = true
			skip["/dev/auth/password_shadow"] = true
		
		-- reject on incorrect username
		elseif usr == "" or usr:match("^%s") or usr:match("%s$") then
			logf(LG_DBG,lgid,"Incorrect format of username")
			skip["/dev/auth/enable"] = true
			errors["/dev/auth/username"] = true
			skip["/dev/auth/password"] = true
			skip["/dev/auth/password_shadow"] = true

		-- reject on incorrect password entry
		elseif pwd ~= hidden_password and ( pwd ~= pwd_shadow or pwd == "" or pwd:match("\1") ) then
			logf(LG_DBG,lgid,"passwords differs from password shadow, or the password still contains a partial hidden password")
			skip["/dev/auth/enable"] = true
			skip["/dev/auth/username"] = true
			errors["/dev/auth/password"] = true
			errors["/dev/auth/password_shadow"] = true

		-- ignore when user and password are not changed:
		-- this only happens direct after authorisation because the browser will 
		-- re-send the page-request
		elseif usr == config:get("/dev/auth/username") and
				pwd == config:get("/dev/auth/password") then
			logf(LG_DBG,lgid,"usr and password ignore because of page resend")
			keyvalues["/dev/auth/enable"] = nil
			keyvalues["/dev/auth/username"] = nil
			keyvalues["/dev/auth/password"] = nil
			keyvalues["/dev/auth/password_shadow"] = nil
			keyvalues["/dev/auth/encrypted"] = nil
	
		-- accept when passwords are entered:
		elseif pwd ~= hidden_password then
			-- accept entered user and passwords
			local shadow, salt, crypted = encrypt_password( pwd )
			keyvalues["/dev/auth/encrypted"] = escapes_to_binstr( crypted )
		else
			logf(LG_WRN,lgid,"undefined situation for username password")
			errors["/dev/auth/enable"] = true
			errors["/dev/auth/username"] = true
			errors["/dev/auth/password"] = true
			errors["/dev/auth/password_shadow"] = true
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
			if skip[key] then
				-- nothing to do, just skip because of some other error
				logf(LG_DBG,lgid,"Skipped setting of %s because of some other error", key)
			elseif errors[key] then
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

	if applied_setting then
		logf(LG_DBG,lgid,"Applied settings")
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
	client:set_header("Expires", "")
	client:set_header("Cache-control", "no-cache, must-revalidate, proxy-revalidate")
	
	client:add_data([[<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
]])
	client:add_data("<html>\n")
	handler(client, request)
	client:add_data("</html>")

	return retval

end


function new()

	webserver:register("/", on_webserver)
	
end

-- vi: ft=lua ts=3 sw=3
