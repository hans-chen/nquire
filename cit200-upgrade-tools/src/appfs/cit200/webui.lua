LuaQ     @webui.lua           !      A@    À@@  A@ ¤   ä@  $  dÁ  ¤ äA $      J  ¤Â          ä      $C      d G dÃ GÃ d ¤C ä $Ä    d    ¤D ä    $Å              d ¤E                
     ä                                $Æ                       d                   ¤F                         ä           $Ç  $         dG    ¤                  	  	   
                    äÇ     $      H   
      module    Webui    package    seeall    webui     	   humanize 
   box_start    show_page_rebooting    new !                  K @ Á@  \@     	   add_data Å   <head>
<link rel="icon" href="favicon.ico" type="image/x-icon"> 
<link rel="shortcut icon" href="favicon.ico" type="image/x-icon">
<link rel="stylesheet" type="text/css" href="cit.css" />
</head>
                          client                   ^        K @ Á@  \@     	   add_data L  <body>
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

           ]      ^         client                `   d        K @ Á@  \@     	   add_data 	   </body>
        a   c   a   d         client                f   k        K @ Á@  $  ]  ^           gsub    [;&#"'%<>]        h   j     	   A   @  @À    ÁÀ  UÀ ^          &#    string    byte    ;     	   i   i   i   i   i   i   i   i   j         c               g   g   j   g   j   k         value                q   t     
    @ A  @ @   FÁÀ  @     	   add_data    <td width=30%>
    <span class=label>    label 	   </span>
     
   r   r   r   s   s   s   s   s   s   t         client     	      node     	           v   x        K @ Á@  \@     	   add_data    </td>
        w   w   w   x         client                z   }          À     @  À   @              {   {   {   {   |   |   |   }         client           node              draw_node_label_start    draw_node_label_end        Í    ë   À  Ú@    Á@  KÀ \ Z   8KÁÀ \ Á    À5@  @5A  A Á   À  ÆÁ  ÁÁ   A ÕAÇA AÂ BÀÁÂ  C A Å  AÂ  ÀA  Ä A A    A  ËD J  bB PBÜAËD J  À  EC bB PBÜA *AÂ B@Å A A    A   Ä ÁA ÚA    ÁA  D  À   @C ¢B BD  À  @C ¢B B!AÂ  F D 
@ ÅB "BAÆ ÁF @@ B B    B  ËD JÀ  bCPCÜB¡A  ÀûD Â AAÂ  H@D 
 @  ÀC "B A@ ÆÆ Ú  ÀÁÁ Æ ÂF	 @C	 @    À !B  ÀýBÂ I@Â	 JEÂ	 FBÊ\ Â	 BJÁ  O   ÆÁÊ ÚA   Á ÚA  @@K ÁA ÚA    À BÂ K ÁÁ Á BÂ IÀ ÂÊ B    À  @B Á  D   \ D 
 @  ÌÍ @D "C B D  A  5      full_id     	   has_data    get    is_writable    popup    comment    onMouseOver="popup(' &   ','lightgreen')"; onMouseOut="kill()"    type    boolean    appearance 	   checkbox    logf    LG_DBG    displaying checkbox %s = %s    true    checked 	   add_data 6   <input type='hidden' name='default-%s' value='off'/>
 1   <input type='checkbox' name='set-%s' %s %s %s/>
    false ?   <input type='radio' name='set-%s' value='false' %s %s %s/> No
 ?   <input type='radio' name='set-%s' value='true' %s %s %s/> Yes
    enum    <select name='set-%s' %s %s>
    range    gmatch    ([^,]+) 
    selected     <option value=%q%s>%s</option>
    </select>
 	   password A   <input type='password' name='set-%s' size='15' value=%q %s %s/>
       $@           (%d+) 	   tonumber    number    math    floor    log       ð?   size       D@      @   ip_address       .@   binstr_to_escapes       ?@      p@B   <input name='set-%s' maxlength='%d' size='%d' value='%s' %s %s/>
        @    ë                                                                                                                                                                                                                                                                                                                                                     ¡   ¡   ¡   ¡   ¡   ¢   ¢   ¢   ¢   ¢   ¢   £   £   £   £   £   £   £   £   ¡   £   ¥   ¥   ¥   ¥   ¦   ¦   ¦   ¨   ¨   ¨   ¨   ¨   ¨   ¨   ¨   ¨   ¨   ª   «   «   «   ¬   ­   ­   ­   ­   ­   ®   ®   ®   ¯   ¯   ¯   ­   ¯   ±   ±   ±   ²   ²   ²   ²   ²   ²   ²   ²   ²   ²   ²   ²   ²   ²   ´   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¸   ¹   ¹   ¹   º   »   »   ¼   ¼   ¼   ¼   ¼   ¼   ½   Â   Â   Â   Â   Â   Ä   Ä   Ä   Æ   Æ   Æ   Æ   Æ   Æ   Æ   Æ   Æ   Æ   Æ   Ç   Ê   Ê   Ê   Í         client     ê      node     ê      ro     ê      optarg     ê      id    ê      value    ê      html_comment          is_checked 1   @      c1 J   b      c2 P   b      (for generator) r         (for state) r         (for control) r         item s         sel y      
   maxlength    æ      rmax    ¸      (for generator)    ¦      (for state)    ¦      (for control)    ¦      c    ¤      n ¡   ¤      size Æ   æ      v_esc Ø   æ      v_html Û   æ         to_html_escapes    lgid    hidden_password     Ð   Û    
   À  D  FZ   A  GA  @ AÁ  GA  KA ÅA  ÐÁ\AD   À   @\AKA Á \A        full_id    class    node-error    node 	   add_data    <td class=%s>
    </td>        Ñ   Ñ   Ò   Ò   Ò   Ò   Ó   Ó   Ó   Õ   Õ   Ø   Ø   Ø   Ø   Ù   Ù   Ù   Ù   Ù   Ù   Ú   Ú   Ú   Û         client           node           ro           optarg           id             errors    draw_node_value_data     ß   ä    
   K@ ÁA  B     AÂ  ÕA\AD    À \AD   À   @\AK@ Á \A     	   add_data    <tr         >
    </tr>
        à   à   à   à   à   à   à   à   á   á   á   á   â   â   â   â   â   â   ã   ã   ã   ä         client           node           ro           optarg           tr_arg              draw_node_label    draw_node_value     î   ò        K @ Á@    \    K @ ÁÀ  $  \              gsub    [_]         (.)(.+)        ð   ð         @  Ë@À Ü À           upper    lower        ð   ð   ð   ð   ð   ð   ð         a           b               ï   ï   ï   ï   ï   ð   ð   ð   ð   ð   ñ   ò         s                õ   ú     	   @ A  ÛA  Á  Â  A@  À B A@  A     	   add_data    <fieldset         >
 	   <legend>    </legend>
 	   <table>
        ö   ö   ö   ö   ö   ö   ö   ö   ÷   ÷   ÷   ÷   ÷   ÷   ù   ù   ù   ú         client           page           title           extra                ü   ÿ        K @ Á@  \@K @ Á  \@     	   add_data 
   </table>
    </fieldset>
        ý   ý   ý   þ   þ   þ   ÿ         client                         Z    @ A  @   @  @ Á  @     	   add_data    <form method='post'     >
    <form method='post'>
                                        client           extra                	         K @ Á@  \@K @ Á  \@K @ ÁÀ  \@K @ Á  \@     	   add_data 	   <center> ;   <input type='submit' class=submit value='Apply settings'/>    </center>
 	   </form>
        
  
  
                            client                           À   @  @ A  @ @   @ @ Á  @ @  @     	   add_data    <table class=top><tr>    <td class=top-left>&nbsp;</td>     <td class=top-right>&nbsp;</td>    </tr></table>
                                              client           request           
   draw_head       !         À   @  @ A  @ @   @ @ Á  @     	   add_data    <table class=bottom><tr> "   <td class=bottom-left>&nbsp;</td>    </tr></table>
                                   !        client           request           
   draw_head     $  8          @@  À@ Ë A AA  Á UÁÜ@        config    lookup 
   /dev/name    get 	   add_data 
   		<title>   </title> 
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
	        &  &  &  &  &  &  (  )  )  7  7  (  8        client           request           name               ;  G   "    Á   A  A  Á  Á B A ¢@Ä      Ü@ ËÀA A Ü@Å@   Ü  ÂA  ÀÃ @ ¢B  Bá   ýËÀA A Ü@        home    network 	   messages    scanner    miscellaneous    log    reboot 	   add_data    <ul class=menu>    ipairs 5   <li class=menu><a href='?p=%s' target='main'>%s</li> 	   humanize    </ul>
     "   =  =  =  =  =  =  =  =  =  ?  ?  ?  A  A  A  B  B  B  B  C  C  C  C  C  C  C  C  C  B  C  E  E  E  G        client     !      request     !   
   item_list 	   !      (for generator)          (for state)          (for control)          _          item          
   draw_head     J  k   7      À   @   À   @    À   A  A  @  ÁÀ   AA  ÁÁ  AB  ÁÂ  AC  ÁÃ  AD ¢@Å   Ü @Â EKBE\ T@ D   À  \B á  ÀûÄ    Ü@ Ä     Ü@      
   box_start    home    Welcome 
   /dev/name    /dev/serial    /dev/hardware    /dev/firmware    /dev/version    /dev/build 
   /dev/date    /dev/rfs_version    /network/macaddress_eth0    /network/macaddress_wlan0    /dev/scanner/version    /dev/mifare/modeltype    /dev/touch16/name    /dev/mmcblk    /network/current_ip    ipairs    config    lookup    get             7   K  K  K  L  L  L  M  M  M  M  M  O  Q  R  S  T  U  V  W  X  Y  Z  [  \  ]  ^  `  `  b  b  b  b  c  c  c  c  d  d  d  d  d  e  e  e  e  e  b  f  i  i  i  j  j  j  k  	      client     6      request     6      keys    6      (for generator)    0      (for state)    0      (for control)    0      _     .      key     .      cfg $   .      
   draw_head    body_begin 
   draw_node    box_end 	   body_end     m  o           A   Z@    A@  ^              style='display:none'        n  n  n  n  n  n  n  o        yes_do                r  Å   K     À   @   À   @   À   @    @@  ËÀ@Ü  AA E KÁ\   Á@  A  À ZA  @ WÀA@#Å    AB  ÜA A  @ZA  ÀWÀA@ËÁB A  ÁB UÂÜAÁ    Â B     AB  ÕZA  @ ÀD@ @EA  @ E@ ÀE  ÀA@   Â   B @  B    	 @   Á C DWÅ  C   \ CB@    B@ B  @    B@Ã B  @    B@ B   @  B Z  À @  Â ÁB  DWÀÄ  C   \ CB@    B@Ã B  @    B@ B  @    B@C B  @    B@ B  @    B@Ã B   @  B ÀÿÅ    AB 	 ÁB	 ÜAÄ   E  KBÀÁ	 \  ÁÂ	 ÜAËÁB A
 Å  ËBÀA	 ÜËÂÀÜ @Ê@ ÀÄ  ÂB  Â  Á
 UÂÜAÄ   E  KBÀÁÂ
 \ÜA  Ä   E  KBÀÁ \ÜA  Ä   E  KBÀÁB \ÜA  Ä   E  KBÀÁ \ÜA  Ä   E  KBÀÁÂ \ÜA  ËÁB A ÜAÄ    ÜA Å    AB B ÜA Å  ËÁÀA Ü@    B@ Â  Ã B@    B@ Â  C KÍÁÃ \ZC  @  Î AC ZC    A CB@    B@Ã Â   W@Ï@  Î AC ZC    A CB@    B@ Â  Ã  Ð AC ZC    A CB @  B  @  B @  B   A      config    lookup    /network/interface    get    Network    wlan_is_available    gprs_is_available 	   ethernet 
   box_start    network    Network interface 	   add_data    <span class=label>WATCH OUT:  #    hardware is not detected!</span>
 &   onChange="set_visibility(this.value==    'wifi','wifisettings'    'gprs','gprssettings'    ); 5   set_visibility(this.value!='gprs', 'dhcp_settings')"    gprs    range    ethernet,gprs    wifi    ethernet,wifi    Wifi    id='wifisettings'     /network/wifi/essid    /network/wifi/keytype    /network/wifi/key    Gprs    id='gprssettings'     /network/gprs/pin    /network/gprs/username    /network/gprs/password    /network/gprs/apn    /network/gprs/number    IP Settings    id='dhcp_settings'    /network/dhcp C   onClick='set_visibility(this.value=="false","static_ip_settings")'     <table id='static_ip_settings'     false    >    /network/ip/address    /network/ip/netmask    /network/ip/gateway    /network/ip/ns1    /network/ip/ns2 	   </table>    NQuire protocol settings 
   /cit/mode -  onChange="enable_disable(this.value!='UDP' && this.value!='offline','tcp_port');enable_disable(this.value!='TCP server' && this.value!='TCP client' && this.value!='TCP client on scan' && this.value!='offline','udp_port');enable_disable(this.value!='TCP server' && this.value!='offline','remote_ip') "    /cit/udp_port    id='udp_port'    find    TCP    offline 
    disabled        /cit/tcp_port    id='tcp_port'    UDP    /cit/remote_ip    id='remote_ip'    TCP server     K  s  s  s  t  t  t  u  u  u  w  w  w  w  x  x  z  z  z  {  {  {  |  |  |  |  ~  ~  ~  ~  ~  ~                                                                                                                                                                                                                                                   ¡  ¡  ¡  ¡  ¡  ¡  ¡  ¢  ¢  ¢  ¢  ¢  ¢  ¢  £  £  £  £  £  £  £  ¤  ¤  ¤  ¥  «  «  «  «  «  «  ¬  ¬  ¬  ¬  ¬  ¬  ¬  ¬  ¬  ­  ­  ®  ®  ®  ®  ®  ®  ®  ®  ®  ¯  ¯  ¯  ¯  ®  ¯  ¯  ­  °  °  °  °  °  °  °  ±  ±  ±  ±  ±  ±  ±  ²  ²  ²  ²  ²  ²  ²  ³  ³  ³  ³  ³  ³  ³  ´  ´  ´  ´  ´  ´  ´  µ  µ  µ  ¶  ¶  ¶  ¸  ¸  ¸  ¸  ¸  ¹  ¹  ¹  ¹  º  º  º  º  º  º  º  º  º  »  »  »  »  »  »  »  »  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  »  ½  ½  ½  ½  ½  ½  ½  ½  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ½  ¿  ¿  ¿  ¿  ¿  ¿  ¿  ¿  À  À  À  À  À  À  À  ¿  Á  Á  Á  Ã  Ã  Ã  Ä  Ä  Ä  Å  	      client     J     request     J  	   itf_node    J  
   ift_value    J  	   has_wlan    J  	   has_gprs    J     itf_config    J     extra :   ¬      mode   J     
   draw_head    body_begin    form_start 
   draw_node    box_end    display_by_default 	   form_end 	   body_end     È     ñ      À   @   À   @   Ê  É@@ÉÀ@
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
    disabled    /cit/messages/%s/%s/valign    top )   onChange='enable_disable(value=="top", "    ")' *   onChange='enable_disable(value=="left", "    /cit/messages/%s/%s/%s     /cit/messages/idle/picture/show i   onClick="enable_disable(this.checked,'xpos');enable_disable(this.checked,'ypos')" id='show_idle_picture'     /cit/messages/idle/picture/xpos 
   id='xpos'     /cit/messages/idle/picture/ypos 
   id='ypos'    </tr>
    /cit/messages/fontsize    /cit/messages/fontsize/small    /cit/messages/fontsize/large Ë   <script type="text/javascript"> 
	enable_disable(document.getElementById('show_idle_picture').checked, 'xpos');
	enable_disable(document.getElementById('show_idle_picture').checked, 'ypos');
</script> 
     ñ   É  É  É  Ê  Ê  Ê  Ì  Ì  Í  Í  Í  Î  Î  Ï  Ð  Ð  Ð  Ð  Ð  Ð  Ð  Ð  Ò  Ò  Ò  Ô  Ô  Ô  Ô  Ö  Ö  Ö  Ö  Ö  ×  ×  ×  ×  ×  Ù  Ù  Ù  Ú  Ú  Ú  Ú  Û  Û  Û  Û  Û  Û  Û  Û  Û  Û  Û  Ú  Û  Ý  Ý  Ý  Þ  Þ  Þ  Þ  ß  ß  ß  à  à  à  à  á  â  â  â  â  ã  ã  ã  ã  ã  ã  ä  ä  ä  ä  ä  ä  ä  ä  ä  ä  ä  ä  ä  å  å  å  ç  ç  ç  ç  ç  ç  ç  ç  ç  ç  ç  ç  ç  è  è  è  ë  ë  ì  ì  ì  ì  ì  ì  î  î  ï  ï  ï  ï  ï  ï  ñ  ñ  ñ  ñ  ñ  ñ  ñ  ñ  ñ  ò  ò  ò  ò  ò  ò  à  ò  ô  ô  ô  Þ  ÷  ÷  ÷  ø  ø  ø  ú  ú  ú  ú  û  û  û  û  ü  ü  ü  ü  ü  ü  ý  ý  ý  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ                                               Ô    	  	  	  	  	  	  	  	  	  
  
  
  
  
  
  
                                                client     ð      request     ð   	   msg_list    ð   	   key_list    ð      (for generator)    Í      (for state)    Í      (for control)    Í      _    Ë      msg    Ë      node "   Ë      (for generator) -   ;      (for state) -   ;      (for control) -   ;      _ .   9      item .   9      (for index) A         (for limit) A         (for step) A         row B         (for generator) H         (for state) H         (for control) H         _ I         item I         extra J         node          idle_picture_show £   Å      
   draw_head    body_begin    form_start    draw_node_label    draw_node_value    draw_node_label_start    draw_node_value_data    draw_node_label_end    box_end 
   draw_node 	   form_end 	   body_end          i     À   @   À   @   À   @    À   A  A  @ @  À@ AÀ
@ Á Á EA  FÂÀEB  \ Z  E ÂB\ Z  @@  ÀC  ÌÁ!  @û  A @@  Á DB Â    A@  Á D A   À   Á DÁ @   À   Á D @  @E  @À Å@  Æ Â ÅA   Ü Ú  @Å ÂBÜ ÚA   ÅÁ ËÄAÂ ÂBUÜÚ   EB  Á ÃBB@  B@ EB  ÁÂ ÃBB¡  ö@  À@ A@  ÅÀ Ë ÄAA ÜÆ@ÇÇ  À Á Á EA  FÂ EB  \ Z  À	E ÂB\ Z  EÂ KÄÁÂ ÃBÕ\Z    ÅB  A ÃBBÀ   C Á D @ Õ @ ÕCB ÌÁ@ Å  AÃ ÃBB!   ô À   @ @  À@ A    À   A  A	 @  À   Á DA	 @   À   Á D	 @   À   Á DÁ	 @   À   @ @  À@ J@   À   A  AA
 @  À   Á D
 @   À   Á DÁ
 @   À   @    À    AA @  À   Á D @   À   @ À  L        À   A  AA @  À   Á D @   À   Á DÁ @   À   Á D @   À   Á DA @   À   Á D @   À   Á DÁ @   À   Á D @   À   Á DA @   À   Á D @   À   Á DÁ @   À   Á D @   À   @   À   @  À   @   =   
   box_start    scanner 	   Barcodes    type    em2027    onChange='       ð?   ipairs    enable_disable    does_firmware_support    is_2d_code    name 1   set_visibility(this.value=="1D and 2D","2d_code_    ");    '    config    lookup    /dev/scanner/barcodes &   /dev/scanner/multi_reading_constraint ,   /dev/scanner/prevent_duplicate_scan_timeout    /dev/scanner/enable_barcode_id 	   add_data #   <tr><td colspan='2'><hr/><td></tr>    /dev/scanner/enable-disable/    logf    LG_DBG    showing code %s $   Code '%s' is no configuration item.        value    1D only     style='display:none'    id='2d_code_ 	   tostring    LG_WRN )   Code '%s' not found in the configuration    Scanning modes Imager    /dev/scanner/illumination_led !   /dev/scanner/reading_sensitivity    /dev/scanner/aiming_led    em1300    Scanning modes '   /dev/scanner/default_illumination_leds    /dev/scanner/1d_scanning_mode    extscanner    External scanner    /dev/extscanner/raw    Scanner_rf    is_available    Mifare scanner    /dev/mifare/key_A    /dev/mifare/relevant_sectors    /dev/mifare/cardnum_format    /dev/mifare/send_cardnum_only    /dev/mifare/sector_data_format "   /dev/mifare/sector_data_seperator    /dev/mifare/suppress_beep +   /dev/mifare/prevent_duplicate_scan_timeout &   /dev/mifare/msg/access_violation/text %   /dev/mifare/msg/incomplete_scan/text *   /dev/mifare/msg/transaction_error_message     i                    !  !  !  !  !  "  "  "  "  #  $  %  %  %  %  %  &  &  &  &  &  &  &  &  &  &  '  '  '  '  '  (  %  )  +  +  +  -  -  -  -  -  -  -  -  -  .  .  .  .  .  .  .  0  0  0  0  0  0  0  2  2  2  2  2  2  2  4  4  4  7  7  7  7  7  8  8  8  8  8  8  8  8  8  8  9  9  9  9  9  9  :  :  ;  ;  ;  ;  ;  ;  <  <  <  <  <  >  >  >  >  >  >  7  @  C  C  C  C  D  E  E  E  E  E  E  E  F  H  I  I  I  I  I  J  J  J  J  J  J  J  J  J  J  K  K  K  K  K  K  L  L  M  M  M  M  M  M  N  N  N  N  N  N  N  N  N  N  N  N  N  O  O  Q  Q  Q  Q  Q  Q  I  S  W  W  W  Y  Y  Y  Y  Z  Z  Z  Z  Z  \  \  \  \  \  \  \  ]  ]  ]  ]  ]  ]  ]  ^  ^  ^  ^  ^  ^  ^  _  _  _  b  b  b  b  c  c  c  c  c  d  d  d  d  d  d  d  e  e  e  e  e  e  e  f  f  f  i  i  i  i  i  j  j  j  j  j  j  j  k  k  k  n  n  n  n  n  o  o  o  o  o  p  p  p  p  p  p  p  q  q  q  q  q  q  q  r  r  r  r  r  r  r  s  s  s  s  s  s  s  t  t  t  t  t  t  t  u  u  u  u  u  u  u  v  v  v  v  v  v  v  w  w  w  w  w  w  w  x  x  x  x  x  x  x  y  y  y  y  y  y  y  z  z  z  z  z  z  z  {  {  {  ~  ~  ~                client     h     request     h     onof    >      n    >      (for generator)    +      (for state)    +      (for control)    +      _    )      code    )      (for generator) S   y      (for state) S   y      (for control) S   y      _ T   w      code T   w      node d   w      display_style ~   »      n    »      (for generator)    »      (for state)    »      (for control)    »      _    ¹      code    ¹      node    ¹      
   draw_head    body_begin    form_start 
   draw_node    lgid    box_end 	   form_end 	   body_end       Ï        À   @   À   @   À   @    À   A  A  @  À   Á  AA @    À   @         À   A  AÁ @  À   Á  A B  A @ À   Á  A B  Á @ À   Á  A B  A @ À   Á  A B  Á @ À   Á  A B  A @  À   @    À   A  A @  À   Á  AÁ B   @À   AÁ @EE À @      Ä    EÁ  KÁÁA \  Á   ÕÜ@Ä    EÁ  KÁÁÁ \  Á   ÕÜ@Ä    EÁ  KÁÁA \  Á   ÕÜ@Ä     Ü@ Å      AA  Á Ü@ Ä    EÁ  KÁÁ \Ü@  Ä    EÁ  KÁÁA \  Á Ü@ÅÀ  Ë ÁAA ÜÆ@ÅÅ ÁÀ Ú@    Á  @  Á  AÂ Â  	 @BA @  A   @  A  ÁA	 A @  Á  A	 A  @  Á  AÂ	 A  @  Á  A
 A  @  Á  AB
 A  @  Á  A
 A  Á  AÁ
 D  À   A \AD  ÅÁ  ËÁAB Ü  A BEE Â B     U\AD   \A E    ÁA  Â \A D  ÅÁ  ËÁA Ü\A  D  ÅÁ  ËÁAB Ü\A  D  ÅÁ  ËÁA Ü\A  D  ÅÁ  ËÁAÂ Ü\A  D   \A E    ÁA   \A D  ÅÁ  ËÁAB Ü\A  D  ÅÁ  ËÁA Ü\A  D  ÅÁ  ËÁAÂ Ü  A \AEÁ  KAÎÁÁ \Î AÁ ZA    A À  Â  AÂ B   ÀÂA À  A Á  ANB WÀE@  À  B  A A À  Â  AÂ A  À  Â  A A  À  Â  AB A  À  Â  A A  À  Â  AÂ A  À  Â  A A   À  A À  A  À  A   E   
   box_start    miscellaneous    Device    config    lookup 
   /dev/name    offline_server    Offline database    /cit/offlinedb/enabled ã   onClick="enable_disable(value=='true','offlinedb_mode');enable_disable(value=='true','offlinedb_import_busy_msg');enable_disable(value=='true','offlinedb_import_busy_msg_pos');enable_disable(value=='true','offlinedb_failure')"    /cit/offlinedb/mode     id='offlinedb_mode'    /cit/offlinedb/import_busy_msg      id='offlinedb_import_busy_msg' #   /cit/offlinedb/import_busy_msg_pos $    id='offlinedb_import_busy_msg_pos'    /cit/offlinedb/failure     id='offlinedb_failure'    Authentication    /dev/auth/enable    onClick="enable_disable(value=='true', 'auth_username');enable_disable(value=='true', 'auth_password');enable_disable(value=='true', 'auth_password_shadow')"    value    true     
    disabled    /dev/auth/username     id='auth_username'    /dev/auth/password     id='auth_password'    /dev/auth/password_shadow     id='auth_password_shadow'    Programming barcode security    /cit/programming_mode_timeout    /dev/barcode_auth/enable 9   onClick="enable_disable(value=='true', 'security_code')"     /dev/barcode_auth/security_code     id='security_code'    Text and messages    /cit/messages/idle/timeout    /cit/messages/error/timeout    /cit/codepage    /cit/message_separator    /cit/message_encryption    /cit/enable_message_tag 7   onClick="enable_disable(value=='true', 'message_tag')"    /cit/message_tag     id='message_tag'    Interaction    /dev/display/contrast    /dev/beeper/volume    /dev/beeper/beeptype    /cit/disable_scan_beep    GPIO    /dev/gpio/prefix    /dev/gpio/event_counter    /dev/gpio/method ;   onChange="enable_disable(this.value=='Poll','poll_delay')"    get    Poll    /dev/gpio/poll_delay     id='poll_delay'    /dev/touch16/name    Touch screen    /dev/touch16/prefix    /dev/touch16/timeout    /dev/touch16/keyclick    /dev/touch16/invert !   /dev/touch16/minimum_click_delay #   /dev/touch16/send_active_keys_only                                                                                                                                                                                                                                                                                                                ¡  ¡  ¡  ¡  ¡  ¡  ¡  ¢  ¢  ¢  ¢  ¢  ¢  ¢  ¢  ¢  £  £  £  £  £  £  £  £  £  £  £  ¤  ¤  ¤  ¤  ¤  ¤  ¤  ¤  ¤  ¤  ¤  ¥  ¥  ¥  §  §  §  §  §  ¨  ¨  ¨  ¨  ¨  ¨  ¨  ©  ©  ©  ©  ©  ©  ©  ª  ª  ª  ª  ª  ª  ª  «  «  «  «  «  «  «  ¬  ¬  ¬  ¬  ¬  ¬  ¬  ­  ­  ­  ­  ®  ®  ®  ®  ®  ®  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  ¯  °  °  °  ²  ²  ²  ²  ²  ³  ³  ³  ³  ³  ³  ³  ´  ´  ´  ´  ´  ´  ´  µ  µ  µ  µ  µ  µ  µ  ¶  ¶  ¶  ¶  ¶  ¶  ¶  ·  ·  ·  ¹  ¹  ¹  ¹  ¹  º  º  º  º  º  º  º  »  »  »  »  »  »  »  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ¼  ½  ½  ½  ½  ½  ½  ½  ½  ½  ½  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¾  ¿  ¿  ¿  Á  Á  Á  Á  Á  Á  Â  Â  Â  Â  Â  Ã  Ã  Ã  Ã  Ã  Ã  Ã  Ä  Ä  Ä  Ä  Ä  Ä  Ä  Å  Å  Å  Å  Å  Å  Å  Æ  Æ  Æ  Æ  Æ  Æ  Æ  Ç  Ç  Ç  Ç  Ç  Ç  Ç  È  È  È  È  È  È  È  É  É  É  Ì  Ì  Ì  Í  Í  Í  Ï        client          request          extra i        extra ­        emtn ç        gpi_poll_delay_disabled K       
   draw_head    body_begin    form_start 
   draw_node    box_end 	   form_end 	   body_end     Ò    	       @@  À@À    AA AÁ @    AA A @   À   @   À   @ @ Å ÆÀÂ AA ÜÚ    @  Á Á A AD  AÁÄÀ
ÅB BZ  	CD  CCD  À  ¢C CCD  À ¢C CCD  À  ¢C CCD  À @ ¢C  CCD C CF C @B!A  @ôAD Á AÇA @  A  @  A  @  Á ÁA A @    AB A  @  A  @  A À EÁ Á A AD A A @  A   "      config    get    /cit/loglevel    3    lookup    /cit/webui_loglevel    setraw    info    event       ð?   io    popen V   cat /home/ftp/messages.2 /home/ftp/messages.1 /home/ftp/messages.0 /home/ftp/messages    r 
   box_start    log    System log 	   add_data    <table class=log>    lines    match 7   ^(%a+%s+%d%d? %d%d:%d%d:%d%d) .*lua: (%S+) (%S-): (.+)    <tr>     <td class=log-%s>%d</td>     <td class=log-%s>%s</td>    </tr>
    flush 	   </table>    close    Log settings    logf    LG_WRN    Could not read the log 4   <table>ERROR: could not read the system log</table>        Ô  Ô  Ô  Ô  Ô  Ô  Õ  Õ  Õ  Õ  Õ  Õ  Õ  Õ  ×  ×  ×  ×  ×  ×  ×  Û  Û  Û  Ü  Ü  Ü  Þ  à  à  à  à  à  á  á  â  â  â  â  â  ã  ã  ã  ä  ä  ä  é  é  é  ê  ê  ë  ë  ë  ì  ì  ì  ì  ì  ì  ì  î  î  î  î  î  î  î  ï  ï  ï  ï  ï  ï  ï  ð  ð  ð  ð  ð  ð  ð  ð  ð  ñ  ñ  ñ  ò  ò  ó  ä  ô  ö  ö  ö  ÷  ÷  ø  ø  ø  ú  ú  ú  û  û  û  û  û  ü  ü  ü  ü  ü  ü  ü  ý  ý  ý  þ  þ  þ  þ                                client           request           line          f !         (for generator) -   \      (for state) -   \      (for control) -   \      l .   Z   	   datetime 1   Z      level 1   Z   
   component 1   Z      msg 1   Z   	   
   draw_head    body_begin    to_html_escapes    box_end    form_start 
   draw_node 	   form_end    lgid 	   body_end     	     0      À   @   À   @    À   A  A  @ À@  @À@ A @À@  @À@ Á @À@  @À@ A @À@ A @À@  @À@ Á @À@  @  À   @  À   @      
   box_start    miscellaneous    Device 	   add_data 6   Click the button below to reboot the device: <br><br>    <form method='post'> +   <input type=hidden name=p value=rebooting> #   <input type=submit value='Reboot'>    </form> a   <br><br>Click the button below to reset factory default settings and reboot the device: <br><br> *   <input type=hidden name=p value=defaults> %   <input type=submit value='Defaults'>     0                                                                                                         client     /      request     /      
   draw_head    body_begin    box_end 	   body_end     !  @    
	   Ë @ AA   Á    AÂ  UAÜ@     	   add_data a   <meta http-equiv='refresh' content="30; url=javascript:window.open('/','_top');">

<br><br><br>    <br><br>

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
	progressbar(0,      );
</script>
     	   "  %  %  =  =  ?  ?  "  @        client           intro           delay                B  O         À   @   À   @    À   A  A  @ À   AÁ@ @   À   @         show_page_rebooting f   		The NQuire is now rebooting. This page will automatically attempt to
		reconnect after 40 seconds.        D@   os    execute    reboot        D  D  D  E  E  E  G  G  I  I  G  K  K  K  K  M  M  M  O        client           request           
   draw_head    body_begin 	   body_end     R  U         @@@    À     @        cit    restore_defaults        S  S  S  T  T  T  T  U        client           request              page_rebooting     \          Å@    A  ÁÀ ÆÁ ÚA    ÁA @   Á ÁÀ ÀA@Á    ABFÁ  ä     A 
   
  J  Á ÆÃ ËBÃA ÜÚ   Ã @  I CÃ   ÀFÃ C À ÃFZC    ID¡  ùÁ ÀÅ  C  D  Ã À  ÜB ¡  ýÅ  À"Å@E "ÅÆÁÅÆE  B  Ä  C E KÃÆÁ \ À  \B E KÂÆÁ \@Å E KÂÆÁ \@D @ÀÀ@E  B  Ä   \B 	AG	AG	AÇ	AG WA@KBCÁ \ZB   KBCÁÂ \Z  E  B  Ä   \B 	AGD IBG	AÇ	AG@D W@  WÁ KBÃÁB \Z  ÀE  B  Ä   \B 	AG	AGD IBÇD IBG@E KÂÆÁ \@ E KÂÆÁÂ \@E  B  Ä  Ã \B IIIIIÉIIIÉD W@ÀE	 \Ã @ IÀE  Â	 Ä  
 \B D IBGD IBGD IBÇD IBG@ÅD IÁIÁIAÁ À@Å ËBÊ@ÜÚ  ÀÊÀJ@Ë@K WD  B C    EC    Á  C 
 C    EC    ÁÃ  C@ÃÆ W@KÌÀ \ZC  ÀE  Ã	 Ä  D @ÄÆ À \CD ICÇ E  C  Ä   @ À \C  ¡  Àî   @  ÅA    AÂ A  AM A  A ÁM AB A  ÁN CB AAÉ   AÉWA@  ÅA    A A ÁÀ A ÄÁ Ä Á ÄÁ¡Ä Á¡ÄÁ¢Ä Á¢ÄÁ£Ä Á£ÄÁ¤Ä Á¤ÄÁ¥Ä Á¥ÄÁ¦ÆÃ ÆAÓ Ú   FÂZ  @ Â  PKS ÁÂ  \B KS ÁB  \B KS Á Ã \B KU ÁB \BKU Á \B@   À \BKU ÁÂ \BÞ    X      logf    LG_DBG (   request.method=%s, request.post_data=%s    method 
   post_data    nil        POST    string    gsub    ([^&=]+)=([^&;]*)[&;]?    pairs    param    match    ^set%-(.+)$    escapes_to_binstr    ^default%-(.+)$    set-    false    keyvalue['%s'] = '%s'    /dev/auth/enable    true    /dev/auth/username    /dev/auth/password    /dev/auth/password_shadow 1   /dev/auth/username=%s, usr=%s, pwd=%s, shadow=%s    config    get "   Nothing changed to authentication    ^%s    %s$    Incorrect format of username     a   passwords differs from password shadow, or the password still contains a partial hidden password /   usr and password ignore because of page resend     /dev/auth/encrypted    encrypt_password    LG_WRN *   undefined situation for username password    lookup    type    boolean    appearance 	   checkbox 2   Skipped setting of %s because of some other error #   Webui data entry error on field %s    set (   Error setting node %s from '%s' to '%s' "   changed node %s from '%s' to '%s'    Applied settings    display 	   set_font       2@   show_message 	   Applying 	   settings    evq    push    cit_idle_msg       @   Requesting authorisation    Authorization    top    bottom    main    menu    home    network 	   messages    scanner    miscellaneous    log    reboot 
   rebooting 	   defaults    p    set_header    Content-Type    text/html; charset=UTF-8    Expires    Cache-control ,   no-cache, must-revalidate, proxy-revalidate 	   add_data @   <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
    <html>
    </html>        e  g          @Å@  ÆÀ   Ü A  @@           param 
   webserver    url_decode        f  f  f  f  f  f  f  f  f  f  f  g        name           attr              request   ^  ^  ^  ^  ^  ^  ^  ^  ^  ^  _  `  c  c  c  c  c  c  d  d  d  d  g  g  d  k  k  l  p  q  q  q  q  r  r  r  s  s  t  t  t  t  t  v  v  v  w  w  w  w  w  w  w  w  w  x  q  z  }  }  }  }  ~  ~  ~  ~  ~  ~  ~  }  ~                                                                                                                                                                                       ¡  ¢  £  £  ¤  ¤  ¤  ©  ©  ©  ©  ©  ©  ª  ª  ª  ª  ª  ª  «  «  «  «  «  ¬  ­  ®  ¯  °  °  ³  ³  ³  µ  µ  µ  ¶  ¶  ¶  ¶  ¶  ¸  ¸  ¸  ¸  ¸  ¹  ¹  º  º  »  »  ¼  ¼  ½  ¾  ¾  ¾  À  Á  Â  Æ  Æ  Æ  Æ  Ç  Ç  Ç  Ç  È  È  É  É  É  É  É  É  É  É  Ê  Ì  Ì  Ì  Î  Î  Î  Î  Î  Î  Î  Ï  Ï  Ï  Ï  Ð  Ð  Ð  Ð  Ð  Ð  Ð  Ò  Ò  Ó  Ó  Ô  Ô  Ô  Ô  Ô  Õ  Õ  Õ  Õ  Õ  Õ  Õ  Õ  Õ  Ö  Ö  Ö  Ø  Ø  Ø  Ø  Ø  Ø  Ø  Ø  Ù  Æ  Ý  à  à  á  á  á  á  á  â  â  â  â  â  â  ã  ã  ã  ã  ã  ä  ä  ä  ä  ä  ä  ç  ç  ç  ç  ç  ç  ê  ê  ê  ê  ê  ë  î  ï  ï  ð  ð  ñ  ñ  ò  ò  ó  ó  ô  ô  õ  õ  ö  ö  ÷  ÷  ø  ø  ù  ù  ú  ú  û  û  þ  þ  ÿ                                               
    
                          "      client          request          applied_setting         retval         skip      
   keyvalues         (for generator)     :      (for state)     :      (for control)     :      key !   8      val !   8      id $   8      cb_id .   8      (for generator) =   G      (for state) =   G      (for control) =   G      key >   E      value >   E      usr N   Õ      pwd O   Õ      pwd_shadow P   Õ      shadow Ã   Ç      salt Ã   Ç      crypted Ã   Ç      (for generator) ß   $     (for state) ß   $     (for control) ß   $     key à   "     value à   "     node ä   "     prev_value   "     pagehandlers c       p e       handler f          lgid    errors    hidden_password 	   page_top    page_bottom 
   page_main 
   page_menu 
   page_home    page_network    page_messages    page_scanner    page_miscellaneous 	   page_log    page_reboot    page_rebooting    page_defaults             E   @  Ä     KÁ@ \ \@  KÀ@ \  Á @E@ KÁ ÁÀ  \@  E@ KÁ ÁÀ A \@   
      logf    LG_INF    Setting loglevel to %s    get    info    config    set    /cit/loglevel    3    4                                                            node              lgid       $          @@   Ä   @ À   A @ Á  C@      
   webserver 	   register    /    config 
   add_watch    /cit/webui_loglevel    set                  !  !  !  !  !  !  !  $            on_webserver    set_webui_loglevel                            ^   d   k   t   x   }   }   }      Í   Í   Í   Í   Û   Û   Û   ä   ä   ä   ò   î   ú   õ   ÿ           !  !  8  G  G  k  k  k  k  k  k  o  Å  Å  Å  Å  Å  Å  Å  Å  Å                                              Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï                                @  !  O  O  O  O  U  U                                        $  $  $    $         lgid          hidden_password       
   draw_head          body_begin 	      	   body_end 
         to_html_escapes          draw_node_label_start          draw_node_label_end          draw_node_label          errors          draw_node_value_data          draw_node_value       
   draw_node          box_end           form_start !      	   form_end "      	   page_top $         page_bottom &      
   page_main '      
   page_menu )      
   page_home /         display_by_default 0         page_network 9         page_messages F         page_scanner O         page_miscellaneous W      	   page_log a         page_reboot f         page_rebooting l         page_defaults n         on_webserver          set_webui_loglevel           