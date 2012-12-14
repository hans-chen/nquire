LuaQ     @webui.lua           l      A@    À@@$   d@  ¤  äÀ  $ dA        ä $Â      d      ¤B  ¤ B ¤Â ä $C d     ¤Ã     ä $D     d       ¤Ä ä                  	      $E                                 d                  ¤Å                  ä        $F        d G dÆ     ¤   äF                  	   
  
             $ Ç $Ç      	      module    Webui    package    seeall 	   humanize 
   box_start    show_page_rebooting    on_upgrade_welcome_image    new                    K @ Á@  \@     	   add_data k
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
	        	      	            client                ¢   ´        K @ Á@  \@     	   add_data |  <body>
<script type="text/javascript"> 
function toggle(tf, group) 
{ 
    document.getElementById(group).style.visibility = (tf) ? "block" : "none"; 
}
function set_visibility(tf, group)
{
    document.getElementById(group).style.display = (tf) ? "block" : "none"; 
} 
function enable_disable(tf, element) 
{ 
    document.getElementById(element).disabled = ! tf; 
}
</script> 
        £   ³   £   ´         client                ¶   º        K @ Á@  \@     	   add_data 	   </body>
        ·   ¹   ·   º         client                À   Ã     
    @ A  @ @   FÁÀ  @     	   add_data    <td width=30%>
    <span class=label>    label 	   </span>
     
   Á   Á   Á   Â   Â   Â   Â   Â   Â   Ã         client     	      node     	           Å   Ç        K @ Á@  \@     	   add_data    </td>
        Æ   Æ   Æ   Ç         client                É   Ì          À     @  À   @              Ê   Ê   Ê   Ê   Ë   Ë   Ë   Ì         client           node              draw_node_label_start    draw_node_label_end     Ð   
    É   À  Ú@    Á@  KÀ \ Z  /KÁÀ \ Á    @-@  À,AÁ A ÁÁ  B@A Å Â A  ÁB  UA Ã Á A    A  ËD J  bB PBÜAËD J À  bBPBÜA$AÁ A ÀÄ Á A    A  Ã ÁÁ ÚA    ÁA  D À   @¢BBD À  @¢BBAÁ EÀD 
 @ "B AÆ AF @@ Â B    B  ËD JÀ  bCPCÜB¡A  ÀûD B AÀAÁ G  Á @ A Á Æ    Æ HÂ   ÆAÁ  ÉÅA	 ÆÉB	 ÂI@  EB	 FÂÉB \ BÜ ÌÁÇÁ   Á Á ÆAÊ Ú  ÆAÊ ËÊAÂ
 ÜÚ   ËD J ÎBKÃÇ C  @ Ã CKE \ bBPBÜA ËD J À ÃÇ C    Ã @bBPBÜA D  A  0      full_id     	   has_data    get    is_writable    type    boolean    appearance 	   checkbox    logf    LG_DBG    webui    displaying checkbox      =     true    checked 	   add_data 6   <input type='hidden' name='default-%s' value='off'/>
 .   <input type='checkbox' name='set-%s' %s %s/>
    false <   <input type='radio' name='set-%s' value='false' %s %s/> No
 <   <input type='radio' name='set-%s' value='true' %s %s/> Yes
    enum    <select name='set-%s' %s >
    range    gmatch    ([^,]+) 
    selected     <option value=%q%s>%s</option>
    </select>
    ip_address    size       .@      $@   match    :(%d+)    number    math    floor    log       ð?   options    find    b ?   <input name='set-%s' maxlength='%d' size='%d' value='%s' %s/>
       @   binstr_to_escapes =   <input name='set-%s' maxlength='%d' size='%d' value=%q %s/>
     É   Ñ   Ñ   Ó   Ó   Ó   Õ   Õ   Õ   Õ   Ö   Ö   Ø   Ø   Ø   Ø   Ø   Ø   Û   Û   Û   Û   Û   Û   Ü   Ü   Ü   Ü   Ü   Ü   Ü   Ü   Ü   Ý   Ý   Ý   Ý   Ý   Ý   Þ   Þ   Þ   Þ   Þ   Þ   ß   ß   ß   ß   ß   ß   ß   ß   ß   à   à   à   á   á   á   á   á   á   â   â   â   â   â   â   ã   ã   ã   ã   ã   ã   ã   ã   ä   ä   ä   ä   ä   ä   ä   ä   ä   å   å   å   æ   æ   æ   æ   æ   æ   æ   ç   ç   ç   ç   ç   è   è   è   è   è   è   é   é   é   é   é   é   é   é   ç   é   ë   ë   ë   ë   í   í   í   î   î   î   ð   ð   ò   ò   ò   ó   ó   ó   ó   ô   ô   õ   õ   õ   ö   ö   ö   ö   ö   ö   ö   ö   ö   ö   ö   ö   ö   ö   ö   ø   ü   ý   ý   ý   ý   ý   ý   ý   ý   ý                                                                                        
        client     È      node     È      ro     È      optarg     È      id    È      value    È      is_checked &   4      c1 >   T      c2 D   T      (for generator) c   t      (for state) c   t      (for control) c   t      item d   r      sel j   r      tmp       
   maxlength    Ä                
   À  D  FZ   A  GA  @ AÁ  GA  KA ÅA  ÐÁ\AD   À   @\AKA Á \A        full_id    class    node-error    node 	   add_data    <td class=%s>
    </td>                                                                client           node           ro           optarg           id             errors    draw_node_value_data       !   	   @ A  A  @   A @   À  A@   A     	   add_data    <tr>
    </tr>
                                           !        client           node           ro           optarg              draw_node_label    draw_node_value     +  /       K @ Á@    \    K @ ÁÀ  $  \              gsub    [_]         (.)(.+)        -  -        @  Ë@À Ü À           upper    lower        -  -  -  -  -  -  -        a           b               ,  ,  ,  ,  ,  -  -  -  -  -  .  /        s                2  7    	   @ A  ÛA  Á  Â  A@  À B A@  A     	   add_data    <fieldset         >
 	   <legend>    </legend>
 	   <table>
        3  3  3  3  3  3  3  3  4  4  4  4  4  4  6  6  6  7        client           page           title           extra                9  <       K @ Á@  \@K @ Á  \@     	   add_data 
   </table>
    </fieldset>
        :  :  :  ;  ;  ;  <        client                >  D       Z    @ A  @   @  @ Á  @     	   add_data    <form method='post'     >
    <form method='post'>
        ?  ?  @  @  @  @  @  @  @  B  B  B  D        client           extra                F  K       K @ Á@  \@K @ Á  \@K @ ÁÀ  \@K @ Á  \@     	   add_data 	   <center> ;   <input type='submit' class=submit value='Apply settings'/>    </center>
 	   </form>
        G  G  G  H  H  H  I  I  I  J  J  J  K        client                Q  W         À   @  @ A  @ @   @ @ Á  @ @  @     	   add_data    <table class=top><tr>    <td class=top-left>&nbsp;</td>     <td class=top-right>&nbsp;</td>    </tr></table>
        R  R  R  S  S  S  T  T  T  U  U  U  V  V  V  W        client           request           	   draw_css     Y  ^         À   @  @ A  @ @   @ @ Á  @     	   add_data    <table class=bottom><tr> "   <td class=bottom-left>&nbsp;</td>    </tr></table>
        Z  Z  Z  [  [  [  \  \  \  ]  ]  ]  ^        client           request           	   draw_css     a  w          @@  À@ Ë A AA  Á UÁÜ@        config    lookup 
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
	        c  c  c  c  c  c  e  g  g  v  v  e  w        client           request           name               z     "    Á   A  A  Á  Á B A ¢@Ä      Ü@ ËÀA A Ü@Å@   Ü  ÂA  ÀÃ @ ¢B  Bá   ýËÀA A Ü@        home    network 	   messages    scanner    miscellaneous    log    reboot 	   add_data    <ul class=menu>    ipairs 5   <li class=menu><a href='?p=%s' target='main'>%s</li> 	   humanize    </ul>
     "   |  |  |  |  |  |  |  |  |  ~  ~  ~                                                    client     !      request     !   
   item_list 	   !      (for generator)          (for state)          (for control)          _          item          	   draw_css          C      À   @    À   A  A  @   À   Á  AA B @   À   Á  A B @   À   Á  AÁ @    À   Á  A @    À   Á  AA @    À   Á  A @    À   Á  AÁ @    À   Á  A @       
   box_start    home    Welcome    config    lookup 
   /dev/name    /dev/serial    /dev/version    /dev/rfs_version    /dev/build 
   /dev/date    /dev/scanner/version    /network/macaddress     C                                                                                                                                               client     B      request     B      	   draw_css 
   draw_node                  A   Z@    A@  ^              style='display:none'                              yes_do                  ß        À   @   À   @   À   @    @@  ËÀ@Ü  AA A    A   @!Á @   ÁA A  E KAÁ\ Z   AÁ ZA    A A Á ÁE KÁ\ Z  @  Ä  @ÄD  À   @ \AD   \A E KAÁ\ Z   	EÁ   Á Â A WÄ  ÂB  Â  U\AD  Å  ËAÀAB Ü\A  D  Å  ËAÀA Ü\A  D  Å  ËAÀAÂ Ü\A  D   \A E KÁ\ Z  EÁ   Á B A W Æ  ÂB  Â  U\AD  Å  ËAÀAÂ Ü\A  D  Å  ËAÀA Ü\A  D  Å  ËAÀAB Ü\A  D  Å  ËAÀA Ü\A  D  Å  ËAÀAÂ Ü\A  D   \A   A@  HA AÁ @   Á Â A@    A@	 Â  B	 AI Á	 Ä  B@	 Â@  J@  Æ  B   Ü B
 A@    A@
 A  @    A@Â
 A  @    A@ A  I A A @  A Á @   Á A @    A@Â A  @    A@ A  @    A@B A  @    A@ A   @  A  @  A @  A   3      config    lookup    /network/interface    get    Network    wlan_is_available    gprs_is_available 
   box_start    network    Network interface %   onclick="set_visibility(this.value==    'wifi','wifisettings'    'gprs','gprssettings'    ); 5   set_visibility(this.value!='gprs', 'dhcp_settings')"    range    ethernet,gprs    ethernet,wifi    wifi    Wifi    id='wifisettings'     /network/wifi/essid    /network/wifi/keytype    /network/wifi/key    gprs    Gprs    id='gprssettings'     /network/gprs/pin    /network/gprs/username    /network/gprs/password    /network/gprs/apn    /network/gprs/number    set 	   ethernet    IP Settings    id='dhcp_settings'    /network/dhcp C   onclick='set_visibility(this.value=="false","static_ip_settings")' 	   add_data     <table id='static_ip_settings'     false    >    /network/ip/address    /network/ip/netmask    /network/ip/gateway 	   </table>    NQuire protocol settings    /cit/udp_port    /cit/tcp_port 
   /cit/mode    /cit/remote_ip                                     ¡  ¡  £  £  £  £  £  £  £  £  £  £  ¦  ¦  ¦  ¦  ¦  §  ¨  ¨  ¨  ¨  ¨  ¨  ¨  ¨  ¨  ¨  ©  ©  «  «  «  «  «  ¬  ¬  ®  °  °  °  °  °  °  ±  ±  ±  ³  ³  ³  ³  ³  ´  ´  ´  ´  ´  µ  µ  µ  µ  µ  µ  µ  ´  ¶  ¶  ¶  ¶  ¶  ¶  ¶  ·  ·  ·  ·  ·  ·  ·  ¸  ¸  ¸  ¸  ¸  ¸  ¸  ¹  ¹  ¹  ¼  ¼  ¼  ¼  ¼  ½  ½  ½  ½  ½  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ½  ¿  ¿  ¿  ¿  ¿  ¿  ¿  À  À  À  À  À  À  À  Á  Á  Á  Á  Á  Á  Á  Â  Â  Â  Â  Â  Â  Â  Ã  Ã  Ã  Ã  Ã  Ã  Ã  Ä  Ä  Ä  Å  Ç  Ç  Ç  Ç  Ç  Ç  Ç  Ë  Ë  Ë  Ë  Ë  Ë  Ì  Ì  Ì  Ì  Ì  Ì  Ì  Ì  Ì  Í  Í  Î  Î  Î  Î  Î  Î  Î  Î  Î  Ï  Ï  Ï  Ï  Î  Ï  Ï  Í  Ð  Ð  Ð  Ð  Ð  Ð  Ð  Ñ  Ñ  Ñ  Ñ  Ñ  Ñ  Ñ  Ò  Ò  Ò  Ò  Ò  Ò  Ò  Ó  Ó  Ó  Ô  Ô  Ô  Ö  Ö  Ö  Ö  Ö  ×  ×  ×  ×  ×  ×  ×  Ø  Ø  Ø  Ø  Ø  Ø  Ø  Ù  Ù  Ù  Ù  Ù  Ù  Ù  Ú  Ú  Ú  Ú  Ú  Ú  Ú  Û  Û  Û  Ý  Ý  Ý  Þ  Þ  Þ  ß        client          request       	   itf_node      
   ift_value         extra +         	   draw_css    body_begin    form_start 
   draw_node    box_end    display_by_default 	   form_end 	   body_end     ä  4   ñ      À   @   À   @   Ê  É@@ÉÀ@
  	A	AA¢@ Ê   AÁ  ÁA  AÂ â@  @  A  @ @+EB KÃÆ@ÐÂ\ À  C FÄB ÂD  B ÀÄ   ED KÃÊ @@ âD ÐÄ\ÜC  ¡  üÂD  BÂ Æ@Ã  BÃD  C À@Á WÀA	@  B	@	E F@ 	À Õ
