LuaQ     @network.lua           X      A@    À@@  A@   Â     C  ä      $B        d        ¤Â        ä               $C d ¤Ã   ä $D d       ¤Ä                    	ä    dE        
¤ äÅ                 
        	 d        GÆ dF G d   ¤Æ      	               	               F   
      module    Network    package    seeall    network    off       pÀ   gprs_is_available    wlan_is_available    new               
      @@À     À@     EÁ    Á    @A   A@AA              io    open    logf    LG_WRN    Could not open file '%s': %s 
   /dev/null                                                                                fname           mode           fd          err             lgid     "   C    
`   E   @  Ä     \@ D  À@ Á  \@Á  @À  BA BË@Á AÁ Ü@Ë@Á A Ü@@Ë@Á AA Ü@Ë@Á A Á BÂ Á UÁÜ@Ë@Á AA Á B Á UÁÜ@Ë@Á AÁ Á B Á UÁÜ@Ë@Á AA Ü@Ë@Á A Ü@ËÅ Ü@ ÀE@ÅÀ Ë ÂA ÜW@ÆÀÄ  F AÁ ÜAÁ ÅÁ ËÂAB Ü AAÁ ÅÁ ËÂA Ü AÅA         logf    LG_DBG     Configuring Ethernet connection    fname_interfaces    a    write    auto eth0
    config    get    /network/dhcp    true    iface eth0 inet dhcp
      vendor NQuire200
    iface eth0 inet static
      address     /network/ip/address    
      netmask     /network/ip/netmask      gateway     /network/ip/gateway 8     pre-up while killall udhcpc; do sleep .1; done; true
    close    false    /network/interface    gprs    fname_resolv_conf    w    nameserver     /network/ip/ns1    /network/ip/ns2     `   $   $   $   $   $   (   (   (   (   )   )   )   +   +   +   +   -   -   .   .   .   /   /   /   /   1   1   1   2   2   2   2   2   2   2   2   2   3   3   3   3   3   3   3   3   3   4   4   4   4   4   4   4   4   4   6   6   6   7   7   7   8   8   <   <   <   <   <   <   <   <   =   =   =   =   >   >   >   >   >   >   >   >   >   ?   ?   ?   ?   ?   ?   ?   ?   ?   @   @   C         network     _      fd 	   _      dhcp    _      fd K   _         lgid    open_or_die     J          E   @  Ä     \@ EÀ  K Á Á@ \À   A ÅÀ  Ë ÁAÁ ÜÁ  A D A Á \ÁÂ AÁÂB AÁÂAÁÂÂ A ÄÀ ÁÂB AÀÄ@ÁÂB AÁÂAÁÂ AÀ@Å@ÁÂ AÁÂAÁÂ AAÆA  ÆF Â  Ç À ËÁBAB ÜA@ËÁBA ÜAËÁBAÂ Â  A ÁB UÂÜAËÁBA Â  AÃ ÁB UÂÜAËÁBA	 Â  AC	 ÁB UÂÜAËÁBA	 ÜAËÁBAÂ	 ÜAËÁBA
 ÜAËÁBAB ÜAËAFÜA @Ê @ÅÁ  ËÁA
 ÜWÀÊÀÄ K A ÜÂÂB ÅÂ  ËÁA ÜC BÂÂB ÅÂ  ËÁAÃ ÜC BBÆB   0      logf    LG_DBG    Configuring wifi connection    config    get    /network/dhcp    /network/wifi/key    /network/wifi/keytype    /network/wifi/essid    /tmp/wpa_supplicant.conf    w    write    ctrl_interface=/tmp
    network={
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
      netmask     /network/ip/netmask      gateway     /network/ip/gateway G     pre-up while killall udhcpc wpa_supplicant; do sleep .1; done; true
 ?     pre-up wpa_supplicant -iwlan0 -c/tmp/wpa_supplicant.conf -B
 C     post-down while killall wpa_supplicant; do sleep .1; done; true
    false    /network/interface    gprs    fname_resolv_conf    nameserver     /network/ip/ns1    /network/ip/ns2        L   L   L   L   L   N   N   N   N   O   O   O   O   P   P   P   P   Q   Q   Q   Q   U   U   U   U   X   X   X   Y   Y   Y   Z   Z   Z   [   [   [   ]   ]   ^   ^   ^   ^   _   _   `   `   `   a   a   a   b   b   b   b   c   c   d   d   d   e   e   e   g   g   g   h   h   o   o   o   o   q   q   r   r   r   r   t   t   t   u   u   u   u   u   u   u   u   u   v   v   v   v   v   v   v   v   v   w   w   w   w   w   w   w   w   w   y   y   y   {   {   {   |   |   |   ~   ~   ~                                                                                                                  network           dhcp 	         key          keytype          essid          fd          fd H         fd             lgid    open_or_die        2       E   @  Ä     \@ D  À@ Á  \@Á  ÁAA  @  @Â @   Á Á Ë@AE FÁÁ \ Ü@  Ë@BÜ@ Ä  A AÁ ÜAÁ ÁAÁ  A  AÂA Á DAA A  FD Á EÁ KÅÁA \WÅ AAÂ @ A ÆAF Â ËAA@ ÅÂ ËÅAÃ ÜUÂÜAËABÜA AA ÂAA Â EC ÅÂ ËÅA ÜÃG FH  A  ABA  ÆÁG Â ËAAE FÂÁB ÅÂ ËÅA ÜÃ EÃ EÃ KÅÁ	 \\  ÜA  ËABÜA ÅÁ ÆÄB	 FÂG BÜA Ä H AÂ ÜBÁ	 BBÂB Â DAB	 H UB  FBF Â KBAÅ ÆÂÁÃ	 EÃ KÅÁC \Ã EÄ Ü  \B  KBB\B   (      logf    LG_DBG    Configuring GPRS connection    fname_interfaces    a    write    string    format    iface gprs inet ppp
  pre-up while killall udhcpc; do sleep .1; done; true
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
                                                            £   £   £   £   ¤   ¤   ¤   ¹   ¤   ¤   º   º   ½   ½   ½   ½   ¾   ¾   ¾   È   ¾   ¾   É   É   Ê   Ê   Ê   Ê   Î   Î   Î   Î   Ï   Ï   Ï   Ï   Ð   Ð   Ñ   Ñ   Ñ   Ñ   Ñ   Ñ   Ó   Ó   Ó   Ó   Ô   Ô   Ô   Ô   Ô   Ô   Ô   Ô   Ô   Õ   Õ   ×   ×   ×   ï   ð   ð   ð   ð   ñ   ñ   ñ   ñ   ò   ó   ×   ×   ô   ô   ø   ø   ø   ø   ù   ù   ù                             ù   ù                             %    &  &  '  '  '  '  '  '  +  +  +  +  ,  ,  ,  ,  -  -  -  -  .  .  .  .  ,  ,  0  0  2  
      network           fd 	         fd          fd !         fd 1      	   username 5         chapfd A   L      fd b         fd          fd             lgid    open_or_die     9  J   $   E   @  Ä     \@ D  À@ Á  \@Á  @@Á Á @@Á  @@Á A @@Á Á @Â @   À   @  À   @   À   @         logf    LG_INF    Configuring interfaces    fname_interfaces    w    write 8   # Auto-generated by validator application, do not edit
    
 	   auto lo
    iface lo inet loopback
    close     $   ;  ;  ;  ;  ;  >  >  >  >  ?  ?  ?  @  @  @  A  A  A  B  B  B  C  C  C  D  D  F  F  F  G  G  G  H  H  H  J        network     #      fd 	   #         lgid    open_or_die    configure_ethernet    configure_wifi    configure_gprs     N  [           @@ A  À     ÀK A Á@ \A @ ÀÁ      ÀW Â   @      @ C  ^    	      io    open    /sys/class/net/eth0/carrier    r    read       ð?   close     1        O  O  O  O  O  P  P  Q  Q  Q  R  R  S  S  T  T  T  V  V  V  V  V  W  Y  Y  [     
   fd_status          status 
              ^  a        
À  	@@	À@	 AE@ KÁ ÁÀ \F@  ^       	   ethernet    eth0    wifi    wlan0    gprs    config    get    /network/interface        _  _  _  _  `  `  `  `  `  `  a        convert_to_itf    
           c  g      E   F@À      \  @ A   Á  @        sys    get_macaddr    setraw            e  e  e  e  e  f  f  f  f  f  g        node     
      mac    
         get_current_itf     i  l    
   E   F@À   \ À@ A    @        sys    get_macaddr    eth0    setraw         
   j  j  j  j  k  k  k  k  k  l        node     	      mac    	           n  q    
   E   F@À   \ À@ A    @        sys    get_macaddr    wlan0    setraw         
   o  o  o  o  p  p  p  p  p  q        node     	      mac    	           t      	       E   F@À    \À    Å  Á  D  À    Ü@ ^          net    get_interface_ip    logf    LG_DBG    Interface %s: %s        v  v  x  x  x  x  z  z  {  {  {  {  {  {  {  ~          itf          ip          err             get_current_itf    lgid       á   	   A         À@  Å   AÁ  @       @AÁ @               À   @     À  BA B ÅÀ Ë ÃÜ Ú   @CÅÀ ËÃÜ Ú@  @Å@    D Á À Ü@Å  Ë@ÄÜ@   Ä Ü  ÁDA  À   A U@ A  EA  Á A Á C      AÁ U@Á C      A U@  AA U@FÀ ÁDA    AÁ U@BÀ   A U@ @CÀ   AA U@A  E   Á   A  ÁG    AH ÃÂ A	 ÉA	 IÁ	 Á
 A A  EA
  Á
   AA  EA  ÁÁ
   A    @ ¤            äA       A  -          logf    LG_WRN    Double upping network: delayed    os    execute #   killall udhcpc wpa_supplicant ifup    config    get    /network/interface    wifi    Network    wlan_is_available    gprs    gprs_is_available (   No hardware for network on interface %s    beeper    beep_error    opt    n    ifdown -f eth0;     LG_DBG %   opt -n found: not shutting down eth0    ifdown -f wlan0;     ifdown gprs;  	   sleep 1; 	   ethernet 
   ifup eth0    ifup wlan0    sleep 2; ifup gprs .   Unknown interface '%s'. Not starting network.    is_up    evq    push    network_down       ð¿    led    set    blue    flash    LG_INF !   Bringing up network %s interface    Running %q    runbg        Ë  Û   '   W @  @  Å    AÁ    @       @      Å@  A D   À Ü@Ä  Ú@   I ÂÅ@ ËÂAÁ Ü@            À  @                 logf    LG_WRN -   An error occured configuring the network: %d    ?.?.?.?    LG_INF $   Configured network successfully: %s    is_up    evq    push    network_up     '   Ì  Ì  Í  Í  Í  Í  Í  Í  Î  Î  Î  Ð  Ð  Ð  Ð  Ð  Ñ  Ñ  Ñ  Ñ  Ñ  Ñ  Ò  Ò  Ò  Ó  Ô  Ô  Ô  Ô  ×  ×  Ø  Ø  Ø  Ù  Ù  Ù  Û        status     &      network     &      ip             lgid    again    get_current_ip_addr    upping_network    up     Ü  Þ         Å@    A    @        logf    LG_DBG 	   ifup> %s        Ý  Ý  Ý  Ý  Ý  Ý  Þ        data           network              lgid                                                                                                                    ¡  ¡  ¡  ¡  ¢  ¢  ¢  ¢  ¤  ¤  ¤  ¤  ¤  ¦  ¦  ¦  ¦  ¦  §  §  §  ©  ©  ©  ©  ©  ª  ª  ª  ­  ­  ­  ¯  ¯  °  °  °  °  ±  ±  ±  ²  ³  ³  ´  ´  ´  ´  µ  µ  ¶  ¶  ¶  ¶  ¸  ¸  ¸  ¸  ¸  ¸  ¹  ¼  ¼  ¼  ¿  ¿  ¿  ¿  ¿  ¿  À  Â  Â  Â  Â  Â  Ä  Ä  Ä  Ä  Ä  Ä  È  È  È  È  È  È  É  É  Ê  Ê  Û  Û  Û  Û  Û  Û  Þ  Þ  ß  Ê  á        network           cmd       
   interface          current_ip 8            upping_network    lgid    again    config_is_changed 
   configure    get_current_ip_addr    up     ä  ë      D   \ Z   À  @   @  @ A  @        setraw    ?        å  å  æ  æ  ç  ç  ç  ç  é  é  é  ë        node           ipaddr             get_current_ip_addr     î  ü   	+   E   F@À   \ Z@  À  Å    AA @      ËÀÁ A ÜË@Â@   UÜ   ËÀÂ Ü@    Ä  WÀ ÀÅÀ   D  A À    Ü@   Å   Ý  Þ           io    open    /proc/net/wireless    logf    LG_WRN "   Could not open /proc/net/wireless 	   tonumber    read    *all    match    :%s+%d+%s+%d+.%s*(%-?%d+)    close    LG_DMP    %s signal strength=%d     +   ï  ï  ï  ï  ð  ð  ñ  ñ  ñ  ñ  ñ  ò  ò  ô  ô  ô  ô  ô  ô  ô  ô  ô  ô  õ  õ  ÷  ÷  ÷  ÷  ÷  ø  ø  ø  ø  ø  ø  ø  ù  û  û  û  û  ü        itf     *      fd    *      ss    *         lgid    prev_signalstrength     ÿ      	+   E   K@À Á  \ÀÀ @J     @AÁ      Ã ÁA À  Ú   ÂA Á  @WBBÂ A  @  C  I@@Ã@úCA ^  @ C  ^          config    get    /network/interface    wifi    io    popen    wpa_cli -p /tmp status    read    match 
   (.+)=(.*)    bssid    state    ip_address     close     +                                               	  	  	  
  
  
  
  
  
  
  
  
  
  
                            network     *      kv    '      f    '      l    &      key    "      value    "             \  	       Ä   Ü A  @Á  D \ Á   Z   @A@ A  WÀ ÀWA Ú   @Á Å  AB A  Á Å  AÂ A  Ã@  C
Á  Á    Á   ÀÁ À ÁD E@E  @  @DÁ Å  A A   @Á Å  AÂ Â AÁ   @ Á  WÁ  È W  AF DA @C@Á Å  AÂ A À A   Á Å  A A C@A G A   Á Å  AÂ A C@ A  ZA   A G   ÀÁ Å  A A  À A     !      flash    config    get    /network/interface    is_up 	   ethernet     logf    LG_INF    Carrier restored    LG_WRN ?   Network error: Carrier lost (network re-init or cable failure)    on    wifi    new_wlan_signal_strength    wlan0      àoÀ   network    get_wpa_status 
   wpa_state 
   COMPLETED    wifi signal recovered    wifi signal lost. (%d dB)    led    set    blue    Network is up    Network is down    Network    wlan_is_available    wifi is down unexpected.    Trying to re-init the network.                                          !  !  !  "  "  "  #  #  #  $  $  %  %  %  %  %  %  '  '  '  '  '  *  *  +  ,  -  -  .  .  .  .  /  /  /  /  /  /  0  0  0  1  1  1  1  1  1  2  4  4  4  5  5  5  5  5  6  8  8  8  9  9  9  9  :  9  =  =  =  >  >  C  C  D  G  G  G  H  I  I  I  I  I  J  J  J  K  K  K  K  K  K  L  L  L  M  M  M  M  M  N  N  N  N  N  N  N  O  O  O  O  O  U  U  U  U  U  V  V  V  V  V  V  V  W  W  W  W  W  X  X  X  [  [  \        event           nw           new_led_status          current_carrier_status       
   interface          current_ip_addr 	      	      get_carrier_status    get_current_ip_addr    upping_network    carrier_status    lgid    get_wlan_signal_strength    wlan_signal_strength    led_status    up     i      i       @       @  @  @  ÀÀ   A @ E FÀÁ    Á  \Z    @BÀ  @  ÀAÀ    @   ÀBÀ   EÁ  KÁÁA \  @   CÀ  @  ÀCÀ   @ @DÀ   AÁ  Å  A D  ÛA   ÁÁ Ü@   @Ë FAA ÜÚ      Â   @ Â@  Â  È   Ä   Ú   @Å   D Á Ü@  Å  A D  Ü@ Å Æ@Â  Ü@ @  Å@  A   @              Scanner_1d    is_available    config    get    /dev/modem/device    sys    open    r    close    rw    set_baudrate 	   tonumber    /dev/modem/baudrate    tcflush    write    AT 	   readport       4@     @@   logf    LG_DBG    gprs_is_available() data='%s'    <nil>    find    OK    LG_INF    GPRS hardware detected.    No GPRS hardware detected.    LG_WRN =   GPRS modem device '%s' not found (should probably be ttyS1).     i   j  j  j  k  k  l  l  l  l  l  m  m  m  m  n  n  n  n  n  o  o  p  p  p  p  q  q  q  q  q  q  r  r  r  r  r  r  r  r  r  r  s  s  s  s  t  t  t  t  t  u  u  u  u  u  u  v  v  v  v  v  v  v  v  w  w  w  w  w  w  w  w  w  w  w  w  w  x  x  x  y  y  y  y  y  y  {  {  {  {  {  }  }  }  }  }                          dev    f      fd    f      data 8   _         has_gprs_hw    lgid                  @@ A  À      K A \@ B  ^  @ B   ^          io    open    /sys/class/net/wlan0    r    close                                            fd                       E   K@À Á    @  \@E   KÀÀ Á  \@        evq    unregister    check_network_status_timer    signal_del    SIGCHLD                                    self     
         on_check_network_status_timer       Ï    T   
À 	@@	À@	@A	ÀA	@B	ÀB	@CD   	@ D  	@D  	@ D 	@E KÀÄ Á  \@E@ KÅ ÁÀ  D   \@ E@ KÅ Á@  D  \@ E@ KÅ Á  D   \@ E@ KÅ ÁÀ  D  \@ D \ H  d      @ E AA  À  @ @ E AA  À  @  ÀG D   @ @H C @C @     #      fname_resolv_conf    /etc/resolv.conf    fname_interfaces    /etc/network/interfaces    fname_peer    /etc/ppp/peers/gprs    fname_chat_connect    /etc/ppp/gprs-connect-chat    fname_chat_disconnect    /etc/ppp/gprs-disconnect-chat    fname_chap_secrets    /etc/ppp/chap-secrets    is_up  
   configure    up    get_wpa_status 	   shutdown    evq    signal_add    SIGCHLD    config 
   add_watch    /network/macaddress    get    /network/macaddress_eth0    /network/macaddress_wlan0    /network/current_ip 	   /network    set    /dev/modem 	   register    check_network_status_timer    push       @       º  Â         Å@    A  Á@  @        @A CÁ @ Â @   	      logf    LG_DBG    Reconfigure because of node %s    full_id    evq    push    network_reconfigure       ð¿   up        »  »  »  »  »  »  »  ¿  ¿  À  À  À  À  À  À  Á  Á  Â        node           nw              lgid    config_is_changed T     ¢  £  ¤  ¥  ¦  §  ¨  «  «  ¬  ¬  ­  ­  ®  ®  ±  ±  ±  ±  ³  ³  ³  ³  ³  ³  ³  ´  ´  ´  ´  ´  ´  ´  µ  µ  µ  µ  µ  µ  µ  ¶  ¶  ¶  ¶  ¶  ¶  ¶  ¸  ¸  ¸  Â  Â  Â  Ä  Ä  Ä  Ä  Ä  Ä  Ä  Å  Å  Å  Å  Å  Å  Å  É  É  É  É  É  É  Ê  Ê  Ê  Ê  Ê  Ê  Ì  Ì  Î  Ï        netwrk    S      reconfigure 6   S      
   configure    up    get_wpa_status 	   shutdown    get_used_macaddress    get_macaddress_eth0    get_macaddress_wlan0    get_current_ip    carrier_status    get_carrier_status    lgid    config_is_changed    on_check_network_status_timer X                     	   
                     C   C   C            2  2  2  J  J  J  J  J  J  [  a  g  g  l  q        á  á  á  á  á  á  á  á  ë  ë  í  ü  ü  ü    \  \  \  \  \  \  \  \  \  \  h        i          Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï    Ï        lgid    W      led_status    W      carrier_status    W      upping_network 	   W      again 
   W      wlan_signal_strength    W      config_is_changed    W      open_or_die    W      configure_ethernet    W      configure_wifi    W      configure_gprs    W   
   configure    W      get_carrier_status    W      get_current_itf    W      get_used_macaddress !   W      get_macaddress_eth0 "   W      get_macaddress_wlan0 #   W      get_current_ip_addr &   W      up .   W      get_current_ip 0   W      prev_signalstrength 1   W      get_wlan_signal_strength 4   W      get_wpa_status 5   W      on_check_network_status_timer ?   W      has_gprs_hw @   W   	   shutdown H   W       