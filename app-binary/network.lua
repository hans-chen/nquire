LuaQ     @network.lua           (      A@    À@@$   d@      ¤      äÀ      $           dA   ä    $Â d ¤B   Á   d             ¤Ã              C         module    Network    package    seeall    off    new                
      @@À     À@     EÁ   ÁA    @A   A@A              io    open    logf    LG_WRN    network    Could not open file '%s': %s 
   /dev/null                                                                                fname           mode           fd          err                  :    
Z   E   @  Á  Á  \@ D    A Á@ \Á Á @  @B ÀBËÁ A Ü@ËÁ AA Ü@@ËÁ A Ü@ËÁ AÁ  AB ÁA UÁÜ@ËÁ A  ABÂ ÁA UÁÜ@ËÁ A  ABB ÁA UÁÜ@ËÁ A Ü@ËÁ AA Ü@ËÀÅ Ü@  FÀÄ   AF A ÜÁÁ Å ËAÂA ÜB AÁÁ Å ËAÂAB ÜB AÁÅA         logf    LG_DBG    network     Configuring Ethernet connection    fname_interfaces    a    write    auto eth0
    config    get    /network/dhcp    true    iface eth0 inet dhcp
      vendor NQuire200
    iface eth0 inet static
      address     /network/ip/address    
      netmask     /network/ip/netmask      gateway     /network/ip/gateway      pre-up killall udhcpc; true
    close    false    fname_resolv_conf    w    nameserver     /network/ip/ns1    /network/ip/ns2     Z                                          "   "   "   "   $   $   %   %   %   &   &   &   &   (   (   (   )   )   )   )   )   )   )   )   )   *   *   *   *   *   *   *   *   *   +   +   +   +   +   +   +   +   +   -   -   -   .   .   .   /   /   3   3   4   4   4   4   5   5   5   5   5   5   5   5   5   6   6   6   6   6   6   6   6   6   7   7   :         network     Y      fd 	   Y      dhcp    Y      fd E   Y         open_or_die     A          E   @  Á  Á  \@ E  K@Á Á \  @AÁ Å  Ë@ÁA Ü AAA D   ÁÁ \ÃB AÃAÃÂ A ÄÀ ÃB AÀÄ@ÃB AÃAÃ AÀ@Å@Ã AÃAÃ AAÆA   ÆF Â  Ç À ËCAB ÜA@ËCA ÜAËCAÂ  BA ÁB UÂÜAËCA  BAÃ ÁB UÂÜAËCA	  BAC	 ÁB UÂÜAËCA	 ÜAËCAÂ	 ÜAËCA
 ÜAËCAB
 ÜAËCAB ÜAËAFÜA Ê ÀÄ  ÂJ AÂ ÜÃ Å ËBÁAC ÜC BÃ Å ËBÁA ÜC BBÆB   /      logf    LG_DBG    network    Configuring wifi connection    config    get    /network/dhcp    /network/wifi/key    /network/wifi/keytype    /network/wifi/essid    /tmp/wpa_supplicant.conf    w    write    network={
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
    false    fname_resolv_conf    nameserver     /network/ip/ns1    /network/ip/ns2        C   C   C   C   C   E   E   E   E   F   F   F   F   G   G   G   G   H   H   H   H   L   L   L   L   N   N   N   O   O   O   P   P   P   R   R   S   S   S   S   T   T   U   U   U   V   V   V   W   W   W   W   X   X   Y   Y   Y   Z   Z   Z   \   \   \   ]   ]   d   d   d   d   f   f   g   g   g   g   i   i   i   j   j   j   j   j   j   j   j   j   k   k   k   k   k   k   k   k   k   l   l   l   l   l   l   l   l   l   n   n   n   o   o   o   p   p   p   q   q   q   s   s   s   t   t   x   x   y   y   y   y   z   z   z   z   z   z   z   z   z   {   {   {   {   {   {   {   {   {   |   |            network           dhcp 	         key          keytype          essid          fd          fd E         fd             open_or_die        ô    s   E   @  Á  Á  \@ D    A Á@ \Á Á BAA  ÅÁ ËÃAB Ü  ÅÁ ËÃA Ü  @  ÀÃ @    Æ D A ËAEÁ FÂ ÅÁ ËÃAÂ ÜÂ C EÂ KÃÁ \BE ÆE \Ü@  ËÀCÜ@ Ä   AE AA ÜÁÁ BÁÁ Â C EÂ KÃÁB \  A  ÁÃA  ÁFA AE UA   FE A KAÁA \AKÁC\A E FÁÆ ÆE Á\A D  G ÁA \ÁÂ BAÂ Â CÃ ÅÂ ËÃA Ü  A  ÁÃA   !      logf    LG_DBG    network    Configuring GPRS connection    fname_interfaces    a    write    string    format P   iface gprs inet ppp
  pre-up echo -en "\nAT+CPIN=%04d\n" > %s
  provider gprs

 	   tonumber    config    get    /network/gprs/pin    /dev/modem/device    close    fname_peer    w #  user %s
%s %s
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
replacedefaultroute
persist
lcp-echo-interval 3
lcp-echo-failure 12
	    /network/gprs/username    /dev/modem/baudrate    fname_chat_connect    fname_chat_disconnect r  #!/bin/sh -e
exec chat -v\
        ABORT BUSY\
        ABORT DELAYED\
        ABORT "NO ANSWER"\
        ABORT "NO DIALTONE"\
        ABORT VOICE\
        ABORT ERROR\
        ABORT RINGING\
        TIMEOUT 3\
        "" ATZ\
        OK-\\k\\k\\k\\d+++ATH-OK ATE1\
        TIMEOUT 30\
        OK AT+CGDCONT=1,\"IP\",\"%s\",,0,0\
        OK ATD%s\
        CONNECT \d\c
	    /network/gprs/apn    /network/gprs/number    os    execute 
   chmod +x  ñ   #!/bin/sh -e
/usr/sbin/chat -v\
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
	    fname_chap_secrets 
   %s "" %s
    /network/gprs/password     s                                                                                                         ³   ´   ´   ´   ´   µ   µ   µ   µ   ¶   ¶   ¶   ¶   ·   ¸         ¹   ¹   ½   ½   ½   ½   ¾   ¾   ¾   Ï   Ð   Ð   Ð   Ð   Ñ   Ñ   Ñ   Ñ   ¾   ¾   Ò   Ò   Ó   Ó   Ó   Ó   Ó   Ó   ×   ×   ×   ×   Ø   ç   Ø   è   è   é   é   é   é   é   é   í   í   í   í   î   î   î   î   ï   ï   ï   ï   ð   ð   ð   ð   î   î   ò   ò   ô         network     r      fd 	   r      fd    r      fd 9   r      fd S   r      fd b   r         open_or_die     ü      3   E   K@À Á  \WÀÀ @  Å@  AÁ  @   Æ B A ËBAÁ Ü@ËBA Ü@ËBAA Ü@ËBA Ü@ËBA Ü@ËÀCÜ@ Ä     Ü@ Ä     Ü@ @  Å@  A @ @ DÁ @	@E        config    get    /network/interface    off    logf    LG_INF    network !   Configuring network interface %q    fname_interfaces    w    write 8   # Auto-generated by validator application, do not edit
    
 	   auto lo
    iface lo inet loopback
    close    Not configuring network    evq    push    network_up    is_up     3   þ   þ   þ   þ                                                           	  	                                            network     2   
   interface    2      fd    '         open_or_die    configure_ethernet    configure_wifi                  @@ A   À@   W@A   @              io    input    /sys/class/net/eth0/carrier    read       ð?   1                                                 I   	@   E   @  Á  Á  \@ B   H   E  F@Á  \ KÀÁ Á  \@Â     @   ÅÀ   A @   @ CÁ Á  @DÀ  A Õ@  AÁ Õ@  E   ÁA   A  EA    Á  AÁ @¤     äA     A  AF A	 Ç        logf    LG_DMP    network    upping network    io    open    /proc/mounts    read    *a    match    root / nfs    LG_WRN 3   Root filesystem is on NFS, not configuring network    config    get    /network/interface "   ifdown -f wlan0; ifdown -f eth0;  	   ethernet    ifup -f eth0    ifup -f wlan0    LG_INF !   Bringing up network %s interface    Running %q    runbg    evq    push    network_down    is_up         :  @      W @ @E@    ÁÀ   \@ @ B  H                   logf    LG_WRN    network )   An error occured configuring the network        ;  ;  <  <  <  <  <  <  >  >  @        status     
         network_is_initialized     A  D   	   E   @  Á  Á  @  \@B  H           logf    LG_DMP    network 	   ifup> %s     	   B  B  B  B  B  B  C  C  D        data              network_is_initialized @   #  #  #  #  #  $  $  &  &  &  &  &  &  &  '  '  '  '  '  (  (  (  (  (  )  ,  ,  ,  ,  .  0  0  1  1  1  1  3  3  3  6  6  6  6  6  6  8  8  8  8  8  8  9  9  @  @  D  D  9  F  F  F  F  H  I        network     ?      mounts    ?   
   interface    ?      cmd    ?         network_is_initialized     L  O       E   F@À   \ À@   @        sys    get_macaddr    eth0    setraw        M  M  M  M  N  N  N  O        node           serial               R  ^           @@ A   C     À@  Ë@AA ÜÚ     @ ÁA A ^          io    popen    /sbin/ifconfig    read    *a    match    inet addr:(%S+)    close        S  S  S  S  T  U  U  V  V  V  W  W  W  X  X  Y  [  [  ]  ^        fd          ipaddr          tmp 
         tmp               a  h      D   \ Z   À  @   @  @ A  @        setraw    ?        b  b  c  c  d  d  d  d  f  f  f  h        node           ipaddr             get_current_ip_addr     n     D   A       Ä  Ú   Å@  ËÀAÁ  Ü Á@ W@A@ W Á       A Ä Ú    ÀAÅ@  ËÀAÁ  Ü Á Å  A A Á Ü@  Ä  WÀ ÀH  Å  Ë@ÃA  Ü@ Ä  Á@Å  Á A  Ü@ Å@ ËÄAÁ Ü@ Å  Á A  Ü@ Â  Þ          flash    config    get    /network/interface 	   ethernet    on     logf    LG_WRN    network    Network error: carrier lost    led    set    blue    LG_INF    Network is up    evq    push    network_up    Network is down     D   o  p  p  r  r  r  s  s  s  s  t  t  t  t  t  t  u  u  u  u  v  {  {  {  {  {  |  |  |  |  |  |  }  }  }  }  }                                                                      network     C      new_led_status    C      current_carrier_status    C   
   interface 
            get_carrier_status    network_is_initialized    get_current_ip_addr    carrier_status    led_status       ·    :   
@ 	@@	À@	@A	ÀA	@B	ÀB	@CD   	@ D  	@E  K@Ä Á \@d   À  EA A  À  @ À  EÁ A À  @ À  E AA  À  @ À  E AA  À  @   ÀF D @   @G @   @          fname_resolv_conf    /etc/resolv.conf    fname_interfaces    /etc/network/interfaces    fname_peer    /etc/ppp/peers/gprs    fname_chat_connect    /etc/ppp/gprs-connect-chat    fname_chat_disconnect    /etc/ppp/gprs-disconnect-chat    fname_chap_secrets    /etc/ppp/chap-secrets    is_up  
   configure    up    evq    signal_add    SIGCHLD    config 
   add_watch    /network/macaddress    get    /network/current_ip 	   /network    set    /dev/modem 	   register    check_network_status_timer    push       @       ¨  ¬          Á@  @ À @ ÀÀ @         print    Reconfiguring network 
   configure    up        ©  ©  ©  ª  ª  «  «  ¬        node           network            :                   ¢  ¢  £  £  ¦  ¦  ¦  ¦  ¬  ®  ®  ®  ®  ®  ®  ®  ¯  ¯  ¯  ¯  ¯  ¯  ¯  °  °  °  °  °  °  °  ±  ±  ±  ±  ±  ±  ±  ³  ³  ³  ³  ³  ´  ´  ´  ´  ´  ´  ¶  ·        network    9      reconfigure    9      
   configure    up    get_macaddress    get_current_ip    on_check_network_status_timer (                     :   :         ô   ô               I  I  O  ^  h  h  l  m              ·  ·  ·  ·  ·  ·    ·        open_or_die    '      configure_ethernet    '      configure_wifi 
   '      configure_gprs    '   
   configure    '      get_carrier_status    '      network_is_initialized    '      up    '      get_macaddress    '      get_current_ip_addr    '      get_current_ip    '      led_status    '      carrier_status    '      on_check_network_status_timer     '       