ÀA	@E C
 Æ@ ¢E G
W@G
  	A ÕD
 B	@E C
 Æ@ ¢E G
W H
  	A ÕD
@B	@E F@ À Õ
B	@Å F@Å À Õ
E C
Æ@ @ 	¢ED   À 
  @	\E¡  ÀìÃD  Cê@À@ 
ÂD  BB CC	 Ä   @ ÜBÄ    @   Á	 ÜBÄ   ÜB Ä    EC KÃÁÃ	 \  Á
 ÜBÄ    EC KÃÁC
 \  Á
 ÜBËÂD AÃ
 ÜBÂD Ã
 B À  B !  ÀÓ @  A ÅA ËÃA ÜÆÄA @  A CB A  @  A C A   @  A  @  A ÁD Á A@  A   0      count       @   id    idle        @   error    text    xpos    ypos    valign    halign    size    ipairs    config    lookup    /cit/messages/%s 
   box_start 	   messages    label 	   add_data    <tr>    /cit/messages/%s/1/%s    </tr>       ð?       id='    '    /cit/messages/%s/%s/halign    value    left 
    disabled    /cit/messages/%s/%s/valign    top )   onchange='enable_disable(value=="top", "    ")' *   onchange='enable_disable(value=="left", "    /cit/messages/%s/%s/%s     /cit/messages/idle/picture/show i   onclick="enable_disable(this.checked,'xpos');enable_disable(this.checked,'ypos')" id='show_idle_picture'     /cit/messages/idle/picture/xpos 
   id='xpos'     /cit/messages/idle/picture/ypos 
   id='ypos'    </tr>
    /cit/messages/fontsize    /cit/messages/fontsize/small    /cit/messages/fontsize/large Ë   <script type="text/javascript"> 
	enable_disable(document.getElementById('show_idle_picture').checked, 'xpos');
	enable_disable(document.getElementById('show_idle_picture').checked, 'ypos');
