LuaQ     @network.lua           L      A@    À@@  A@   Â     C  ä      $B        d        ¤Â        ä               $C d ¤Ã     ä                    $D    A ¤       äÄ $                   	     C
¤E   
    Å ¤  ¤Å       	                 
E   
      module    Network    package    seeall    network    off       pÀ   gprs_is_available    wlan_is_available    new               
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
    close     $   ;  ;  ;  ;  ;  >  >  >  >  ?  ?  ?  @  @  @  A  A  A  B  B  B  C  C  C  D  D  F  F  F  G  G  G  H  H  H  J        network     #      fd 	   #         lgid    open_or_die    configure_ethernet    configure_wifi    configure_gprs     N  [           @@ A      ÀKÀ@ Á  \@A @ Á      ÀWÀÁ   @      @ C  ^          io    input    /sys/class/net/eth0/carrier    read       ð?   close     1        O  O  O  O  P  P  Q  Q  Q  R  R  S  S  T  T  T  V  V  V  V  V  W  Y  Y  [     
   fd_status          status 	              ^  a       E   F@À   \ À@   @        sys    get_macaddr    eth0    setraw        _  _  _  _  `  `  `  a        node           serial               d  q    
   
À  	@@	À@	 AE@ KÁ ÁÀ \F@    @BÀ  À Ú    EÁ   Á   @A        	   ethernet    eth0    wifi    wlan0    gprs    config    get    /network/interface    net    get_interface_ip    logf    LG_DBG    Interface %s: %s        f  f  f  f  g  g  g  g  g  i  i  i  i  k  k  l  l  l  l  l  l  l  o  q        convert_to_itf          itf 	         ip          err             lgid     w  Ò   	   A         À@  Å   AÁ  @       @AÁ @               À   @     À  BA B ÅÀ Ë ÃÜ Ú   @CÅÀ ËÃÜ Ú@  @Å@    D Á À Ü@Å  Ë@ÄÜ@   Ä Ü  ÁDA  À   A U@ A  EA  Á A Á C      AÁ U@Á C      A U@  AA U@FÀ ÁDA    AÁ U@BÀ   A U@ @CÀ   AA U@A  E   Á   A  ÁG    AH ÃÂ A	 ÉA	 IÁ	 Á
 A A  EA
  Á
   AA  EA  ÁÁ
   A    @ ¤            äA       A  -          logf    LG_WRN    Double upping network: delayed    os    execute #   killall udhcpc wpa_supplicant ifup    config    get    /network/interface    wifi    Network    wlan_is_available    gprs    gprs_is_available (   No hardware for network on interface %s    beeper    beep_error    opt    n    ifdown -f eth0;     LG_DBG %   opt -n found: not shutting down eth0    ifdown -f wlan0;     ifdown gprs;  	   sleep 1; 	   ethernet 
   ifup eth0    ifup wlan0    sleep 2; ifup gprs .   Unknown interface '%s'. Not starting network.    is_up    evq    push    network_down       ð¿    led    set    blue    flash    LG_INF !   Bringing up network %s interface    Running %q    runbg        ¼  Ì   '   W @  @  Å    AÁ    @       @      Å@  A D   À Ü@Ä  Ú@   I ÂÅ@ ËÂAÁ Ü@            À  @                 logf    LG_WRN -   An error occured configuring the network: %d    ?.?.?.?    LG_INF $   Configured network successfully: %s    is_up    evq    push    network_up     '   ½  ½  ¾  ¾  ¾  ¾  ¾  ¾  ¿  ¿  ¿  Á  Á  Á  Á  Á  Â  Â  Â  Â  Â  Â  Ã  Ã  Ã  Ä  Å  Å  Å  Å  È  È  É  É  É  Ê  Ê  Ê  Ì        status     &      network     &      ip             lgid    again    get_current_ip_addr    upping_network    up     Í  Ï         Å@    A    @        logf    LG_DBG 	   ifup> %s        Î  Î  Î  Î  Î  Î  Ï        data           network              lgid    y  {  {  {  |  |  |  |  |  }  }  ~  ~  ~  ~                                                                                                                                                          ¡  ¡  ¡  ¡  ¢  ¢  ¢  £  ¤  ¤  ¥  ¥  ¥  ¥  ¦  ¦  §  §  §  §  ©  ©  ©  ©  ©  ©  ª  ­  ­  ­  °  °  °  °  °  °  ±  ³  ³  ³  ³  ³  µ  µ  µ  µ  µ  µ  ¹  ¹  ¹  ¹  ¹  ¹  º  º  »  »  Ì  Ì  Ì  Ì  Ì  Ì  Ï  Ï  Ð  »  Ò        network           cmd       
   interface          current_ip 8            upping_network    lgid    again    config_is_changed 
   configure    get_current_ip_addr    up     Õ  Ü      D   \ Z   À  @   @  @ A  @        setraw    ?        Ö  Ö  ×  ×  Ø  Ø  Ø  Ø  Ú  Ú  Ú  Ü        node           ipaddr             get_current_ip_addr     ß  í   	+   E   F@À   \ Z@  À  Å    AA @      ËÀÁ A ÜË@Â@   UÜ   ËÀÂ Ü@    Ä  WÀ ÀÅÀ   D  A À    Ü@   Å   Ý  Þ           io    open    /proc/net/wireless    logf    LG_WRN "   Could not open /proc/net/wireless 	   tonumber    read    *all    match    :%s+%d+%s+%d+.%s*(%-?%d+)    close    LG_DMP    %s signal strength=%d     +   à  à  à  à  á  á  â  â  â  â  â  ã  ã  å  å  å  å  å  å  å  å  å  å  æ  æ  è  è  è  è  è  é  é  é  é  é  é  é  ê  ì  ì  ì  ì  í        itf     *      fd    *      ss    *         lgid    prev_signalstrength     ð      	+   E   K@À Á  \ÀÀ @J     @AÁ      Ã ÁA À  Ú   ÂA Á  @WBBÂ A  @  C  I@@Ã@úCA ^  @ C  ^          config    get    /network/interface    wifi    io    popen    wpa_cli -p /tmp status    read    match 
   (.+)=(.*)    bssid    state    ip_address     close     +   ñ  ñ  ñ  ñ  ñ  ñ  ò  ô  ô  ô  ô  õ  õ  ö  ø  ø  ø  ù  ù  ú  ú  ú  û  û  û  û  û  û  û  û  û  û  û  ü  ÿ  ÿ                        network     *      kv    '      f    '      l    &      key    "      value    "           
  L         Ä   Ü A  @Á  D \ Á   Z   @A@ A  WÀ ÀWA Ú   @Á Å  AB A  Á Å  AÂ A  Ã@  C
Á  Á    Á   ÀÁ À ÁD E@E  @  @DÁ Å  A A   @Á Å  AÂ Â AÁ   @ Á  WÁ  È W  AF DA @C@Á Å  AÂ A À A   Á Å  A A C@A G A   Á Å  AÂ A            flash    config    get    /network/interface    is_up 	   ethernet     logf    LG_INF    Carrier restored    LG_WRN ?   Network error: Carrier lost (network re-init or cable failure)    on    wifi    new_wlan_signal_strength    wlan0      àoÀ   network    get_wpa_status 
   wpa_state 
   COMPLETED    wifi signal recovered    wifi signal lost. (%d dB)    led    set    blue    Network is up    Network is down    Network    wlan_is_available    wifi is down unexpected.                                                                                                                          !  !  !  "  "  "  "  "  "  #  %  %  %  &  &  &  &  &  '  )  )  )  *  *  *  *  +  *  .  .  .  /  /  4  4  5  8  8  8  9  :  :  :  :  :  ;  ;  ;  <  <  <  <  <  <  =  =  =  >  >  >  >  >  ?  ?  ?  ?  ?  ?  ?  @  @  @  @  @  K  K  L        event           nw           new_led_status          current_carrier_status       
   interface          current_ip_addr 	            get_carrier_status    get_current_ip_addr    upping_network    carrier_status    lgid    get_wlan_signal_strength    wlan_signal_strength    led_status     Y  t    i       @       @  @  @  ÀÀ   A @ E FÀÁ    Á  \Z    @BÀ  @  ÀAÀ    @   ÀBÀ   EÁ  KÁÁA \  @   CÀ  @  ÀCÀ   @ @DÀ   AÁ  Å  A D  ÛA   ÁÁ Ü@   @Ë FAA ÜÚ      Â   @ Â@  Â  È   Ä   Ú   @Å   D Á Ü@  Å  A D  Ü@ Å Æ@Â  Ü@ @  Å@  A   @              Scanner_1d    is_available    config    get    /dev/modem/device    sys    open    r    close    rw    set_baudrate 	   tonumber    /dev/modem/baudrate    tcflush    write    AT 	   readport       4@     @@   logf    LG_DBG    gprs_is_available() data='%s'    <nil>    find    OK    LG_INF    GPRS hardware detected.    No GPRS hardware detected.    LG_WRN =   GPRS modem device '%s' not found (should probably be ttyS1).     i   Z  Z  Z  [  [  \  \  \  \  \  ]  ]  ]  ]  ^  ^  ^  ^  ^  _  _  `  `  `  `  a  a  a  a  a  a  b  b  b  b  b  b  b  b  b  b  c  c  c  c  d  d  d  d  d  e  e  e  e  e  e  f  f  f  f  f  f  f  f  g  g  g  g  g  g  g  g  g  g  g  g  g  h  h  h  i  i  i  i  i  i  k  k  k  k  k  m  m  m  m  m  o  o  o  o  o  o  s  s  t        dev    f      fd    f      data 8   _         has_gprs_hw    lgid     w             @@ A  À      K A \@ B  ^  @ B   ^          io    open    /sys/class/net/wlan0    r    close        y  y  y  y  y  z  z  {  {  |  |  |  ~  ~          fd                 ¶  	  C   
 	@@	À@	@A	ÀA	@B	ÀB	@CD   	@ D  	@D  	@ E@ KÄ ÁÀ \@E  K@Å Á Á D  \@ E  K@Å Á  Á D   \@ D  \ H d      @EA A  À  @   @EÁ A  À  @ @  GA D   @@ GA CÁ @C @            fname_resolv_conf    /etc/resolv.conf    fname_interfaces    /etc/network/interfaces    fname_peer    /etc/ppp/peers/gprs    fname_chat_connect    /etc/ppp/gprs-connect-chat    fname_chat_disconnect    /etc/ppp/gprs-disconnect-chat    fname_chap_secrets    /etc/ppp/chap-secrets    is_up  
   configure    up    get_wpa_status    evq    signal_add    SIGCHLD    config 
   add_watch    /network/macaddress    get    /network/current_ip 	   /network    set    /dev/modem 	   register    check_network_status_timer    push       @       ¢  ©              @@  CÁ  @ Á @         evq    push    network_reconfigure       ð¿   up        ¦  ¦  §  §  §  §  §  §  ¨  ¨  ©        node     
      nw     
         config_is_changed C                                                                            ©  ©  «  «  «  «  «  «  «  ¬  ¬  ¬  ¬  ¬  ¬  ¬  °  °  °  °  °  °  ±  ±  ±  ±  ±  ±  ³  ³  µ  ¶        netwrk    B      reconfigure %   B   	   
   configure    up    get_wpa_status    get_macaddress    get_current_ip    carrier_status    get_carrier_status    config_is_changed    on_check_network_status_timer L                     	   
                     C   C   C            2  2  2  J  J  J  J  J  J  [  a  q  q  Ò  Ò  Ò  Ò  Ò  Ò  Ò  Ò  Ü  Ü  Þ  í  í  í    L  L  L  L  L  L  L  L  L  X  t  t  t  Y    w  ¶  ¶  ¶  ¶  ¶  ¶  ¶  ¶  ¶  ¶    ¶        lgid    K      led_status    K      carrier_status    K      upping_network 	   K      again 
   K      wlan_signal_strength    K      config_is_changed    K      open_or_die    K      configure_ethernet    K      configure_wifi    K      configure_gprs    K   
   configure    K      get_carrier_status    K      get_macaddress    K      get_current_ip_addr !   K      up )   K      get_current_ip +   K      prev_signalstrength ,   K      get_wlan_signal_strength /   K      get_wpa_status 0   K      on_check_network_status_timer 9   K      has_gprs_hw :   K       