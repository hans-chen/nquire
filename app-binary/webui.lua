LuaQ     @webui.lua           r      A@  ��  ��@@�  A@ �   �@  $�  d�  � �A   �   
  d�       � ��      ��   �   $C � $� � $� d �C �    $�    d �D    �      �$� d      �  �  �      
      �E      �  �  �     �  �        �      �      �  �  �             $�      �  �  �      d       �F       � � ��    $   �dG          �   �     �   	  �	  �
     �     �     �   ��   ��G  � 
      module    Webui    package    seeall    webui     	   humanize 
   box_start    show_page_rebooting    new           �        K @ �@  \@� �    	   add_data k
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
	           �      �         client                �   �        K @ �@  \@� �    	   add_data w  <body>
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
        �   �   �   �         client                �   �        K @ �@  \@� �    	   add_data 	   </body>
        �   �   �   �         client                �   �     
   � @ A  �@�� @ �  F�� � ��@� �    	   add_data    <td width=30%>
    <span class=label>    label 	   </span>
     
   �   �   �   �   �   �   �   �   �   �         client     	      node     	           �   �        K @ �@  \@� �    	   add_data    </td>
        �   �   �   �         client                �   �       �   �    � �@�� � �   �@  �            �   �   �   �   �   �   �   �         client           node              draw_node_label_start    draw_node_label_end     �      �   � � �@    ��@  K�� \� Z  �6�K�� \� �� �� �  �4��@   4��A� �A�����  B���A Ł   A� � ���A  �� ��A �A    ��A  ˁC J� � bB� PB���A�ˁC J�� ��  bB�PB��A�@,��A� �A �@�� ��A �A    ��A   �� ��A �A    ��A  �C ���   @��B����B��C ���  �@��B�����B�@$��A�  E����C 
 @ ��"B ���A���� ��E ��@�@�� ��B �B    ��B  ˂C J����  �bC�PC��B��A  ����C � �A����A�  G ���C 