</script> 
     ñ   å  å  å  æ  æ  æ  è  è  é  é  é  ê  ê  ë  ì  ì  ì  ì  ì  ì  ì  ì  î  î  î  ð  ð  ð  ð  ò  ò  ò  ò  ò  ó  ó  ó  ó  ó  õ  õ  õ  ö  ö  ö  ö  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ö  ÷  ù  ù  ù  ú  ú  ú  ú  û  û  û  ü  ü  ü  ü  ý  þ  þ  þ  þ  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ                                                                                               
  
                                            ü          ú                                                                                          !  !  !  "  "  "  ð  "  %  %  %  %  %  %  %  %  %  &  &  &  &  &  &  &  '  '  '  '  '  '  '  (  (  (  *  *  *  ,  1  ,  3  3  3  4        client     ð      request     ð   	   msg_list    ð   	   key_list    ð      (for generator)    Í      (for state)    Í      (for control)    Í      _    Ë      msg    Ë      node "   Ë      (for generator) -   ;      (for state) -   ;      (for control) -   ;      _ .   9      item .   9      (for index) A         (for limit) A         (for step) A         row B         (for generator) H         (for state) H         (for control) H         _ I         item I         extra J         node          idle_picture_show £   Å      	   draw_css    body_begin    form_start    draw_node_label    draw_node_value    draw_node_label_start    draw_node_value_data    draw_node_label_end    box_end 
   draw_node 	   form_end 	   body_end     6          À   @   À   @   À   @    À   A  A  @ @  À@ AÀ À   A AÁ B   @ À   A AA @   À   A A @    À   @ @  À@ A    À   A  AÁ @  À   A A @   À   A AA @   À   A A @    À   @ @  À@ÀC   À   A  A @  À   A AA @    À   @    À   A  A  @ D Á @  Å@  Æ@Å  Å ÂEÜ ÚA  ÀÅA ËÁA ÂEUÜÚ  ÀB E Â Á ÃEÕB @  BÀB EB Â Á ÃEAÃ ÕBB ¡   ÷D  @@  À@ A @ AÁ @HHÀ D Á @ D 	 @  Å@  Æ@Å  Å ÂEÜ Ú  ÀÅA ËÁA ÂEUÜÚ  ÀB E Â Á ÃEÕB @  BÀB EB	 Â Á ÃEA	 ÕBB ¡   ÷D  @  À   @ À	  J    
   À   A  AA
 @  À   A A
 @   À   A AÁ
 @   À   A A @   À   A AA @   À   A A @    À   @  À   @   /   
   box_start    scanner 	   Barcodes    type    2d    config    lookup    /dev/scanner/barcodes =   onclick='set_visibility(this.value=="1D and 2D","2d_codes")' &   /dev/scanner/multi_reading_constraint    /dev/scanner/enable_barcode_id    Scanning modes Imager    /dev/scanner/illumination_led !   /dev/scanner/reading_sensitivity    /dev/scanner/aiming_led    1d    Scanning modes    /dev/scanner/1d_scanning_mode 	   add_data    <table id='1d_codes'>    ipairs    enable_disable    is_2d_code    name    /dev/scanner/enable-disable/    logf    LG_DMP    webui    showing code     LG_DBG    Code '    ' is no configuration item. 	   </table>    value    1D only +   <table id='2d_codes' style='display:none'>    <table id='2d_codes'>    LG_WRN !   ' not found in the configuration    Scanner_rf    is_available    Mifare scanner    /dev/mifare/key    /dev/mifare/relevant_sectors +   /dev/mifare/prevent_duplicate_scan_timeout &   /dev/mifare/msg/access_violation/text %   /dev/mifare/msg/incomplete_scan/text       8  8  8  9  9  9  :  :  :  <  <  <  <  <  =  =  =  =  >  >  >  >  >  >  >  ?  >  @  @  @  @  @  @  @  C  C  C  C  C  C  C  D  D  D  F  F  F  F  G  G  G  G  G  H  H  H  H  H  H  H  I  I  I  I  I  I  I  J  J  J  J  J  J  J  K  K  K  N  N  N  N  O  O  O  O  O  P  P  P  P  P  P  P  Q  Q  Q  U  U  U  U  U  W  W  W  X  X  X  X  X  Y  Y  Y  Y  Y  Z  Z  Z  Z  Z  Z  [  [  \  \  \  \  \  \  \  ]  ]  ]  ]  ]  _  _  _  _  _  _  _  _  X  a  c  c  c  e  e  e  e  f  f  f  f  f  f  f  g  g  g  g  i  i  i  l  l  l  l  l  m  m  m  m  m  n  n  n  n  n  n  o  o  p  p  p  p  p  p  p  q  q  q  q  q  s  s  s  s  s  s  s  s  l  u  w  w  w  y  y  y  {  {  {  {  {  |  |  |  |  |  }  }  }  }  }  }  }  ~  ~  ~  ~  ~  ~  ~                                                                client          request          (for generator) l         (for state) l         (for control) l         _ m         code m         node x         (for generator) ©   Í      (for state) ©   Í      (for control) ©   Í      _ ª   Ë      code ª   Ë      node µ   Ë      	   draw_css    body_begin    form_start 
   draw_node    box_end 	   form_end       ±   
