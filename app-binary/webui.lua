LuaQ     @webui.lua            y      A@  ��  ��@@�  A@ �   �@  $�  d�  � �A $�      �J  ��   �      � �   �   $C      �d� G� d� G� d �C � $�    d    �D �    $�          d �E      �        �  �
  �   �      �        �        �  �     �   $�      �            �  �   d      �        �  �   �F      �   �      �   $�  $       dG    ��       �  �      �   	  �	   
     �     �     �     ���    �G  � 
      module    Webui    package    seeall    webui     	   humanize 
   box_start    show_page_rebooting    new            �        K @ �@  \@� �    	   add_data �
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
	
	<STYLE TYPE="text/css">
		<!--
		#dek {POSITION:absolute;VISIBILITY:hidden;Z-INDEX:200;}
		//-->
	</STYLE>

	</head>
	           �      �         client                �   �        K @ �@  \@� �    	   add_data L  <body>
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

        �   �   �   �         client                �   �        K @ �@  \@� �    	   add_data 	   </body>
        �   �   �   �         client                �       	   � @ A  @� ��  �d  �  �    �       gsub    [    ]        �        	   A   �@  ��@�   �� ��  U�� ^   �       &#    string    byte    ;     	   �   �   �   �   �   �   �   �            c            	   �   �   �   �   �      �              value           esc                  
    
   � @ A  �@�� @ �  F�� � ��@� �    	   add_data    <td width=30%>
    <span class=label>    label 	   </span>
     
         	  	  	  	  	  	  
        client     	      node     	                    K @ �@  \@� �    	   add_data    </td>
                      client                        �   �    � �@�� � �   �@  �                                  client           node              draw_node_label_start    draw_node_label_end       ^   �   � � �@    ��@  K�� \� Z  �<�K�� \� �� �� �  �:��@   :��A  �A ��� �   ��  Ɓ� � ����   AB �A��A ��� �B���� @C ��� �� � A � ���A @�� ��� �A    ��A  ��D J� � bB� PB��A���D J � ��  EC bB PB���A��.���� �B����� ��� �A    ��A  @�� ��� �A    ��A  �D � �   @��C �B ����B��D � �  �@��C �B ���B� &���� @F ���D 
�@ ���B "B���A���� �GB ��@�@�� ��� �B    ��B  ��D J����  �bC�PC���B��A  ����D  �A� ���� @H@���D 
 @ � ��C "B ��A������ �H� ��A	 �	 @