�@ �� ��"B����A����A� �G� �� �� �	���� �  @��A �� ��� ��E� ������ ���� �� ��  ��� �A  ���A�  I ��A	 ��I�A	 ���� ܁ B	 �IA
 � ���� ������ @ ��
 �� �� Ɓ� �   �Ɓ� ���A ܁��  ��ˁC J�� ΂K�� C  @ �� �KE� ���C D \� ��bB�PB���A� ��� ��B �  � A� �� ܁ �C ���   F�� ZC    �E� �����B�����B�� ���C  ��A� � 4      full_id     	   has_data    get    is_writable    type    boolean    appearance 	   checkbox    logf    LG_DBG    displaying checkbox %s = %s    true    checked 	   add_data 6   <input type='hidden' name='default-%s' value='off'/>
 .   <input type='checkbox' name='set-%s' %s %s/>
    false <   <input type='radio' name='set-%s' value='false' %s %s/> No
 <   <input type='radio' name='set-%s' value='true' %s %s/> Yes
    enum    <select name='set-%s' %s >
    range    gmatch    ([^,]+) 
    selected     <option value=%q%s>%s</option>
    </select>
 	   password >   <input type='password' name='set-%s' size='15' value=%q %s/>
    ip_address    size       .@           (%d+) 	   tonumber    number    math    floor    log       $@      �?   options    find    b ?   <input name='set-%s' maxlength='%d' size='%d' value='%s' %s/>
       @   binstr_to_escapes    gsub    [&']       ?@      p@       
      
    @ � �A@  ^  � ��@ @ �A�  ^   �       '    &#39;    &    &#38;     
                             c     	       �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                                                             	  	  	    	      	                                            client     �      node     �      ro     �      optarg     �      id    �      value    �      is_checked $   2      c1 <   R      c2 B   R      (for generator) a   r      (for state) a   r      (for control) a   r      item b   p      sel h   p      (for generator) �   �      (for state) �   �      (for control) �   �      c �   �      n �   �   
   maxlength �   �      v �   �         lgid    hidden_password       (   
   � � D  F�Z  � �A�  GA  @ �A�  GA  KA �A  ����\A�D� �  ��   @�\A�KA �� \A� �       full_id    class    node-error    node 	   add_data    <td class=%s>
    </td>                             "  "  %  %  %  %  &  &  &  &  &  &  '  '  '  (        client           node           ro           optarg           id             errors    draw_node_value_data     ,  1   
   K@ �A  B   ��  A�  �A�\A�D  �  �� \A�D� �  ��   @�\A�K@ � \A� �    	   add_data    <tr         >
    </tr>
        -  -  -  -  -  -  -  -  .  .  .  .  /  /  /  /  /  /  0  0  0  1        client           node           ro           optarg           tr_arg              draw_node_label    draw_node_value     ;  ?       K @ �@  �  \�   � K @ ��  $  \�   �    �       gsub    [_]         (.)(.+)        =  =       � @ �� �@� ܀ �� �   �       upper    lower        =  =  =  =  =  =  =        a           b               <  <  <  <  <  =  =  =  =  =  >  ?        s                B  G    	   @ �A  �A�  ���  �  �A�@ � � B �A�@ �� A� �    	   add_data    <fieldset         >
 	   <legend>    </legend>
 	   <table>
        C  C  C  C  C  C  C  C  D  D  D  D  D  D  F  F  F  G        client           page           title           extra                I  L       K @ �@  \@�K @ ��  \@� �    	   add_data 
   </table>
    </fieldset>
        J  J  J  K  K  K  L        client                N  T       Z   ��� @ A  @� ��  ��@�� �� @ �  �@� �    	   add_data    <form method='post'     >
    <form method='post'>
        O  O  P  P  P  P  P  P  P  R  R  R  T        client           extra                V  [       K @ �@  \@�K @ ��  \@�K @ ��  \@�K @ �  \@� �    	   add_data 	   <center> ;   <input type='submit' class=submit value='Apply settings'/>    </center>
 	   </form>
        W  W  W  X  X  X  Y  Y  Y  Z  Z  Z  [        client                a  g      �   �   �@ � @ A  �@�� @ �  �@�� @ �  �@�� @  �@� �    	   add_data    <table class=top><tr>    <td class=top-left>&nbsp;</td>     <td class=top-right>&nbsp;</td>    </tr></table>
        b  b  b  c  c  c  d  d  d  e  e  e  f  f  f  g        client           request           	   draw_css     i  n      �   �   �@ � @ A  �@�� @ �  �@�� @ �  �@� �    	   add_data    <table class=bottom><tr> "   <td class=bottom-left>&nbsp;</td>    </tr></table>
        j  j  j  k  k  k  l  l  l  m  m  m  n        client           request           	   draw_css     q  �       �   �@@�  �����@�� � A AA � �� U���@� �       config    lookup 
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
	        s  s  s  s  s  s  u  w  w  �  �  u  �        client           request           name               �  �   "   � ��   A  A�  ��  � B A� �@��      �@ ��A A �@��@   �  ��A �� ��� @� �B  ���B��   ���A A �@� �       home    network 	   messages    scanner    miscellaneous    log    reboot 	   add_data    <ul class=menu>    ipairs 5   <li class=menu><a href='?p=%s' target='main'>%s</li> 	   humanize    </ul>
     "   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     !      request     !   
   item_list 	   !      (for generator)          (for state)          (for control)          _          item          	   draw_css     �  �   J   �   �   �@ �   �   A  A�  �@ � � �   �  A�A ��B� �@ � � �   �  A�� ��B� �@ � � �   �  A�� ��@  � � �   �  A� ��@  � � �   �  A�A ��@  � � �   �  A�� ��@  � � �   �  A�� ��@  � � �   �  A� ��@  � � �   �  A�A ��@   �    
   box_start    home    Welcome    config    lookup 
   /dev/name    /dev/serial    /dev/version    /dev/rfs_version    /dev/build 
   /dev/date    /dev/scanner/version    /network/macaddress    /dev/hardware     J   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     I      request     I      	   draw_css 
   draw_node     �  �          � �A   Z@    �A@  ^   �           style='display:none'        �  �  �  �  �  �  �  �        yes_do                �  �   9  �   �   �@ � � �   �@ �  �   �@ �   �@@�  �����@܀  AA� E K��\� �  ��@�  ���A  � �ZA  @ �W�A@#��    AB �� �A A  @�ZA  ��W�A@���B A � �B U�A���   � �� B    � AB �� Ձ�ZA  @ ��D@ ��@E���A  @ ��E@ ���E�  ���A��@  � �   �B� @  B    	� @  �� � C D�W��  ��C  �� \� CB��@  �  �B@� ��B  �@  �  �B@� ��B  �@  �  �B@ ��B   @  B Z  �� @  �� �B � D�W��  ��C  �� \� CB��@  �  �B@� ��B  �@  �  �B@ ��B  �@  �  �B@C ��B  �@  �  �B@� ��B  �@  �  �B@� ��B   @  B ���    AB �	 �B	 �A���   E  KB���	 \���  ��	 �A���B A
 ���  �B�A�	 ܂����܂ @�@ ���  ��B  �� �� ��
 U�A���   E  KB���
 \��A  ��   E  KB�� \��A  ��   E  KB��B \��A  ��B A� �A��    �A �    AB �� �A �  ���A ܁��@  �  �B@C ����  � K��� \��Z  � �AC ZC    �A� CB��@  �  �B@� ����   @�� �AC ZC    �A� CB��@  �  �B@ ����  � B��@  �  �B@� ����   @�� �AC ZC    �A� CB� @  B  @  B �@  B  � >      config    lookup    /network/interface    get    Network    wlan_is_available    gprs_is_available 	   ethernet 
   box_start    network    Network interface 	   add_data    <span class=label>WATCH OUT:  #    hardware is not detected!</span>
 %   onclick="set_visibility(this.value==    'wifi','wifisettings'    'gprs','gprssettings'    ); 5   set_visibility(this.value!='gprs', 'dhcp_settings')"    gprs    range    ethernet,gprs    wifi    ethernet,wifi    Wifi    id='wifisettings'     /network/wifi/essid    /network/wifi/keytype    /network/wifi/key    Gprs    id='gprssettings'     /network/gprs/pin    /network/gprs/username    /network/gprs/password    /network/gprs/apn    /network/gprs/number    IP Settings    id='dhcp_settings'    /network/dhcp C   onclick='set_visibility(this.value=="false","static_ip_settings")'     <table id='static_ip_settings'     false    >    /network/ip/address    /network/ip/netmask    /network/ip/gateway 	   </table>    NQuire protocol settings 
   /cit/mode    /cit/udp_port    id='udp_port'    find    TCP 
    disabled        /cit/tcp_port    id='tcp_port'    UDP �   onchange="enable_disable(this.value!='UDP','tcp_port');enable_disable(this.value!='TCP server' && this.value!='TCP client' && this.value!='TCP client on scan','udp_port');enable_disable(this.value!='TCP server','remote_ip') "    /cit/remote_ip    id='remote_ip'    TCP server     9  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  	      client     8     request     8  	   itf_node    8  
   ift_value    8  	   has_wlan    8  	   has_gprs    8     itf_config    8     extra :   �      mode �   8     	   draw_css    body_begin    form_start 
   draw_node    box_end    display_by_default 	   form_end 	   body_end       R   �   �   �   �@ � � �   �@ �  ʀ  �@@���@�
�  	A�	AA��@ �  � A� � �A � A� �@  @  A  @ @+�EB K��Ƃ@��\��� �  C F���B ��D  �B�� �������   ED K��� �@@ �D �Ą�\��C  ��  ����D � �B��� �@� �B���D  �C�� ���@�� W�A	@ � B	@	�E F�@� 	��� �
�A	@�E �C
� ƅ@ ��E ������G
W@G
� � �	A� �D
 B	@�E �C
� ƅ@ ��E ������G
W H
� � �	A� �D
@B	@�E F�@� ��� �
�B	@�� F�@�� ��� �
E �C
��ƅ@ �@ 	�E������D �  � 
  @�	\E���  ����D � �C�����@�@ 
���D  �B��B ��CC	 �����   @ �B��    @ �  ��	 �B���   �B �    EC K����	 \���  �
 �B��    EC K���C
 \���  ��
 �B���D A�
 �B���D �
 �B�� �  �B !�  �� @  �A �A ˁ�A ܁�Ɓ�A �@  �A ��CB ��A  �@  �A ��C� ��A   @  A  @  A �D �� A��@  A  � 0      count       @   id    idle        @   error    text    xpos    ypos    valign    halign    size    ipairs    config    lookup    /cit/messages/%s 
   box_start 	   messages    label 	   add_data    <tr>    /cit/messages/%s/1/%s    </tr>       �?       id='    '    /cit/messages/%s/%s/halign    value    left 
    disabled    /cit/messages/%s/%s/valign    top )   onchange='enable_disable(value=="top", "    ")' *   onchange='enable_disable(value=="left", "    /cit/messages/%s/%s/%s     /cit/messages/idle/picture/show i   onclick="enable_disable(this.checked,'xpos');enable_disable(this.checked,'ypos')" id='show_idle_picture'     /cit/messages/idle/picture/xpos 
   id='xpos'     /cit/messages/idle/picture/ypos 
   id='ypos'    </tr>
    /cit/messages/fontsize    /cit/messages/fontsize/small    /cit/messages/fontsize/large �   <script type="text/javascript"> 
	enable_disable(document.getElementById('show_idle_picture').checked, 'xpos');
	enable_disable(document.getElementById('show_idle_picture').checked, 'ypos');
</script> 
     �                             	  
  
  
  
  
  
  
  
                                                                                                                                                              !  !  !  !  !  !  !  !  !  !  !  !  !  "  "  "  %  %  &  &  &  &  &  &  (  (  )  )  )  )  )  )  +  +  +  +  +  +  +  +  +  ,  ,  ,  ,  ,  ,    ,  .  .  .    1  1  1  2  2  2  4  4  4  4  5  5  5  5  6  6  6  6  6  6  7  7  7  9  9  9  9  9  9  9  9  9  :  :  :  :  :  :  :  :  :  <  <  <  ?  ?  ?  @  @  @    @  C  C  C  C  C  C  C  C  C  D  D  D  D  D  D  D  E  E  E  E  E  E  E  F  F  F  H  H  H  J  O  J  Q  Q  Q  R        client     �      request     �   	   msg_list    �   	   key_list    �      (for generator)    �      (for state)    �      (for control)    �      _    �      msg    �      node "   �      (for generator) -   ;      (for state) -   ;      (for control) -   ;      _ .   9      item .   9      (for index) A   �      (for limit) A   �      (for step) A   �      row B   �      (for generator) H   �      (for state) H   �      (for control) H   �      _ I   �      item I   �      extra J   �      node �   �      idle_picture_show �   �      	   draw_css    body_begin    form_start    draw_node_label    draw_node_value    draw_node_label_start    draw_node_value_data    draw_node_label_end    box_end 
   draw_node 	   form_end 	   body_end     T  �   E  �   �   �@ � � �   �@ �  �   �@ �   �   A  A�  �@ �@  ��@ A�
��@ �� � EA  F���EB � \� Z  ��E� ��B\� Z  @�@ � ��C � �̀�!�  @�  A� �@�@  �� �DB ����    A��@  �� �D� ��A  � ��   � D�� ��@  � ��   � D� ��@  �@E � �@��� �@  � �� ���A   ܁ �  @�Ł �B܁ �A   ��� ��A� ��BU��܁��  �� EB � �� �BB��@  ��B�@� E� � � �BB���  ���@  ��@ A@��@ �� � �AA ܀�ƀ���  ��  �� � EA  F� �EB � \� Z  �	�E� ��B\� Z  ��E� K��� �B��\��Z   �� �B  A� ��B�B����   �C �C � @�� ��� @ �C��B ̀�@�� ��  A	 ��B�B�!�   �� ��   �@ �@  ��@ A ��   �   A  AA	 �@ � ��   � D��	 ��@  � ��   � D��	 ��@  � ��   � D�
 ��@  � ��   �@ �@  ��@@J@��   �   A  A�
 �@ � ��   � D��
 ��@  � ��   � D� ��@  � ��   �@ �@ ��K�� �   ���   �   A  A� �@ � ��   � D� ��@  � ��   � D�A ��@  � ��   � D�� ��@  � ��   � D�� ��@  � ��   � D� ��@  � ��   � D�A ��@  � ��   � D�� ��@  � ��   � D�� ��@  � ��   �@ �  �   �@ � ��   �@  � 8   
   box_start    scanner 	   Barcodes    type    em2027 
   onclick='       �?   ipairs    enable_disable    does_firmware_support    is_2d_code    name 1   set_visibility(this.value=="1D and 2D","2d_code_    ");    '    config    lookup    /dev/scanner/barcodes &   /dev/scanner/multi_reading_constraint ,   /dev/scanner/prevent_duplicate_scan_timeout    /dev/scanner/enable_barcode_id 	   add_data #   <tr><td colspan='2'><hr/><td></tr>    /dev/scanner/enable-disable/    logf    LG_DMP    showing code %s    LG_DBG $   Code '%s' is no configuration item.        value    1D only     style='display:none'    id='2d_code_ 	   tostring    LG_WRN )   Code '%s' not found in the configuration    Scanning modes Imager    /dev/scanner/illumination_led !   /dev/scanner/reading_sensitivity    /dev/scanner/aiming_led    em1300    Scanning modes '   /dev/scanner/default_illumination_leds    /dev/scanner/1d_scanning_mode    Scanner_rf    is_available    Mifare scanner    /dev/mifare/key_A    /dev/mifare/relevant_sectors    /dev/mifare/cardnum_format    /dev/mifare/send_cardnum_only    /dev/mifare/sector_data_format +   /dev/mifare/prevent_duplicate_scan_timeout &   /dev/mifare/msg/access_violation/text %   /dev/mifare/msg/incomplete_scan/text     E  V  V  V  W  W  W  X  X  X  Z  Z  Z  Z  Z  [  [  [  [  \  ]  ^  ^  ^  ^  ^  _  _  _  _  _  _  _  _  _  _  `  `  `  `  `  a  ^  b  d  d  d  f  f  f  f  f  f  f  f  f  g  g  g  g  g  g  g  i  i  i  i  i  i  i  k  k  k  k  k  k  k  m  m  m  p  p  p  p  p  q  q  q  q  q  q  q  q  q  q  r  r  r  r  r  r  s  s  t  t  t  t  t  t  u  u  u  u  u  w  w  w  w  w  w  p  y  |  |  |  |  }  ~  ~  ~  ~  ~  ~  ~    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     D     request     D     onof    >      n    >      (for generator)    +      (for state)    +      (for control)    +      _    )      code    )      (for generator) S   y      (for state) S   y      (for control) S   y      _ T   w      code T   w      node d   w      display_style ~   �      n �   �      (for generator) �   �      (for state) �   �      (for control) �   �      _ �   �      code �   �      node �   �      	   draw_css    body_begin    form_start 
   draw_node    lgid    box_end 	   form_end 	   body_end     �  �   -  �   �   �@ � � �   �@ �  �   �@ �   �   A  A�  �@ � ��   �  A�A ��@  �  �   �@ �   �   A  A� �@ � ��   �  A�� ��B  � �@���  � A� ����@B�B� ��� �@    ��  � �   E�  K��A \���  ��   ���@�� �   E�  K��� \���  �   ���@�� �   E�  K��A \���  ��   ���@��     �@ �      AA  �� �@ � �   E�  K�� \��@  � �   E�  K��A \���  �� �@���  � �AA ܀��@���� ��� �@    ��  �@  ��  �A� ����   @�BA� @  A   @  �A  �A A �@  ��  �A� ��A  �@  ��  �A� ��A  �@  ��  �A ��A  �@  ��  �AB ��A   @  A   @  �A  �� A �@  ��  �A� ��A  �@  ��  �A ��A  �@  ��  �AB ��A  �@  ��  �A� ��A   @  A   @  �A  �� A �@  ��  �A	 ��A  �@  ��  �AB	 ����  �	 A��  �I�A	 �� J� �� A    � D��  ��  ��AB
 ܁�  A�
 � U��\A�D �  \A E�  K����
 \��W���
�E  �  �A   \A D��  ��  ��AB ��\A  D��  ��  ��A� ��\A  D��  ��  ��A� ��\A  D��  ��  ��A ��\A  D��  ��  ��AB ��\A  D �  \A D��  \A  � 2   
   box_start    miscellaneous    Device    config    lookup 
   /dev/name    Authentication    /dev/auth/enable �   onclick="enable_disable(value=='true', 'auth_username');enable_disable(value=='true', 'auth_password');enable_disable(value=='true', 'auth_password_shadow')"    value    true     
    disabled    /dev/auth/username     id='auth_username'    /dev/auth/password     id='auth_password'    /dev/auth/password_shadow     id='auth_password_shadow'    Programming barcode security    /cit/programming_mode_timeout    /dev/barcode_auth/enable 9   onclick="enable_disable(value=='true', 'security_code')"     /dev/barcode_auth/security_code     id='security_code'    Text and messages    /cit/messages/idle/timeout    /cit/messages/error/timeout    /cit/codepage    /cit/message_separator    Interaction    /dev/display/contrast    /dev/beeper/volume    /dev/beeper/beeptype    /cit/disable_scan_beep    GPIO    /dev/gpio/prefix    /dev/gpio/method :   onclick="enable_disable(this.value=='Poll','poll_delay')"    get    Poll    /dev/gpio/poll_delay     id='poll_delay'    /dev/touch16/name    Touch screen    /dev/touch16/prefix    /dev/touch16/timeout    /dev/touch16/keyclick !   /dev/touch16/minimum_click_delay #   /dev/touch16/send_active_keys_only     -  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     ,     request     ,     extra 1   ,     extra u   ,     gpio_poll_delay_disabled �   ,     	   draw_css    body_begin    form_start 
   draw_node    box_end 	   form_end     �     I   �   �   �@ �   �@  ƀ��  A ܀��    �A @  �� �� A B �A A����	���� �  ���B AC �B��B J � � bC PC��B��B J � � bC PC���B��B J � ��bC PC���B��B J � � bC PC���B��B A �B�� @!A  @�B �A A���A � @  A  �          �?   io    popen    logread    r 
   box_start    log    System log 	   add_data    <table class=log>    lines    match    lua: (%S+) (%S-): (.+)    <tr>     <td class=log-%s>%d</td>     <td class=log-%s>%s</td>    </tr>
 	   </table>    close     I   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                                                                           �    
  
  
                    client     H      request     H      line    H      f 	   H      (for generator)    @      (for state)    @      (for control)    @      l    >      level    >   
   component    >      msg    >      	   draw_css    box_end       $   *   �   �   �@ �   �   A  A�  �@ ��@  �@���@ A �@���@ � �@���@ � �@���@  �@���@ A �@���@ A �@���@ � �@���@ � �@���@  �@�� � �   �@  �    
   box_start    miscellaneous    Device 	   add_data 6   Click the button below to reboot the device: <br><br>    <form method='post'> +   <input type=hidden name=p value=rebooting> #   <input type=submit value='Reboot'>    </form> a   <br><br>Click the button below to reset factory default settings and reboot the device: <br><br> *   <input type=hidden name=p value=defaults> %   <input type=submit value='Defaults'>     *                                                                            !  !  !  "  "  "  $        client     )      request     )      	   draw_css    box_end     &  F    
	   � @ AA  �� ��    A�  UA��@� �    	   add_data h   
			<meta http-equiv='refresh' content="30; url=javascript:window.open('/','_top');">

			<br><br><br>  G  <br><br>

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
				progressbar(0,      );
			</script>
		     	   '  +  +  C  C  E  E  '  F        client           intro           delay                H  Z      �   �   �@ �   �@@�   ����  ��   AA �@ �� �   � A �@  ��� �   A A� �@ �� � C�@ �@  �       Upgrade    upgrade_busy    logf    LG_INF    upgrade    Upgrade in progress    show_page_rebooting �   			The NQuire is currently upgrading its software. A reboot will be
			performed after the upgrade. This page will automatically attempt to
			reconnect after 100 seconds.        Y@h   			The NQuire is now rebooting. This page will automatically attempt to
			reconnect after 40 seconds.        D@   os    execute    reboot        J  J  J  L  L  L  L  M  M  M  M  M  O  O  R  R  O  R  T  T  V  V  T  X  X  X  X  Z        client           request           	   draw_css     ]  `      �   �@@�@ �   �    � �@� �       cit    restore_defaults        ^  ^  ^  _  _  _  _  `        client           request              page_rebooting     g     ?  �   �@    A�  ��� �� �A    ��A �@ �  �� � BA   <��� @B@��   ��� �BF� � �    � A 
  � 
  EA ��� \����C ����   ��B  �܂ 	� ���CA� ܂��  ���� A� ��U��CC    �	�a�  ��EA � \���  �B    AC � ���B a�  ��F�EZ  @�F�E����FF�AFƁF� G�� ��W E@�� G� ��W � � W @��� �W��@ ��A@�  EB �  �� B � 	�G�� 	�ǌ� 	�G�� 	�G���� G� �� ���� G�B �� @�	H�	H�	Ȍ	H�	Ȑ � W @�� @ �B   ܂ 	���@�F�E �� �	���	���	�A�EA � \���� ��H  ����  @��I@�@�ƂI��� �W �  �A� �� ���  ���  C D  �
 � �B�@��G܂ W@�@�CJ����C  ��  E�
 �  ��
   KG\� ��C�� 	�G �  EC �  �   @���C�� � a�  @��   ��E  �A �  B \A E� K���  AB \A�E� K���� C�\A�E� KA��� � \A E� K���  AB \A�FAHZ   �FAHW��@�E  �A �  � \A �� 
A D�	A�D 	A��D�	A�D 	A��D�	A�D 	A��D�	A�D 	A��D�	A�D 	A��D�	A�D 	A��D�	A�F�� FA�� �� ���  @ �� ��Z   ��A�  @ ��A  ���OˁR A� � �A ˁR AB �� �A ˁR A� �� �A �    @� �A��   � P      logf    LG_DMP (   request.method=%s, request.post_data=%s    method 
   post_data    nil        Upgrade    upgrade_busy    POST    string    gsub    ([^&=]+)=([^&;]*)[&;]?    pairs    param    match    ^set%-(.+)$    escapes_to_binstr    ^default%-(.+)$    set-    false    keyvalue['%s'] = '%s'    /dev/auth/enable    true    /dev/auth/username    /dev/auth/password    /dev/auth/password_shadow    config    get    LG_DBG ?   password is not entered but authentication or user is changed.     /dev/auth/encrypted    encrypt_password    lookup    type    boolean    appearance 	   checkbox #   Webui data entry error on field %s    set    LG_WRN (   Error setting node %s from '%s' to '%s' "   changed node %s from '%s' to '%s'    Applied settings    evq    push    apply_settings       �   display 	   set_font       2@   show_message 	   Applying 	   settings    cit_idle_msg       @   Requesting authorisation    Authorization    top    bottom    main    menu    home    network 	   messages    scanner    miscellaneous    log    reboot 
   rebooting 	   defaults    p    set_header    Content-Type    text/html; charset=UTF-8    Expires    Cache-control ,   no-cache, must-revalidate, proxy-revalidate        q  s      �   � @�@  ƀ�   ܀ A  �@@� � � � �       param 
   webserver    url_decode        r  r  r  r  r  r  r  r  r  r  r  s        name           attr              request ?  i  i  i  i  i  i  i  i  i  i  j  k  m  m  m  m  o  o  o  o  o  o  p  p  p  p  s  s  p  w  w  z  {  {  {  {  |  |  |  }  }  ~  ~  ~  ~  ~  �  �  �  �  �  �  �  �  �  �  �  �  �  {  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �    !      client     >     request     >     applied_setting    >     retval    >  
   keyvalues          (for generator) #   =      (for state) #   =      (for control) #   =      key $   ;      val $   ;      id '   ;      cb_id 1   ;      (for generator) @   J      (for state) @   J      (for control) @   J      key A   H      value A   H      usr Q   �      pwd R   �      pwd_shadow S   �      shadow �   �      salt �   �      crypted �   �      (for generator) �   �      (for state) �   �      (for control) �   �      key �   �      value �   �      node �   �      prev_value �   �      pagehandlers   >     p   >     handler   >        lgid    errors    hidden_password 	   page_top    page_bottom 
   page_main 
   page_menu 
   page_home    page_network    page_messages    page_scanner    page_miscellaneous 	   page_log    page_reboot    page_rebooting    page_defaults                 @@ ��  �   @    @@ ��  �   @  �    
   webserver 	   register    /    .+.jpg              	   � � �@@�  ����   @���  � �A @ A܀ �   @��A �� � A AB ���� ��A  C �A A���A  �       path    match    ([^/]+.jpg)    io    open    img/    set_header    Content-Type 
   image/jpg 	   add_data    read    *a 
   set_cache       �@   close        	  	  	  	  
  
                                                      client           request           fname          fd                                              on_webserver r                        �   �   �   �   �   �   �   �   �         (  (  (  1  1  1  ?  ;  G  B  L  T  [  g  g  n  n  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  R  R  R  R  R  R  R  R  R  R  R  R  R  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        $  $  $  F  &  Z  Z  `  `                                                  lgid    q      hidden_password    q   	   draw_css    q      body_begin 	   q   	   body_end 
   q      draw_node_label_start    q      draw_node_label_end    q      draw_node_label    q      errors    q      draw_node_value_data    q      draw_node_value    q   
   draw_node    q      box_end    q      form_start    q   	   form_end     q   	   page_top "   q      page_bottom $   q   
   page_main %   q   
   page_menu '   q   
   page_home *   q      display_by_default +   q      page_network 4   q      page_messages A   q      page_scanner J   q      page_miscellaneous Q   q   	   page_log T   q      page_reboot W   q      page_rebooting [   q      page_defaults ]   q      on_webserver n   q       