½      À   @   À   @   À   @    À   A  A  @  À   Á  AA @    À   @    À   A  A @  À   Á  AÁ B   @À   AÁ @BB À @      Ä    EÁ  KÁÁA \  Á   ÕÜ@Ä    EÁ  KÁÁÁ \  Á   ÕÜ@Ä     Ü@ Å      AA  A Ü@ Ä    EÁ  KÁÁ \Ü@  Ä    EÁ  KÁÁÁ \  Á Ü@ÅÀ  Ë ÁAÁ ÜÆ@ÂÂ ÁÀ Ú@    Á  @  Á  AB Â   @BA @  A   @  A  ÁÁ A @  Á  A A  @  Á  AB A  @  Á  A A   @  A   @  A  ÁÁ A @  Á  A A  @  Á  AB A  @  Á  A A  @  Á  AÂ A   @  A @  A       
   box_start    miscellaneous    Device    config    lookup 
   /dev/name    Authentication    /dev/auth/enable h   onclick="enable_disable(value=='true', 'auth_username');enable_disable(value=='true', 'auth_password')"    value    true     
    disabled    /dev/auth/username     id='auth_username'    /dev/auth/password     id='auth_password'    Programming barcode security    /cit/programming_mode_timeout    /dev/barcode_auth/enable 9   onclick="enable_disable(value=='true', 'security_code')"     /dev/barcode_auth/security_code     id='security_code'    Text and messages    /cit/messages/idle/timeout    /cit/messages/error/timeout    /cit/codepage    Interaction    /dev/display/contrast    /dev/beeper/volume    /dev/beeper/beeptype    /cit/disable_scan_beep     ½                                                                                                                                                                                                                                                      ¢  ¢  ¢  ¢  ¢  £  £  £  £  £  £  £  ¤  ¤  ¤  ¤  ¤  ¤  ¤  ¥  ¥  ¥  ¥  ¥  ¥  ¥  ¦  ¦  ¦  ¨  ¨  ¨  ¨  ¨  ©  ©  ©  ©  ©  ©  ©  ª  ª  ª  ª  ª  ª  ª  «  «  «  «  «  «  «  ¬  ¬  ¬  ¬  ¬  ¬  ¬  ­  ­  ­  ¯  ¯  ¯  ±        client     ¼      request     ¼      extra 1   ¼      extra j   ¼      	   draw_css    body_begin    form_start 
   draw_node    box_end 	   form_end     ³  Í   I      À   @    Å@  ÆÀÁ  A ÜÚ    A @   ÁÁ A B A AÂÀ	ÂÂ   ËB AC ÜBËB J  À bC PCÜBËB J  À bC PCÜBËB J  ÀbC PCÜBËB J  À bC PCÜBËB A ÜB @!A  @õB A AÄA  @  A            ð?   io    popen    logread    r 
   box_start    log    System log 	   add_data    <table class=log>    lines    match    lua: (%S+) (%S-): (.+)    <tr>     <td class=log-%s>%d</td>     <td class=log-%s>%s</td>    </tr>
 	   </table>    close     I   µ  µ  µ  ·  ¸  ¸  ¸  ¸  ¸  ¹  ¹  º  º  º  º  º  »  »  »  ¼  ¼  ¼  ¾  ¾  ¾  ¿  ¿  À  À  À  Á  Á  Á  Á  Á  Á  Á  Â  Â  Â  Â  Â  Â  Â  Ã  Ã  Ã  Ã  Ã  Ã  Ã  Ä  Ä  Ä  Ä  Ä  Ä  Ä  Å  Å  Å  Æ  ¼  Ç  É  É  É  Ê  Ê  Ë  Ë  Ë  Í        client     H      request     H      line    H      f 	   H      (for generator)    @      (for state)    @      (for control)    @      l    >      level    >   
   component    >      msg    >      	   draw_css    box_end     Ð  ã   *      À   @    À   A  A  @ À@  @À@ A @À@  @À@ Á @À@  @À@ A @À@ A @À@  @À@ Á @À@  @  À   @      
   box_start    miscellaneous    Device 	   add_data 6   Click the button below to reboot the device: <br><br>    <form method='post'> +   <input type=hidden name=p value=rebooting> #   <input type=submit value='Reboot'>    </form> a   <br><br>Click the button below to reset factory default settings and reboot the device: <br><br> *   <input type=hidden name=p value=defaults> %   <input type=submit value='Defaults'>     *   Ò  Ò  Ò  Ô  Ô  Ô  Ô  Ô  Ö  Ö  Ö  ×  ×  ×  Ø  Ø  Ø  Ù  Ù  Ù  Ú  Ú  Ú  Ü  Ü  Ü  Ý  Ý  Ý  Þ  Þ  Þ  ß  ß  ß  à  à  à  á  á  á  ã        client     )      request     )      	   draw_css    box_end     å      
	   Ë @ AA   Á    AÂ  UAÜ@     	   add_data h   
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
		     	   æ  ê  ê          æ          client           intro           delay                           À   @    @@     ÅÀ   AA @  À   Á A @   À   A A @ À  CÁ@ @         Upgrade    upgrade_busy    logf    LG_INF    upgrade    Upgrade in progress    show_page_rebooting ­   			The NQuire is currently upgrading its software. A reboot will be
			performed after the upgrade. This page will automatically attempt to
			reconnect after 100 seconds.        Y@h   			The NQuire is now rebooting. This page will automatically attempt to
			reconnect after 40 seconds.        D@   os    execute    reboot        	  	  	                                                          client           request           	   draw_css       #   	      Å@    AÁ  @   @AÁ À @  @  EÁ   Á  A  @   A  	      logf    LG_INF    webui 6   Removing cit.conf to restore factory default settings    os    execute    rm -f cit.conf    LG_WRN    Could not remove cit.conf: %s                                                "  "  "  "  #        client           request           ok 	         err 	            page_rebooting     *     °   Æ À @À@ÆÀ Ú   ÅÀ  Æ ÁÀ AA ¤     Ü@ Ê   È   Ê    FÁÁ ÀKÂÁB \Z  @ É  Â   ÀÆÂÁ Ã @ CÆÚB    É C!  @ú @@EB KÃÀ\Z  ÀÂÃ D@BÄD W C  Â Å W 
