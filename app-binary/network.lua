LuaQ     @network.lua           =      A@    À@@  A@   Â   $      dA         ¤         äÁ         $               dB ¤ äÂ $         dC   ¤                 Ã$Ä         d    GÄ dD                    G   	      module    Network    package    seeall    network    off    gprs_is_available    wlan_is_available    new               
      @@À     À@     EÁ    Á    @A   A@AA              io    open    logf    LG_WRN    Could not open file '%s': %s 
   /dev/null                                                                                fname           mode           fd          err             lgid        @    
`   E   @  Ä     \@ D  À@ Á  \@Á  @À  BA BË@Á AÁ Ü@Ë@Á A Ü@@Ë@Á AA Ü@Ë@Á A Á BÂ Á UÁÜ@Ë@Á AA Á B Á UÁÜ@Ë@Á AÁ Á B Á UÁÜ@Ë@Á AA Ü@Ë@Á A Ü@ËÅ Ü@ ÀE@ÅÀ Ë ÂA ÜW@ÆÀÄ  F AÁ ÜAÁ ÅÁ ËÂAB Ü AAÁ ÅÁ ËÂA Ü AÅA         logf    LG_DBG     Configuring Ethernet connection    fname_interfaces    a    write    auto eth0
    config    get    /network/dhcp    true    iface eth0 inet dhcp
      vendor NQuire200
    iface eth0 inet static
      address     /network/ip/address    
      netmask     /network/ip/netmask      gateway     /network/ip/gateway      pre-up killall udhcpc; true
    close    false    /network/interface    gprs    fname_resolv_conf    w    nameserver     /network/ip/ns1    /network/ip/ns2     `   !   !   !   !   !   %   %   %   %   &   &   &   (   (   (   (   *   *   +   +   +   ,   ,   ,   ,   .   .   .   /   /   /   /   /   /   /   /   /   0   0   0   0   0   0   0   0   0   1   1   1   1   1   1   1   1   1   3   3   3   4   4   4   5   5   9   9   9   9   9   9   9   9   :   :   :   :   ;   ;   ;   ;   ;   ;   ;   ;   ;   <   <   <   <   <   <   <   <   <   =   =   @         network     _      fd 	   _      dhcp    _      fd K   _         lgid    open_or_die     G       ¡   E   K@À \ Z@      E  À  Ä    \@ E@ KÁ ÁÀ \@ A Å@ ËÁAA ÜA A D Á Á \AÃ AAÃAAÃ A@ÄÀ AÃ AÀÀÄ@AÃ AAÃ AAÃB AÀÅ@AÃÂ AAÃ AAÃB AÆA  ÆÁF  @Ç À ËACA ÜA@ËACAÂ ÜAËACA B AC Á UÂÜAËACAÂ B A	 Á UÂÜAËACAB	 B A	 Á UÂÜAËACAÂ	 ÜAËACA
 ÜAËACAB
 ÜAËACA
 ÜAËACA ÜAËFÜA ÀÊ @ÅA ËÁA ÜW@ËÀÄ K A ÜBÃÂ ÅB ËÁA Ü BBÃÂ ÅB ËÁAC Ü BÆB   2      Network    wlan_is_available    logf    LG_DBG    Configuring wifi connection    config    get    /network/dhcp    /network/wifi/key    /network/wifi/keytype    /network/wifi/essid    /tmp/wpa_supplicant.conf    w    write    network={
    	ssid="%s"
    	scan_ssid=1
    off    	key_mgmt=NONE
    WEP    	wep_key0=%s
    	wep_tx_keyidx=0
    WPA / WPA2    	key_mgmt=WPA-PSK
    	psk="%s"
    }
    close    fname_interfaces    a    true    iface wlan0 inet dhcp
    iface wlan0 inet static
      address     /network/ip/address    
      netmask     /network/ip/netmask      gateway     /network/ip/gateway      pre-up killall udhcpc; true
 '     pre-up killall wpa_supplicant; true
 ?     pre-up wpa_supplicant -B -iwlan0 -c/tmp/wpa_supplicant.conf
 )     pre-down killall wpa_supplicant; true
    false    /network/interface    gprs    fname_resolv_conf    nameserver     /network/ip/ns1    /network/ip/ns2     ¡   I   I   I   I   I   J   M   M   M   M   M   O   O   O   O   P   P   P   P   Q   Q   Q   Q   R   R   R   R   V   V   V   V   X   X   X   Y   Y   Y   Z   Z   Z   \   \   ]   ]   ]   ]   ^   ^   _   _   _   `   `   `   a   a   a   a   b   b   c   c   c   d   d   d   f   f   f   g   g   n   n   n   n   p   p   q   q   q   q   s   s   s   t   t   t   t   t   t   t   t   t   u   u   u   u   u   u   u   u   u   v   v   v   v   v   v   v   v   v   x   x   x   y   y   y   z   z   z   {   {   {   }   }   }   ~   ~                                                                                                            network            dhcp           key           keytype           essid           fd           fd K          fd              lgid    open_or_die        5   ¦   E   K@À \ Z@      E  À  Ä    \@ D  @A Á \ÀÁ  ABA  @  ÀÂ @   Á  A ËÀAE FAÂ \ Ü@  ËÀBÜ@ Ä  Á AA ÜÁÁ ABÁ  A  ÁÂA A DAÁ A  FE A EA KÅÁÁ \W Æ ÁAB @ A ÆÁF B ËÁA@ ÅB ËÅAC ÜUÂÜAËÁBÜA ÁA BBA B EÃ ÅB ËÅA ÜCH FH  A  ÁBA  ÆAH B ËÁAE FBÂÂ ÅB ËÅA	 ÜC EC	 EC KÅÁ	 \\  ÜA  ËÁBÜA ÅA ÆÄÂ	 FBH BÜA Ä H AB ÜÂÁ
 BÂÂB B DAÂ	 H UB  FÂF B KÂAÅ ÆBÂC
 EC KÅÁÃ \C ED Ü  \B  KÂB\B   *      Network    gprs_is_available    logf    LG_DBG    Configuring GPRS connection    fname_interfaces    a    write    string    format y   iface gprs inet ppp
  pre-up killall udhcpc; true
  provider gprs
  post_up /etc/ppp/ip-up
  pre-down /etc/ppp/ip-down

    close    /etc/ppp/ip-up    w ·  #!/bin/sh

RC=/etc/resolv.conf
RCO=$RC.org

if ! grep "generated by /etc/ppp/ip-up" $RC > /dev/null; then
	cp $RC $RCO
fi

echo "# generated by /etc/ppp/ip-up" > $RC
                              
# TODO FIX: for some unknown reason the following condition does not work:
#if test -n "$USEPEERDNS"; then
#	if test -n "$DNS1"; then
		echo "nameserver $DNS1" >> $RC
#	if
#	if test -n "$DNS2"; then
		echo "nameserver $DNS2" >> $RC
#	if
#fi
    /etc/ppp/ip-down    RC=/etc/resolv.conf
RCO=$RC.org

if grep "generated by /etc/ppp/ip-up" $RC > /dev/null; then
	if test -f $RCO; then
		rm -f $RC
		mv $RCO $RC
	fi
fi
    os    execute )   chmod +x /etc/ppp/ip-up /etc/ppp/ip-down    fname_peer    config    get    /network/gprs/username        user     
    fname_chap_secrets     *     /network/gprs/password   %s %s
connect %s
disconnect %s
crtscts 
lock
updetach
hide-password
defaultroute
usepeerdns
holdoff 3
ipcp-accept-local
lcp-echo-failure 8
lcp-echo-interval 3
noauth
noipdefault
novj
novjccomp
nodeflate
nobsdcomp
#replacedefaultroute
persist
lcp-echo-interval 3
lcp-echo-failure 12
	    /dev/modem/device    /dev/modem/baudrate    fname_chat_connect    fname_chat_disconnect j  #!/bin/sh -e
exec /usr/bin/chat -V -s -S \
	ABORT BUSY \
	ABORT DELAYED \
	ABORT "NO ANSWER" \
	ABORT "NO DIALTONE" \
	ABORT VOICE \
	ABORT ERROR \
	ABORT RINGING \
	TIMEOUT 3 \
	"" ATZ \
	OK-\\k\\k\\k\\d+++ATH-OK ATE1 \
	OK AT+CPIN? \
	CPIN:\\sREADY-\\dAT+CPIN=%s-OK "" \
	TIMEOUT 30 \
	"" AT+CGDCONT=1,\"IP\",\"%s\",,0,0 \
	OK ATD%s \
	CONNECT \\d\\c \
	"" ""    /network/gprs/pin    /network/gprs/apn    /network/gprs/number 
   chmod +x  û   #!/bin/sh -e
exec /usr/bin/chat -V -s -S\
	ABORT OK\
	ABORT BUSY\
	ABORT DELAYED\
	ABORT "NO ANSWER"\
	ABORT "NO CARRIER"\
	ABORT "NO DIALTONE"\
	ABORT VOICE\
	ABORT ERROR\
	ABORT RINGING\
	TIMEOUT 12\
	"" \\k\\k\\k\\d+++ATH\
	"NO CARRIER-AT-OK" ""
	 
   %s "" %s
     ¦                                                         ¡         ¢   ¢   ¦   ¦   ¦   ¦   §   §   §   ¼   §   §   ½   ½   À   À   À   À   Á   Á   Á   Ë   Á   Á   Ì   Ì   Í   Í   Í   Í   Ñ   Ñ   Ñ   Ñ   Ò   Ò   Ò   Ò   Ó   Ó   Ô   Ô   Ô   Ô   Ô   Ô   Ö   Ö   Ö   Ö   ×   ×   ×   ×   ×   ×   ×   ×   ×   Ø   Ø   Ú   Ú   Ú   ò   ó   ó   ó   ó   ô   ô   ô   ô   õ   ö   Ú   Ú   ÷   ÷   û   û   û   û   ü   ü   ü                             ü   ü                             (    )  )  *  *  *  *  *  *  .  .  .  .  /  /  /  /  0  0  0  0  1  1  1  1  /  /  3  3  5  
      network     ¥      fd    ¥      fd    ¥      fd '   ¥      fd 7   ¥   	   username ;   ¥      chapfd G   R      fd h   ¥      fd    ¥      fd    ¥         lgid    open_or_die     <  L   $   E   @  Ä     \@ D  À@ Á  \@Á  @@Á Á @@Á  @@Á A @@Á Á @Â @   À   @  À   @   À   @         logf    LG_INF    Configuring interfaces    fname_interfaces    w    write 8   # Auto-generated by validator application, do not edit
    
 	   auto lo
    iface lo inet loopback
    close     $   >  >  >  >  >  @  @  @  @  A  A  A  B  B  B  C  C  C  D  D  D  E  E  E  F  F  H  H  H  I  I  I  J  J  J  L        network     #      fd 	   #         lgid    open_or_die    configure_ethernet    configure_gprs    configure_wifi     P  W           @@ A   À@   @A  C  ^   WA   B@  B  ^          io    input    /sys/class/net/eth0/carrier    read       ð?    1        Q  Q  Q  Q  Q  Q  Q  R  R  S  S  S  U  U  U  U  U  W        status               Y  \       E   F@À   \ À@   @        sys    get_macaddr    eth0    setraw        Z  Z  Z  Z  [  [  [  \        node           serial               _  g           @@ A   C      À@  @A @  ÀA @ ^          io    popen    /sbin/ifconfig    read    *all    match    inet addr:(%S+)    close        `  `  `  `  a  b  b  c  c  c  c  c  c  c  d  d  f  g        fd          ipaddr               m  º   
   A   @  @ÁÀ    AA ËAAÁ ÜÚ   @Å  A D   Ü@   ÅÀ Ë ÃAA ÜÃ Á D A   @Ä Á D A  @ ÀÄ E   ÁA  A@ EA   Á  AÁ FA     EA FÆZA  À @ Á U E  Ä  B \A EÁ KÄ\ Z   @  UEÁ KÄ\ Z   @ Á U@  UÀÄÀEA FÆZA  @ A UÃÀ @  U @ÄÀ @ Á UE A Ä  	 @\A  EA	 KÉÁÁ	 \AE
 KAÊÁ
 Â
 \A 	@KE  Ä   @\AE Á Ä   @ \AB H EA  ä         $B     @  \A  2          io    open    /proc/mounts    read    *a    match    root / nfs    logf    LG_WRN 3   Root filesystem is on NFS, not configuring network    config    get    /network/interface    wifi    Network    wlan_is_available    gprs    gprs_is_available 	   ethernet    LG_INF    Upping network on %s (   No hardware for network on interface %s    beeper    beep_error    opt    n    ifdown -f eth0;     LG_DBG %   opt -n found: not shutting down eth0    ifdown -f wlan0;     ifdown gprs;  	   sleep 5;    ifup -f eth0    ifup -f wlan0    sleep 5; ifup gprs .   Unknown interface '%s'. Not starting network.    evq    push    network_down    led    set    blue    flash    is_up  !   Bringing up network %s interface    LG_DMP    Running %q    runbg        ª  ´      W @ @  Å    AÁ    @À   @      Å@  A D   À Ü@I ÂÅ@ ËÂAÁ Ü@                     logf    LG_WRN -   An error occured configuring the network: %d    ?.?.?.?    LG_INF $   Configured network successfully: %s    is_up    evq    push    network_up        «  «  ¬  ¬  ¬  ¬  ¬  ¬  ¬  ®  ®  ®  ®  ®  ¯  ¯  ¯  ¯  ¯  ¯  °  ±  ±  ±  ±  ³  ³  ´        status           network           ip             lgid    get_current_ip_addr    upping_network     µ  ·         Å@    A    @        logf    LG_DMP 	   ifup> %s        ¶  ¶  ¶  ¶  ¶  ¶  ·        data           network              lgid    o  s  s  s  s  s  s  s  t  t  t  t  t  u  u  u  u  u  v  y  y  y  y  z  z  z  z  z  z  z  {  {  {  {  {  {  {  |  |  }  }  }  }  }  }  }                                                                                                                                                    ¡  ¡  ¡  ¡  ¢  ¢  ¢  ¢  ¢  £  ¥  ¥  ¥  ¥  ¥  ¥  §  §  §  §  §  §  ¨  ¨  ©  ©  ´  ´  ´  ´  ·  ·  ¸  ©  º        network           cmd          mounts       
   interface          current_ip :            lgid    get_current_ip_addr    upping_network     ½  Ä      D   \ Z   À  @   @  @ A  @        setraw    ?        ¾  ¾  ¿  ¿  À  À  À  À  Â  Â  Â  Ä        node           ipaddr             get_current_ip_addr     È  ç   
H      Ä   Ü A  @Á  D \ Á   Z   @A@ Á  À  W   AB D A  ÀA@Á Å AB A À A   Á Å A A WÀÃ@@AWÀ ÀWÀC Ú   @Á Å A A  Á ÅA A A È           flash    config    get    /network/interface    is_up 	   ethernet    on    led    set    blue    logf    LG_INF    Network is up    Network is down     Carrier restored    LG_WRN ?   Network error: Carrier lost (network re-init or cable failure)     H   É  Ê  Ê  Ë  Ë  Ë  Ë  Ì  Ì  Î  Î  Î  Î  Î  Î  Î  Î  Î  Ï  Ñ  Ñ  Ñ  Ò  Ó  Ó  Ó  Ó  Ó  Ô  Ô  Ô  Õ  Õ  Õ  Õ  Õ  Õ  Ö  Ö  Ö  ×  ×  ×  ×  ×  Û  Û  Ü  Ü  Ü  Ü  Ü  Ü  Ü  Ü  Ý  Ý  Þ  Þ  Þ  Þ  Þ  Þ  à  à  à  à  à  ã  æ  æ  ç        event     G      nw     G      new_led_status    G      current_carrier_status    G   
   interface    G      current_ip_addr 	   G         get_carrier_status    get_current_ip_addr    led_status    lgid    upping_network    carrier_status     ê      g       @        @  @  @  @À   A @ E FÀÁ    Á  \Z     @BÀ  @  ÀAÀ    @   ÀBÀ   EÁ  KÁÁA \  @   CÀ  @  ÀCÀ   @ @DÀ   AÁ  Å  A D  ÛA   ÁÁ Ü@   @Ë FAA ÜÚ      Â   @ Â@  Â  È   Å   D Á Ä  Ú   Á ÚA    ÁA Ü@Å Æ@Â  Ü@ @  Å  AÁ   @               Scanner_1d    is_available    config    get    /dev/modem/device    sys    open    r    close    rw    set_baudrate 	   tonumber    /dev/modem/baudrate    tcflush    write    AT 	   readport       4@     @@   logf    LG_DBG    gprs_is_available() data='%s'    <nil>    find    OK    LG_INF    %sGRPS hardware detected.        No     LG_WRN =   GPRS modem device '%s' not found (should probably be ttyS1).     g   ë  ë  ë  ì  ì  í  í  í  í  í  î  î  î  î  ï  ï  ï  ï  ï  ð  ð  ñ  ñ  ñ  ñ  ò  ò  ò  ò  ò  ò  ó  ó  ó  ó  ó  ó  ó  ó  ó  ó  ô  ô  ô  ô  õ  õ  õ  õ  õ  ö  ö  ö  ö  ö  ö  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ÷  ø  ø  ø  ø  ø  ø  ø  ø  ø  ø  ø  ø  ø  ù  ù  ù  ù  ù  ù  ù  ù  ù  ù  ù  ù  ú  ú  ú  ú  ú  ü  ü  ü  ü  ü  ü                dev    d      fd    d      data 8   ]         has_gprs_hw    lgid                  @       @  @ AÀ       @K@A \ KAÁÁ \Z  @ B H  a@  ýK B \@        	       io    popen 	   iwconfig    r    lines    match    wlan0    close                                	  	  	  
  
  
  
  
      	                    fd 
         (for generator)          (for state)          (for control)          l             has_wlan_hw       =    >   
@ 	@@	À@	@A	ÀA	@B	ÀB	@CD   	@ D  	@E  K@Ä Á \@d       À  EA A  À  @ À  EÁ A À  @ À  E AA  À  @ À  E AA  À  @   ÀF D   @  @G C @          fname_resolv_conf    /etc/resolv.conf    fname_interfaces    /etc/network/interfaces    fname_peer    /etc/ppp/peers/gprs    fname_chat_connect    /etc/ppp/gprs-connect-chat    fname_chat_disconnect    /etc/ppp/gprs-disconnect-chat    fname_chap_secrets    /etc/ppp/chap-secrets    is_up  
   configure    up    evq    signal_add    SIGCHLD    config 
   add_watch    /network/macaddress    get    /network/current_ip 	   /network    set    /dev/modem 	   register    check_network_status_timer    push       @       ,  0          Á@  @ À @ ÀÀ @         print    Reconfiguring network 
   configure    up        -  -  -  .  .  /  /  0        node           nw            >              !  "  #  &  &  '  '  *  *  *  *  0  2  2  2  4  4  4  4  4  4  4  5  5  5  5  5  5  5  6  6  6  6  6  6  6  7  7  7  7  7  7  7  9  9  9  9  9  9  :  :  :  :  :  :  <  =        netwrk    =      reconfigure    =      
   configure    up    carrier_status    get_carrier_status    get_macaddress    get_current_ip    on_check_network_status_timer =                     	   
            @   @   @            5  5  5  L  L  L  L  L  L  W  \  g  º  º  º  º  Ä  Ä  ç  ç  ç  ç  ç  ç  ç  é        ê          =  =  =  =  =  =  =  =    =        lgid    <      led_status    <      carrier_status    <      upping_network 	   <      open_or_die    <      configure_ethernet    <      configure_wifi    <      configure_gprs    <   
   configure    <      get_carrier_status    <      get_macaddress    <      get_current_ip_addr    <      up !   <      get_current_ip #   <      on_check_network_status_timer *   <      has_gprs_hw +   <      has_wlan_hw 0   <       