���� W�I 	���� �  @���	 �	 ��� �G
 �����B
 ���� �	 ��  ��	 �A  ����� �J ���
 �K��
 �A�	 ܁ �
 BKA� � ���� �����	 @ ��� �	 �	 �� �  @��� �A�A� ܁��  ����D J � �M� C  @ �	 MEC ����	 �	 \� ���C bB PB���A�@��A   @��� ��A� � ܁ �D � �   F� ZC    �E	 ����D �B ����B�� ���D  ��A� � 9      full_id     	   has_data    get    is_writable    popup    comment    "'    onMouseOver="popup(' &   ','lightgreen')"; onMouseOut="kill()"    type    boolean    appearance 	   checkbox    logf    LG_DBG    displaying checkbox %s = %s    true    checked 	   add_data 6   <input type='hidden' name='default-%s' value='off'/>
 1   <input type='checkbox' name='set-%s' %s %s %s/>
    false ?   <input type='radio' name='set-%s' value='false' %s %s %s/> No
 ?   <input type='radio' name='set-%s' value='true' %s %s %s/> Yes
    enum    <select name='set-%s' %s %s>
    range    gmatch    ([^,]+) 
    selected     <option value=%q%s>%s</option>
    </select>
 	   password A   <input type='password' name='set-%s' size='15' value=%q %s %s/>
    ip_address    size       .@   custom            (%d+) 	   tonumber    number    math    floor    log       $@      �?   options    find    b B   <input name='set-%s' maxlength='%d' size='%d' value='%s' %s %s/>
       @   binstr_to_escapes    &\'"       ?@      p@    �                                     !  !  "  "  "  #  #  #  #  $  $  $  $  $  )  )  )  )  )  )  *  *  *  *  *  *  *  +  +  +  +  +  +  ,  ,  ,  ,  ,  ,  -  -  -  -  -  -  -  -  -  -  .  .  .  /  /  /  /  /  /  0  0  0  0  0  0  1  1  1  1  1  1  1  1  1  2  2  2  2  2  2  2  2  2  2  3  3  3  4  4  4  4  4  4  4  4  5  5  5  5  5  6  6  6  6  6  6  7  7  7  7  7  7  7  7  5  7  9  9  9  9  :  :  :  <  <  <  <  <  <  <  <  <  <  >  >  >  ?  ?  ?  @  @  @  @  @  @  A  A  B  B  B  B  B  C  C  C  D  D  D  D  B  D  F  F  F  G  G  G  G  G  G  G  G  G  G  G  G  G  G  H  J  J  L  M  M  M  M  M  M  M  M  M  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  P  T  T  T  T  T  T  T  T  V  V  V  V  V  V  V  V  V  V  V  V  V  V  X  [  [  [  ^        client     �      node     �      ro     �      optarg     �      id    �      value    �      html_comment          is_checked 2   A      c1 K   c      c2 Q   c      (for generator) s   �      (for state) s   �      (for control) s   �      item t   �      sel z   �      (for generator) �   �      (for state) �   �      (for control) �   �      c �   �      n �   �   
   maxlength �   �      v �   �         to_html_escapes    lgid    hidden_password     a  l   
   � � D  F�Z  � �A�  GA  @ �A�  GA  KA �A  ����\A�D� �  ��   @�\A�KA �� \A� �       full_id    class    node-error    node 	   add_data    <td class=%s>
    </td>        b  b  c  c  c  c  d  d  d  f  f  i  i  i  i  j  j  j  j  j  j  k  k  k  l        client           node           ro           optarg           id             errors    draw_node_value_data     p  u   
   K@ �A  B   ��  A�  �A�\A�D  �  �� \A�D� �  ��   @�\A�K@ � \A� �    	   add_data    <tr         >
    </tr>
        q  q  q  q  q  q  q  q  r  r  r  r  s  s  s  s  s  s  t  t  t  u        client           node           ro           optarg           tr_arg              draw_node_label    draw_node_value       �       K @ �@  �  \�   � K @ ��  $  \�   �    �       gsub    [_]         (.)(.+)        �  �       � @ �� �@� ܀ �� �   �       upper    lower        �  �  �  �  �  �  �        a           b               �  �  �  �  �  �  �  �  �  �  �  �        s                �  �    	   @ �A  �A�  ���  �  �A�@ � � B �A�@ �� A� �    	   add_data    <fieldset         >
 	   <legend>    </legend>
 	   <table>
        �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client           page           title           extra                �  �       K @ �@  \@�K @ ��  \@� �    	   add_data 
   </table>
    </fieldset>
        �  �  �  �  �  �  �        client                �  �       Z   ��� @ A  @� ��  ��@�� �� @ �  �@� �    	   add_data    <form method='post'     >
    <form method='post'>
        �  �  �  �  �  �  �  �  �  �  �  �  �        client           extra                �  �       K @ �@  \@�K @ ��  \@�K @ ��  \@�K @ �  \@� �    	   add_data 	   <center> ;   <input type='submit' class=submit value='Apply settings'/>    </center>
 	   </form>
        �  �  �  �  �  �  �  �  �  �  �  �  �        client                �  �      �   �   �@ � @ A  �@�� @ �  �@�� @ �  �@�� @  �@� �    	   add_data    <table class=top><tr>    <td class=top-left>&nbsp;</td>     <td class=top-right>&nbsp;</td>    </tr></table>
        �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client           request           	   draw_css     �  �      �   �   �@ � @ A  �@�� @ �  �@�� @ �  �@� �    	   add_data    <table class=bottom><tr> "   <td class=bottom-left>&nbsp;</td>    </tr></table>
        �  �  �  �  �  �  �  �  �  �  �  �  �        client           request           	   draw_css     �  �       �   �@@�  �����@�� � A AA � �� U���@� �       config    lookup 
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
	        �  �  �  �  �  �  �  �  �  �  �  �  �        client           request           name               �  �   "   � ��   A  A�  ��  � B A� �@��      �@ ��A A �@��@   �  ��A �� ��� @� �B  ���B��   ���A A �@� �       home    network 	   messages    scanner    miscellaneous    log    reboot 	   add_data    <ul class=menu>    ipairs 5   <li class=menu><a href='?p=%s' target='main'>%s</li> 	   humanize    </ul>
     "   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     !      request     !   
   item_list 	   !      (for generator)          (for state)          (for control)          _          item          	   draw_css     �  �   M   �   �   �@ �   �   A  A�  �@ � � �   �  A�A ��B� �@ � � �   �  A�� ��B� �@ � � �   �  A�� ��@  � � �   �  A� ��@  � � �   �  A�A ��@  � � �   �  A�� ��@  � � �   �  A�� ��@  � � �   �  A� ��@  � � �   �  A�A ��@  �  �   �@  �    
   box_start    home    Welcome    config    lookup 
   /dev/name    /dev/serial    /dev/version    /dev/rfs_version    /dev/build 
   /dev/date    /dev/scanner/version    /network/macaddress    /dev/hardware     M   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     L      request     L      	   draw_css 
   draw_node 	   body_end     �  �          � �A   Z@    �A@  ^   �           style='display:none'        �  �  �  �  �  �  �  �        yes_do                �  D   G  �   �   �@ � � �   �@ �  �   �@ �   �@@�  �����@܀  AA� E K��\� �  ��@�  ���A  � �ZA  @ �W�A@#��    AB �� �A A  @�ZA  ��W�A@���B A � �B U�A���   � �� B    � AB �� Ձ�ZA  @ ��D@ ��@E���A  @ ��E@ ���E�  ���A��@  � �   �B� @  B    	� @  �� � C D�W��  ��C  �� \� CB��@  �  �B@� ��B  �@  �  �B@� ��B  �@  �  �B@ ��B   @  B Z  �� @  �� �B � D�W��  ��C  �� \� CB��@  �  �B@� ��B  �@  �  �B@ ��B  �@  �  �B@C ��B  �@  �  �B@� ��B  �@  �  �B@� ��B   @  B ���    AB �	 �B	 �A���   E  KB���	 \���  ��	 �A���B A
 ���  �B�A�	 ܂����܂ @�@ ���  ��B  �� �� ��
 U�A���   E  KB���
 \��A  ��   E  KB�� \��A  ��   E  KB��B \��A  ��   E  KB��� \��A  ��   E  KB��� \��A  ��B A �A��    �A �    AB �B �A �  ���A� ܁��@  �  �B@� ����   KC��� \��Z  � �A� ZC    �A CB��@  �  �B@C ����  � ��� �A� ZC    �A CB��@  �  �B@� ����   B��@  �  �B@C ����  � ��� �A� ZC    �A CB� @  B  @  B �@  B  � @      config    lookup    /network/interface    get    Network    wlan_is_available    gprs_is_available 	   ethernet 
   box_start    network    Network interface 	   add_data    <span class=label>WATCH OUT:  #    hardware is not detected!</span>
 %   onclick="set_visibility(this.value==    'wifi','wifisettings'    'gprs','gprssettings'    ); 5   set_visibility(this.value!='gprs', 'dhcp_settings')"    gprs    range    ethernet,gprs    wifi    ethernet,wifi    Wifi    id='wifisettings'     /network/wifi/essid    /network/wifi/keytype    /network/wifi/key    Gprs    id='gprssettings'     /network/gprs/pin    /network/gprs/username    /network/gprs/password    /network/gprs/apn    /network/gprs/number    IP Settings    id='dhcp_settings'    /network/dhcp C   onclick='set_visibility(this.value=="false","static_ip_settings")'     <table id='static_ip_settings'     false    >    /network/ip/address    /network/ip/netmask    /network/ip/gateway    /network/ip/ns1    /network/ip/ns2 	   </table>    NQuire protocol settings 
   /cit/mode    /cit/udp_port    id='udp_port'    find    TCP 
    disabled        /cit/tcp_port    id='tcp_port'    UDP �   onchange="enable_disable(this.value!='UDP','tcp_port');enable_disable(this.value!='TCP server' && this.value!='TCP client' && this.value!='TCP client on scan','udp_port');enable_disable(this.value!='TCP server','remote_ip') "    /cit/remote_ip    id='remote_ip'    TCP server     G  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                                                                     	  	  
  
  
  
                                                                                                                                                                                       !  !  !  !  !  !  !  "  "  "  "  "  "  "  #  #  #  $  *  *  *  *  *  *  +  +  +  +  +  +  +  +  +  ,  ,  -  -  -  -  -  -  -  -  -  .  .  .  .  -  .  .  ,  /  /  /  /  /  /  /  0  0  0  0  0  0  0  1  1  1  1  1  1  1  2  2  2  2  2  2  2  3  3  3  3  3  3  3  4  4  4  5  5  5  7  7  7  7  7  8  8  8  8  9  9  9  9  9  9  9  9  :  :  :  :  :  :  :  :  :  :  9  ;  ;  ;  ;  ;  ;  ;  ;  <  <  <  <  <  <  <  ;  =  =  =  =  =  =  =  =  =  >  >  >  >  >  >  >  >  ?  ?  ?  ?  ?  ?  ?  >  @  @  @  B  B  B  C  C  C  D  	      client     F     request     F  	   itf_node    F  
   ift_value    F  	   has_wlan    F  	   has_gprs    F     itf_config    F     extra :   �      mode   F     	   draw_css    body_begin    form_start 
   draw_node    box_end    display_by_default 	   form_end 	   body_end     I  �   �   �   �   �@ � � �   �@ �  ʀ  �@@���@�
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
     �   J  J  J  K  K  K  M  M  N  N  N  O  O  P  Q  Q  Q  Q  Q  Q  Q  Q  S  S  S  U  U  U  U  W  W  W  W  W  X  X  X  X  X  Z  Z  Z  [  [  [  [  \  \  \  \  \  \  \  \  \  \  \  [  \  ^  ^  ^  _  _  _  _  `  `  `  a  a  a  a  b  c  c  c  c  d  d  d  d  d  d  e  e  e  e  e  e  e  e  e  e  e  e  e  f  f  f  h  h  h  h  h  h  h  h  h  h  h  h  h  i  i  i  l  l  m  m  m  m  m  m  o  o  p  p  p  p  p  p  r  r  r  r  r  r  r  r  r  s  s  s  s  s  s  a  s  u  u  u  _  x  x  x  y  y  y  {  {  {  {  |  |  |  |  }  }  }  }  }  }  ~  ~  ~  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  U  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client     �      request     �   	   msg_list    �   	   key_list    �      (for generator)    �      (for state)    �      (for control)    �      _    �      msg    �      node "   �      (for generator) -   ;      (for state) -   ;      (for control) -   ;      _ .   9      item .   9      (for index) A   �      (for limit) A   �      (for step) A   �      row B   �      (for generator) H   �      (for state) H   �      (for control) H   �      _ I   �      item I   �      extra J   �      node �   �      idle_picture_show �   �      	   draw_css    body_begin    form_start    draw_node_label    draw_node_value    draw_node_label_start    draw_node_value_data    draw_node_label_end    box_end 
   draw_node 	   form_end 	   body_end     �      b  �   �   �@ � � �   �@ �  �   �@ �   �   A  A�  �@ �@  ��@ A�
��@ �� � EA  F���EB � \� Z  ��E� ��B\� Z  @�@ � ��C � �̀�!�  @�  A� �@�@  �� �DB ����    A��@  �� �D� ��A  � ��   � D�� ��@  � ��   � D� ��@  �@E � �@��� �@  � �� ���A   ܁ �  @�Ł �B܁ �A   ��� ��A� ��BU��܁��  �� EB � �� �BB��@  ��B�@� EB � �� �BB���  ���@  ��@ A@��  �� � �AA ܀��@���  ��� �� � EA  F� �EB � \� Z  �	�E� ��B\� Z  ��E� K��� �B��\��Z   �� �B  A� ��B�B����   �C � D @�� ��� @ �C��B ̀�@�� ł  A� ��B�B�!�   �� ��   �@ �@  ��@ A ��   �   A  A	 �@ � ��   � D�A	 ��@  � ��   � D��	 ��@  � ��   � D��	 ��@  � ��   �@ �@  ��@ J@��   �   A  AA
 �@ � ��   � D��
 ��@  � ��   � D��
 ��@  � ��   �@ �   �    AA �@ � ��   � D�� ��@  � ��   �@ �� � L�� �   @��   �   A  AA �@ � ��   � D�� ��@  � ��   � D�� ��@  � ��   � D� ��@  � ��   � D�A ��@  � ��   � D�� ��@  � ��   � D�� ��@  � ��   � D� ��@  � ��   � D�A ��@  � ��   � D�� ��@  � ��   � D�� ��@  � ��   �@ �  �   �@ � ��   �@  � <   
   box_start    scanner 	   Barcodes    type    em2027 
   onclick='       �?   ipairs    enable_disable    does_firmware_support    is_2d_code    name 1   set_visibility(this.value=="1D and 2D","2d_code_    ");    '    config    lookup    /dev/scanner/barcodes &   /dev/scanner/multi_reading_constraint ,   /dev/scanner/prevent_duplicate_scan_timeout    /dev/scanner/enable_barcode_id 	   add_data #   <tr><td colspan='2'><hr/><td></tr>    /dev/scanner/enable-disable/    logf    LG_DBG    showing code %s $   Code '%s' is no configuration item.        value    1D only     style='display:none'    id='2d_code_ 	   tostring    LG_WRN )   Code '%s' not found in the configuration    Scanning modes Imager    /dev/scanner/illumination_led !   /dev/scanner/reading_sensitivity    /dev/scanner/aiming_led    em1300    Scanning modes '   /dev/scanner/default_illumination_leds    /dev/scanner/1d_scanning_mode    extscanner    External scanner    /dev/extscanner/raw    Scanner_rf    is_available    Mifare scanner    /dev/mifare/key_A    /dev/mifare/relevant_sectors    /dev/mifare/cardnum_format    /dev/mifare/send_cardnum_only    /dev/mifare/sector_data_format "   /dev/mifare/sector_data_seperator +   /dev/mifare/prevent_duplicate_scan_timeout &   /dev/mifare/msg/access_violation/text %   /dev/mifare/msg/incomplete_scan/text *   /dev/mifare/msg/transaction_error_message     b  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �           client     a     request     a     onof    >      n    >      (for generator)    +      (for state)    +      (for control)    +      _    )      code    )      (for generator) S   y      (for state) S   y      (for control) S   y      _ T   w      code T   w      node d   w      display_style ~   �      n �   �      (for generator) �   �      (for state) �   �      (for control) �   �      _ �   �      code �   �      node �   �      	   draw_css    body_begin    form_start 
   draw_node    lgid    box_end 	   form_end 	   body_end       ?   >  �   �   �@ � � �   �@ �  �   �@ �   �   A  A�  �@ � ��   �  A�A ��@  �  �   �@ �   �   A  A� �@ � ��   �  A�� ��B  � �@���  � A� ����@B�B� ��� �@    ��  � �   E�  K��A \���  ��   ���@�� �   E�  K��� \���  �   ���@�� �   E�  K��A \���  ��   ���@��     �@ �      AA  �� �@ � �   E�  K�� \��@  � �   E�  K��A \���  �� �@���  � �AA ܀��@���� ��� �@    ��  �@  ��  �A� ����   @�BA� @  A   @  �A  �A A �@  ��  �A� ��A  �@  ��  �A� ��A  �@  ��  �A ��A  �@  ��  �AB ��A  �@  ��  �A� ��A   @  A   @  �A  �� A �@  ��  �A ��A  �@  ��  �AB ��A  �@  ��  �A� ��A  �@  ��  �A� ��A   @  A   @  �A  �	 A �@  ��  �AB	 ��A  �@  ��  �A�	 ����  �	 A��  J��	 ��@J� �� A    � D��  ��  ��A�
 ܁�  A�
 � U��\A�D �  \A E�  K�� \��W��@�E  �  �A  B \A D��  ��  ��A� ��\A  D��  ��  ��A� ��\A  D��  ��  ��A ��\A  D��  ��  ��AB ��\A  D��  ��  ��A� ��\A  D��  ��  ��A� ��\A  D �  \A D��  \A D �  \A  � 4   
   box_start    miscellaneous    Device    config    lookup 
   /dev/name    Authentication    /dev/auth/enable �   onclick="enable_disable(value=='true', 'auth_username');enable_disable(value=='true', 'auth_password');enable_disable(value=='true', 'auth_password_shadow')"    value    true     
    disabled    /dev/auth/username     id='auth_username'    /dev/auth/password     id='auth_password'    /dev/auth/password_shadow     id='auth_password_shadow'    Programming barcode security    /cit/programming_mode_timeout    /dev/barcode_auth/enable 9   onclick="enable_disable(value=='true', 'security_code')"     /dev/barcode_auth/security_code     id='security_code'    Text and messages    /cit/messages/idle/timeout    /cit/messages/error/timeout    /cit/codepage    /cit/message_separator    /cit/message_encryption    Interaction    /dev/display/contrast    /dev/beeper/volume    /dev/beeper/beeptype    /cit/disable_scan_beep    GPIO    /dev/gpio/prefix    /dev/gpio/method :   onclick="enable_disable(this.value=='Poll','poll_delay')"    get    Poll    /dev/gpio/poll_delay     id='poll_delay'    /dev/touch16/name    Touch screen    /dev/touch16/prefix    /dev/touch16/timeout    /dev/touch16/keyclick    /dev/touch16/invert !   /dev/touch16/minimum_click_delay #   /dev/touch16/send_active_keys_only     >                              	  	  	  	  	  	  	  
  
  
                                                                                                                                                                                                                                                                                                               !  !  !  #  #  #  #  #  $  $  $  $  $  $  $  %  %  %  %  %  %  %  &  &  &  &  &  &  &  '  '  '  '  '  '  '  (  (  (  *  *  *  *  *  +  +  +  +  +  +  +  ,  ,  ,  ,  ,  ,  ,  ,  ,  -  -  -  -  -  -  -  -  -  -  .  .  .  .  .  .  .  .  .  .  .  /  /  /  1  1  1  1  1  1  2  2  2  2  2  3  3  3  3  3  3  3  4  4  4  4  4  4  4  5  5  5  5  5  5  5  6  6  6  6  6  6  6  7  7  7  7  7  7  7  8  8  8  8  8  8  8  9  9  9  <  <  <  =  =  =  ?        client     =     request     =     extra 1   =     extra u   =     gpio_poll_delay_disabled �   =     	   draw_css    body_begin    form_start 
   draw_node    box_end 	   form_end 	   body_end     A  a   L   �   �   �@ �   �@  ƀ��  A ܀��    �A @  �� �� A B �A A����	���� �  ���B AC �B��B J � � bC PC��B��B J � � bC PC���B��B J � ��bC PC���B��B J � � bC PC���B��B A �B�� @!A  @�B �A A���A � @  A  @  A  �          �?   io    popen    logread    r 
   box_start    log    System log 	   add_data    <table class=log>    lines    match    lua: (%S+) (%S-): (.+)    <tr>     <td class=log-%s>%d</td>     <td class=log-%s>%s</td>    </tr>
 	   </table>    close     L   C  C  C  E  F  F  F  F  F  G  G  H  H  H  H  H  I  I  I  J  J  J  L  L  L  P  P  Q  Q  Q  R  R  R  R  R  R  R  T  T  T  T  T  T  T  U  U  U  U  U  U  U  V  V  V  V  V  V  V  W  W  W  X  J  Y  [  [  [  \  \  ]  ]  ]  `  `  `  a        client     K      request     K      line    K      f 	   K      (for generator)    @      (for state)    @      (for control)    @      l    >      level    >   
   component    >      msg    >      	   draw_css    box_end 	   body_end     d  x   -   �   �   �@ �   �   A  A�  �@ ��@  �@���@ A �@���@ � �@���@ � �@���@  �@���@ A �@���@ A �@���@ � �@���@ � �@���@  �@�� � �   �@ �  �   �@  �    
   box_start    miscellaneous    Device 	   add_data 6   Click the button below to reboot the device: <br><br>    <form method='post'> +   <input type=hidden name=p value=rebooting> #   <input type=submit value='Reboot'>    </form> a   <br><br>Click the button below to reset factory default settings and reboot the device: <br><br> *   <input type=hidden name=p value=defaults> %   <input type=submit value='Defaults'>     -   f  f  f  h  h  h  h  h  j  j  j  k  k  k  l  l  l  m  m  m  n  n  n  p  p  p  q  q  q  r  r  r  s  s  s  t  t  t  u  u  u  v  v  v  x        client     ,      request     ,      	   draw_css    box_end 	   body_end     z  �    
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
		     	   {      �  �  �  �  {  �        client           intro           delay                �  �       �   �   �@ �   �@@��� �   ����  ��   AA �@ �� �   � A �@  ��� �   A A� �@ �� � C�@ �@ � � �   �@  �       Upgrade    busy    logf    LG_INF    upgrade    Upgrade in progress    show_page_rebooting �   			The NQuire is currently upgrading its software. A reboot will be
			performed after the upgrade. This page will automatically attempt to
			reconnect after 100 seconds.        Y@h   			The NQuire is now rebooting. This page will automatically attempt to
			reconnect after 40 seconds.        D@   os    execute    reboot         �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        client           request           	   draw_css 	   body_end     �  �      �   �@@�@ �   �    � �@� �       cit    restore_defaults        �  �  �  �  �  �  �  �        client           request              page_rebooting     �  d   e  �   �@    A�  ��� �� �A    ��A �@ �  �� � B�� A   E��� @B@��   ��� �BF� � �    � A 
  � 
  J  �A Ɓ� ������A ܂��   �C @ � I� ����� ��  ��F�� �� � ��F��ZC    �IE��  ���A ������  C  D  �C ��  �B ��  ������   �����E@����A���W�A@�K�C�� \��ZB   �K�C� \��Z  @�	AG�D� IBG�	Aǌ	AG��� �@�W����D W@� �K���� \��Z  ��	AG�D� IBG�D� IBǌD� IBG���E� K��� \��W �@�E� K�� \��W@��D @� �E  �B  �  C \B 	AG�D� IBG�D� IBǌD� IBG���E� K�� \��@��E� K��B \��@�@�I�H�I�H�I�ȌI�H�I�ȑ �D W@�@�E	 ��\C @�� I��@���� E� �I���I���I�A��A ���@��� �B�@�܂��  �����I@��@J� �W E  ��� C  ��  EC  �  ��
  �C� 
�� C  ��  EC  �  ��
  �C�@��� W�@�K�� \��ZC  ��E  �C �  � @����� � \C�D� IC� �E  �C  �  � @�� � \C�� � ��  ���   @��  �A    A �A �A ��L A� � �A��A �MB A� �A �� �NB C��� �A�����   ����W�A@��  �A    A� �A �  
A D�	A��D 	A�D�	A��D 	A�D�	A��D 	A�D�	A��D 	A�D�	A��D 	A�D�	A��D 	A�D�	A��F�� F��� �� ��܁� �  @ �� ��Z   ��A�  @ ��A  ���O��R A �B �A ��R A� �� �A ��R A� � �A �    @� �A��   � Q      logf    LG_DBG (   request.method=%s, request.post_data=%s    method 
   post_data    nil        Upgrade    busy    POST    string    gsub    ([^&=]+)=([^&;]*)[&;]?    pairs    param    match    ^set%-(.+)$    escapes_to_binstr    ^default%-(.+)$    set-    false    keyvalue['%s'] = '%s'    /dev/auth/enable    true    /dev/auth/username    /dev/auth/password    /dev/auth/password_shadow    ^%s    %s$        config    get ?   password is not entered but authentication or user is changed.     /dev/auth/encrypted    encrypt_password    lookup    type    boolean    appearance 	   checkbox 2   Skipped setting of %s because of some other error #   Webui data entry error on field %s    set    LG_WRN (   Error setting node %s from '%s' to '%s' "   changed node %s from '%s' to '%s'    Applied settings    display 	   set_font       2@   show_message 	   Applying 	   settings    evq    push    cit_idle_msg       @   Requesting authorisation    Authorization    top    bottom    main    menu    home    network 	   messages    scanner    miscellaneous    log    reboot 
   rebooting 	   defaults    p    set_header    Content-Type    text/html; charset=UTF-8    Expires    Cache-control ,   no-cache, must-revalidate, proxy-revalidate        �  �      �   � @�@  ƀ�   ܀ A  �@@� � � � �       param 
   webserver    url_decode        �  �  �  �  �  �  �  �  �  �  �  �        name           attr              request e  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                                  	  	                                                                                                     !  !  !  !  "  "  "  "  "  "  "  $  $  %  %  &  &  &  &  &  '  '  '  '  '  '  '  '  '  (  (  (  *  *  *  *  *  *  *  *  +    /  2  2  3  3  3  3  3  4  4  4  4  4  4  5  5  5  5  5  6  6  6  6  6  6  9  9  9  9  9  9  <  <  <  <  <  =  B  C  C  D  D  E  E  F  F  G  G  H  H  I  I  J  J  K  K  L  L  M  M  N  N  O  O  R  R  S  T  T  T  T  T  U  U  V  V  V  V  V  W  W  Y  \  \  \  \  ]  ]  ]  ]  ^  ^  ^  ^  `  `  `  `  b  d  "      client     d     request     d     applied_setting    d     retval    d     skip !   &  
   keyvalues "   &     (for generator) %   ?      (for state) %   ?      (for control) %   ?      key &   =      val &   =      id )   =      cb_id 3   =      (for generator) B   L      (for state) B   L      (for control) B   L      key C   J      value C   J      usr S   �      pwd T   �      pwd_shadow U   �      shadow �   �      salt �   �      crypted �   �      (for generator) �        (for state) �        (for control) �        key �         value �         node �         prev_value �         pagehandlers A  d     p C  d     handler D  d        lgid    errors    hidden_password 	   page_top    page_bottom 
   page_main 
   page_menu 
   page_home    page_network    page_messages    page_scanner    page_miscellaneous 	   page_log    page_reboot    page_rebooting    page_defaults     g  x          @@ ��  �   @    @@ ��  �   @  �    
   webserver 	   register    /    .+.jpg        k  v    	   � � �@@�  ����   @���  � �A @ A܀ �   @��A �� � A AB ���� ��A  C �A A���A  �       path    match    ([^/]+.jpg)    io    open    img/    set_header    Content-Type 
   image/jpg 	   add_data    read    *a 
   set_cache       �@   close        l  l  l  l  m  m  n  n  n  n  n  n  o  o  p  p  p  p  q  q  q  q  q  r  r  r  s  s  v        client           request           fname          fd              h  h  h  h  h  j  j  j  v  j  x            on_webserver y                        �   �   �     
            ^  ^  ^  ^  l  l  l  u  u  u  �    �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  D  D  D  D  D  D  D  D  D  �  �  �  �  �  �  �  �  �  �  �  �  �                             ?  ?  ?  ?  ?  ?  ?  ?  a  a  a  a  x  x  x  x  �  z  �  �  �  �  �  d  d  d  d  d  d  d  d  d  d  d  d  d  d  d  d  d  x  x  g  x        lgid    x      hidden_password    x   	   draw_css    x      body_begin 	   x   	   body_end 
   x      to_html_escapes    x      draw_node_label_start    x      draw_node_label_end    x      draw_node_label    x      errors    x      draw_node_value_data    x      draw_node_value    x   
   draw_node    x      box_end     x      form_start !   x   	   form_end "   x   	   page_top $   x      page_bottom &   x   
   page_main '   x   
   page_menu )   x   
   page_home -   x      display_by_default .   x      page_network 7   x      page_messages D   x      page_scanner M   x      page_miscellaneous U   x   	   page_log Y   x      page_reboot ]   x      page_rebooting b   x      page_defaults d   x      on_webserver u   x       