B Å Ã A ÁC Å A  ÁÄ UÃB  ÆÇÚ  ÀÆÇËBÇA ÜÚ  @ÅÂ   Ü ÈÃ À     À ËÈ@ ÜB   Ä  ÉBÈ    !  Àï     ÁH Á	  A AI	 ÁÁ	 A 
 AJ
 ÃÂ
 A
A D 	AD 	AD	AD 	AD	AD 	AD	AD 	AD	AD 	AD	AD 	AD	AFÁÁ FAÎ Z   ÆAÚ  @ A  KËN AÂ  ÜA À    @ ÜA  =      method    POST 
   post_data    string    gsub    ([^&=]+)=([^&;]*)[&;]?    pairs    param    match    ^set%-(.+)$    ^default%-(.+)$    set-    false    config    lookup    type    boolean    appearance 	   checkbox    true    get    logf    LG_DBG    webui    changing node      from '    ' to '    '    options    find    b    escapes_to_binstr    set    display 	   set_font       2@   show_message 	   Applying 	   settings    evq    push    cit_idle_msg       @   top    bottom    main    menu    home    network 	   messages    scanner    miscellaneous    log    reboot 
   rebooting 	   defaults    p    set_header    Content-Type    text/html; charset=UTF-8        1  4          @Å@  ÆÀ   Ü A  @@           param 
   webserver    url_decode        2  2  2  2  2  2  2  2  2  2  2  4        name           attr              request °   /  /  /  /  /  /  0  0  0  0  4  4  0  8  8  ;  <  <  <  <  >  >  >  ?  ?  A  A  C  C  C  D  D  D  D  D  D  D  D  D  F  <  H  L  L  L  L  M  M  M  M  N  N  O  O  O  O  O  O  O  O  P  R  R  R  R  S  S  S  S  S  S  S  S  S  S  S  S  S  T  U  U  U  U  U  U  U  U  U  V  V  V  X  X  X  X  X  X  X  Z  Z  Z  Z  \  \  ]  ]  ]  _  L  b  f  f  g  g  g  g  g  g  h  h  h  h  h  i  i  i  i  i  i  m  n  n  o  o  p  p  q  q  r  r  s  s  t  t  u  u  v  v  w  w  x  x  y  y  z  z  }  }  ~                                          client     ¯      request     ¯      applied_setting     ¯   
   keyvalues    ¯      (for generator)    *      (for state)    *      (for control)    *      key    (      val    (      id    (      cb_id    (      (for generator) -   n      (for state) -   n      (for control) -   n      key .   l      value .   l      node 2   l      ok O   l   	   binvalue [   a      pagehandlers    ¯      p    ¯      handler    ¯         errors 	   page_top    page_bottom 
   page_main 
   page_menu 
   page_home    page_network    page_messages    page_scanner    page_miscellaneous 	   page_log    page_reboot    page_rebooting    page_defaults       ¹     `      B   @  @À   À @   Á  E A Á    @A   Á B EA  \Â Â  ÅÂ C A B  ÁB  ÅB  ÆÃ  Ü ÃÃ  ÀÃ B FÄC  
FÄÀÄÀEÃ FÅC \C EÃ FÅ À Ä \C EÃ   ÁC D @\CE KÃÆÁ  AD \CÀEÃ FÅ À Ã\C EÃ   ÁC Ä @\CB ^ a  îB ^       
   /home/ftp    sys    readdir    logf    LG_WRN    webui     Could not read directory %s: %s    os    time    ipairs    welcome.gif    LG_DMP    installing file %s    /    lstat    isreg    mtime       @   size      jø@   execute    rm -f /cit200/img/welcome.*    mv      /cit200/img/    LG_INF    Installed %s    evq    push    cit_idle_msg            rm -f  5   File %s to large for use as welcome image. max=100kB     `                                                                           ¢  ¢  ¢  ¢  £  £  £  ¦  ¦  ¦  ¦  ¦  §  §  ¨  ¨  ¨  ª  ª  ª  ª  «  «  «  «  «  «  «  ¬  ¬  ¬  ¬  ¬  ¬  ­  ­  ­  ­  ­  ­  ­  °  °  °  °  °  °  ±  ±  ±  ±  ±  ±  ³  ³    ¶  ¸  ¸  ¹        path_ftp_dir    _      upgrade_busy    _      files    _      err    _      now    _      (for generator)    ]      (for state)    ]      (for control)    ]      _    [      file    [   	   filepath $   [      stat (   [      age 0   [           »  Ð          @@   Ä   @    @@ À  ä   @   @@ @ Å @   ÀA @ Ã  @  	   
   webserver 	   register    /    .+.jpg    evq    upgrade_welcome_image    on_upgrade_welcome_image    push       $@       ¿  Ê    	    À @@     @ÅÀ  Æ ÁA @ AÜ Ú   @A Á Á A AB ÂÂ A  C A AÃA         path    match    ([^/]+.jpg)    io    open    img/    set_header    Content-Type 
   image/jpg 	   add_data    read    *a 
   set_cache       ¬@   close        À  À  À  À  Á  Á  Â  Â  Â  Â  Â  Â  Ã  Ã  Ä  Ä  Ä  Ä  Å  Å  Å  Å  Å  Æ  Æ  Æ  Ç  Ç  Ê        client           request           fname          fd              ¼  ¼  ¼  ¼  ¼  ¾  ¾  ¾  Ê  ¾  Í  Í  Í  Í  Í  Î  Î  Î  Î  Î  Î  Ð            on_webserver l                     ´   º   Ã   Ç   Ì   Ì   Ì   Î   
        !  !  !  /  +  7  2  <  D  K  W  W  ^  ^  w              ß  ß  ß  ß  ß  ß  ß  ß  ß  4  4  4  4  4  4  4  4  4  4  4  4  4                ±  ±  ±  ±  ±  ±  ±  Í  Í  Í  ã  ã  ã    å      #  #                                ¹    Ð  Ð  »  Ð     	   draw_css    k      body_begin    k   	   body_end    k      draw_node_label_start 	   k      draw_node_label_end 
   k      draw_node_label    k      errors    k      draw_node_value_data    k      draw_node_value    k   
   draw_node    k      box_end    k      form_start    k   	   form_end    k   	   page_top    k      page_bottom     k   
   page_main !   k   
   page_menu #   k   
   page_home &   k      display_by_default '   k      page_network 0   k      page_messages =   k      page_scanner D   k      page_miscellaneous K   k   	   page_log N   k      page_reboot Q   k      page_rebooting U   k      page_defaults W   k      on_webserver f   k       