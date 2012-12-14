LuaQ     @webui.lua           W      A@  ��  ��@@�$   d@  �   �     $�    �   �d G dA GA d� �� � $B     d�     �� �     $C        d�             �  ���          �   �     �  ��             �  �$D             �  �d�       ���       ��     $E   �	d�         �     �     �     �     �   	  �	   
�� �� �   �
��  �       module    Webui    package    seeall 	   humanize 
   box_start    on_upgrade_welcome_image    new           �        K @ �@  \@� �    	   add_data l
  	<head>
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

	        	   �   	   �         client                �   �        � @ A  �@�� @ �  �@�� @ �� �@�� @  �@�� @ A �@� �    	   add_data    <td width=30%>
    <span class=label>
    label 	   </span>
    </td>
        �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         client           node                �   �    �   � � ܀   �   � ��  A  @ ��  A  A �A  ����A��� �    ��� � K� \� Z  ���@  @�KA ����\A�F�� �� � C� �AA ZA    �A� �C� ��A �A    ��� �A J ����bB PB��A��A AB �A��A J ��� bB PB��A��A AB �A�@�F�� ����KA �� �\A�FA� K���� \�@� � �A ZB    �A� �A 
�@ ��� "C����B�aA  ��KA �� \A���F�� ��� �AA G @ �A� G FA� Z  ��FA� K��� \��Z  @���� @H@��� ��HŁ �� �܁ � IA� � ���� �   �G KA �� �E � �A�����\A�� �KA � \A�A ��	 A� � '      full_id    class    node-error    node 	   add_data    <td class=%s>
 	   has_data    get    is_writable )   <input type=hidden name='id' value=%q/>
    type    boolean    false    checked        true 8   <input type='radio' name='set-%s' value='false' %s> No  	   </input> 8   <input type='radio' name='set-%s' value='true' %s> Yes     enum    <select name='set-%s'>
    range    gmatch    ([^,]+) 
    selected     <option value=%q%s>%s</option>
    </select>
    ip_address    size       .@      $@   match    :(%d+)    number    math    floor    log )   <input name='set-%s' size=%d value=%q/>
    </td>     �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         client     �      node     �      ro     �      id    �      value    �      c1 '   A      c2 -   A      (for generator) L   ]      (for state) L   ]      (for control) L   ]      item M   [      sel S   [      tmp p   �         errors     �   �       � @ AA  �@��      @� �@�� �    @� � �@ � @ A�  �@� �    	   add_data    <tr>
    </tr>
        �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         client           node           ro              draw_node_label    draw_node_value     �           K @ �@  �  \�   � K @ ��  $  \�   �    �       gsub    [_]         (.)(.+)        �   �        � @ �� �@� ܀ �� �   �       upper    lower        �   �   �   �   �   �   �         a           b               �   �   �   �   �   �   �   �   �   �   �            s                         � @ AA  �@�� @ A�  � ��  U���@�� @ PA ��@�� @ AA �@� �    	   add_data    <fieldset>
 	   <legend>    </legend>
 )   <input type=hidden name='p' value='%s'>
 	   <table>
                                              client           page           title                
         K @ �@  \@�K @ ��  \@� �    	   add_data 
   </table>
    </fieldset>
                            client                         Z   ��� @ A  @� ��  ��@�� �� @ �  �@� �    	   add_data    <form     >
    <form>
                                        client           extra                         K @ �@  \@�K @ ��  \@�K @ ��  \@�K @ �  \@� �    	   add_data 	   <center> :   <input type='submit' class=submit value='Apply settings'>    </center>
 	   </form>
                                        client                "  (      �   �   �@ � @ A  �@�� @ �  �@�� @ �  �@�� @  �@� �    	   add_data    <table class=top><tr>    <td class=top-left>&nbsp;</td>     <td class=top-right>&nbsp;</td>    </tr></table>
        #  #  #  $  $  $  %  %  %  &  &  &  '  '  '  (        client           request           	   draw_css     *  /      �   �   �@ � @ A  �@�� @ �  �@�� @ �  �@� �    	   add_data    <table class=bottom><tr> "   <td class=bottom-left>&nbsp;</td>    </tr></table>
        +  +  +  ,  ,  ,  -  -  -  .  .  .  /        client           request           	   draw_css     2  H       �   �@@�  �����@�� � A AA � �� U���@� �       config    lookup 
   /dev/name    get 	   add_data    		<html>
		<title>   </title> 
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
	        4  4  4  4  4  4  6  8  8  G  G  6  H        client           request           name               K  W   "   � ��   A  A�  ��  � B A� �@��      �@ ��A A �@��@   �  ��A �� ��� @� �B  ���B��   ���A A �@� �       home    network 	   messages    scanner    miscellaneous    log    reboot 	   add_data    <ul class=menu>    ipairs 5   <li class=menu><a href='?p=%s' target='main'>%s</li> 	   humanize    </ul>
     "   M  M  M  M  M  M  M  M  M  O  O  O  Q  Q  Q  R  R  R  R  S  S  S  S  S  S  S  S  S  R  S  U  U  U  W        client     !      request     !   
   item_list 	   !      (for generator)          (for state)          (for control)          _          item          	   draw_css     Z  e   C   �   �   �@ �   �   A  A�  �@ � � �   �  A�A ��B� �@ � � �   �  A�� ��B� �@ � � �   �  A�� ��@  � � �   �  A� ��@  � � �   �  A�A ��@  � � �   �  A�� ��@  � � �   �  A�� ��@  � � �   �  A� ��@   �    
   box_start    home    Welcome    config    lookup 
   /dev/name    /dev/serial    /dev/version    /dev/rfs_version    /dev/build 
   /dev/date    /dev/scanner/version    /network/macaddress     C   [  [  [  \  \  \  \  \  ]  ]  ]  ]  ]  ]  ]  ]  ^  ^  ^  ^  ^  ^  ^  ^  _  _  _  _  _  _  _  `  `  `  `  `  `  `  a  a  a  a  a  a  a  b  b  b  b  b  b  b  c  c  c  c  c  c  c  d  d  d  d  d  d  d  e        client     B      request     B      	   draw_css 
   draw_node     h  �   �   �   �   �@��  A�  ܀��    ��@�B��� ��    �� � !A  ����A   @  A � @  A �    � @  �A �� A  @  �� �CB ��A  �@  A  @  �� �� A  @  �� �C ��A   @  �� �CB ��A   @  �� �C� ��A  �@  A ��� C�A ���D� A� @  �A �A A  @  �� �C� ��A   @  �� �C� ��A   @  �� �C ��A   @  �� �CB ��A  �@  A  @  �A �� A  @  �� �C� ��A   @  �� �C ��A   @  �� �CB ��A   @  �� �C� ��A  �@  A  @  A  �       io    popen 	   iwconfig    r    lines    match    wlan0    close 
   box_start    network    Network interface    config    lookup    /network/interface    wifi    Wifi    /network/wifi/essid    /network/wifi/keytype    /network/wifi/key    set 	   ethernet    IP Settings    /network/dhcp    /network/ip/address    /network/ip/netmask    /network/ip/gateway    NQuire protocol settings    /cit/udp_port    /cit/tcp_port 
   /cit/mode    /cit/remote_ip     �   l  n  n  n  n  n  o  o  p  p  p  q  q  q  q  q  r  p  s  u  u  x  x  x  y  y  y  {  {  |  |  |  |  |  }  }  }  }  }  }  }  ~  ~  ~  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     �      request     �   
   have_wlan    �      fd    �      (for generator) 
         (for state) 
         (for control) 
         l          	   draw_css    form_start 
   draw_node    box_end 	   form_end     �  �   n   �   �   �@ �  ʀ  �@@���@�
�  	A�	AA��@ �  � A� � �A � A� �@  @ ��EB K��Ƃ@��\���� �  �B � �  C F���B ��D  �B�� ������    ED K��� �@@ �D �Ą�\��C  ��  ����D � �B��� �@� �����D  �C�� �������   EE K��
���@@�� 	�E����\��D  ��  @���D � �C������D C �B���@�@��� �  C �C�� ��B  ���  �B � �  �B !�  @� �       count       @   id    idle        @   error    text    xpos    ypos    valign    halign    size    ipairs    config    lookup    /cit/messages/%s 
   box_start 	   messages    label 	   add_data    <tr>    /cit/messages/%s/1/%s    </tr>       �?   /cit/messages/%s/%s/%s    </table><table>
 %   /cit/messages/idle/show_idle_picture     n   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     m      request     m   	   msg_list    m   	   key_list    m      (for generator)    m      (for state)    m      (for control)    m      _    k      msg    k      node    k      (for generator) *   8      (for state) *   8      (for control) *   8      _ +   6      item +   6      (for index) >   X      (for limit) >   X      (for step) >   X      row ?   W      (for generator) E   T      (for state) E   T      (for control) E   T      _ F   R      item F   R      	   draw_css    form_start    draw_node_label    draw_node_value 
   draw_node    box_end 	   form_end     �  �   X   �   �   �@ � � �   �@ �   �   A  A�  �@ �@  ��@ A���  �   A �A�� ��@  �  �   A �A� ��@  � ��   �@ �@  ��@ A ��   �   A  AA �@ �  �   A �A�� ��@  �  �   A �A�� ��@  �  �   A �A� ��@  � ��   �@ �@  ��@@C���   �   A  A� �@ �  �   A �A�� ��@  � ��   �@ �  �   �@  �    
   box_start    scanner 	   Barcodes    type    2d    config    lookup    /dev/scanner/barcodes    /dev/scanner/enable_barcode_id    Scanning modes Imager    /dev/scanner/illumination_led !   /dev/scanner/reading_sensitivity    /dev/scanner/aiming_led    1d    Scanning modes    /dev/scanner/1d_scanning_mode     X   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     W      request     W      	   draw_css    form_start 
   draw_node    box_end 	   form_end     �  �   p   �   �   �@ � � �   �@ �   �   A  A�  �@ �  �   �  A�A ��@  � ��   �@ �   �   A  A� �@ �  �   �  A�� ��@  �  �   �  A� ��@  �  �   �  A�A ��@  � ��   �@ �   �   A  A� �@ �  �   �  A�� ��@  �  �   �  A� ��@  �  �   �  A�A ��@  � ��   �@ �   �   A  A� �@ �  �   �  A�� ��@  �  �   �  A� ��@  �  �   �  A�A ��@  � ��   �@ �  �   �@  �    
   box_start    miscellaneous    Device    config    lookup 
   /dev/name    Authentication    /dev/auth/enable    /dev/auth/username    /dev/auth/password    Text and messages    /cit/messages/idle/timeout    /cit/messages/error/timeout    /cit/codepage    Interaction    /dev/display/contrast    /dev/beeper/volume    /dev/beeper/beeptype     p   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     o      request     o      	   draw_css    form_start 
   draw_node    box_end 	   form_end          I   �   �   �@ �   �@  ƀ��  A ܀��    �A @  �� �� A B �A A����	���� �  ���B AC �B��B J � � bC PC��B��B J � � bC PC���B��B J � ��bC PC���B��B J � � bC PC���B��B A �B�� @!A  @�B �A A���A � @  A  �          �?   io    popen    logread    r 
   box_start    log    System log 	   add_data    <table class=log>    lines    match    lua: (%S+) (%S-): (.+)    <tr>     <td class=log-%s>%d</td>     <td class=log-%s>%s</td>    </tr>
 	   </table>    close     I                                   	  	  	  
  
  
                                                                                  
                            client     H      request     H      line    H      f 	   H      (for generator)    @      (for state)    @      (for control)    @      l    >      level    >   
   component    >      msg    >      	   draw_css    box_end       1   *   �   �   �@ �   �   A  A�  �@ ��@  �@���@ A �@���@ � �@���@ � �@���@  �@���@ A �@���@ A �@���@ � �@���@ � �@���@  �@�� � �   �@  �    
   box_start    miscellaneous    Device 	   add_data 6   Click the button below to reboot the device: <br><br>    <form> +   <input type=hidden name=p value=rebooting> #   <input type=submit value='Reboot'>    </form> a   <br><br>Click the button below to reset factory default settings and reboot the device: <br><br> *   <input type=hidden name=p value=defaults> %   <input type=submit value='Defaults'>     *            "  "  "  "  "  $  $  $  %  %  %  &  &  &  '  '  '  (  (  (  *  *  *  +  +  +  ,  ,  ,  -  -  -  .  .  .  /  /  /  1        client     )      request     )      	   draw_css    box_end     4  [      �   �   �@ � @ A  �@���  ��@�  �@  �    	   add_data   
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
	    os    execute    reboot        6  6  6  8  X  8  Z  Z  Z  Z  [        client     
      request     
      	   draw_css     ^  e   	   �   �@  �  A�  �@ �  �@A�� �� �@  @�  E� ��  �  �A�  @  �� A� � 	      logf    LG_INF    webui 6   Removing cit.conf to restore factory default settings    os    execute    rm -f cit.conf    LG_WRN    Could not remove cit.conf: %s        _  _  _  _  _  `  `  `  `  a  a  b  b  b  b  b  b  d  d  d  d  e        client           request           ok 	         err 	            page_rebooting     l  �   \   �   �   �   A� � ���@��  ��  @�E KB�� \��Z  ����� ����� � �B  @ ��  ��A�  ���   ���  A A� �� �@ �  �@�A� �� �@ �  �@�A� � �� �@��@ � � � � ���� � � ���� � � ���� � � ���� � � ���� � � ���� �A� AHC�   ����  @ �F�  �F����H � A	 �A ���   � �A� � %      pairs    param    match    ^set%-(.+)    config    lookup    set    logf    LG_DMP    webui %   Initiating cit_idle_msg in 4 seconds    cit    show_message 	   Applying 	   settings    evq    push    cit_idle_msg       @   top    bottom    main    menu    home    network 	   messages    scanner    miscellaneous    log    reboot 
   rebooting 	   defaults    p    set_header    Content-Type    text/html; charset=UTF-8     \   p  p  q  q  q  q  r  r  r  s  s  t  t  t  t  u  u  v  v  v  w  x  x  y  y  q  |      �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     [      request     [      applied_setting     [      (for generator)          (for state)          (for control)          key          val          id 	         node          ok          pagehandlers H   [      p J   [      handler K   [         errors 	   page_top    page_bottom 
   page_main 
   page_menu 
   page_home    page_network    page_messages    page_scanner    page_miscellaneous 	   page_log    page_reboot    page_rebooting    page_defaults     �  �     `      B   �@  ��@�   �� �@   ��  E �A ��    @�A �  � B�� EA � \���� ���  �� C A ���B��  �B  ���B  Ƃ�  ܂ ��  ��� B�� F�C �� 
�F������E� F��C \C E� F��� � � �\C E�  � �C D @�\C�E� K���  AD \C���E� F��� � ��\C E�  � �C � @�\C�B� ^ a�  ��B� ^  �     
   /home/ftp    sys    readdir    logf    LG_WRN    webui     Could not read directory %s: %s    os    time    ipairs    welcome.gif    LG_DMP    installing file %s    /    lstat    isreg    mtime       @   size      j�@   execute    rm -f /cit200/img/welcome.*    mv      /cit200/img/    LG_INF    Installed %s    evq    push    cit_idle_msg            rm -f  5   File %s to large for use as welcome image. max=100kB     `   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        path_ftp_dir    _      upgrade_busy    _      files    _      err    _      now    _      (for generator)    ]      (for state)    ]      (for control)    ]      _    [      file    [   	   filepath $   [      stat (   [      age 0   [           �  �          @@ ��  �   @    @@ ��  �   @   @@ �@ ŀ @   �A �@ � � @� � 	   
   webserver 	   register    /    .+.jpg    evq    upgrade_welcome_image    on_upgrade_welcome_image    push       $@       �  �    	   � � �@@�  ����   @���  � �A @ A܀ �   @��A �� � A AB ���� ��A  C �A A���A  �       path    match    ([^/]+.jpg)    io    open    img/    set_header    Content-Type 
   image/jpg 	   add_data    read    *a 
   set_cache       �@   close        �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client           request           fname          fd              �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �            on_webserver W                  �   �   �   �   �   �   �   �      �             (  (  /  /  H  W  W  e  e  e  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        1  1  1  [  [  e  e  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �     	   draw_css    V      draw_node_label    V      errors    V      draw_node_value 
   V   
   draw_node    V      box_end    V      form_start    V   	   form_end    V   	   page_top    V      page_bottom    V   
   page_main    V   
   page_menu    V   
   page_home    V      page_network $   V      page_messages ,   V      page_scanner 2   V      page_miscellaneous 8   V   	   page_log ;   V      page_reboot >   V      page_rebooting @   V      page_defaults B   V      on_webserver Q   V       