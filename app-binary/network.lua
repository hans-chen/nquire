LuaQ     @network.lua           M      A@    À@@  A@   Â     C  ä      $B        d        ¤Â        ä               $C d ¤Ã     ä                    $D    A ¤       äÄ                   	       $ C
¤E   
    Å ¤  ¤Å                      
  	E   
      module    Network    package    seeall    network    off       pÀ   gprs_is_available    wlan_is_available    new               
      @@À     À@     EÁ    Á    @A   A@AA              io    open    logf    LG_WRN    Could not open file '%s': %s 
   /dev/null                                                                                fname           mode           fd          err             lgid     "   C    
`   E   @  Ä     \@ D  À@ Á  \@Á  @À  BA BË@Á AÁ Ü@Ë@Á A Ü@@Ë@Á AA Ü@Ë@Á A Á BÂ Á UÁÜ@Ë@Á AA Á B Á UÁÜ@Ë@Á AÁ Á B Á UÁÜ@Ë@Á AA Ü@Ë@Á A Ü@ËÅ Ü@ ÀE@ÅÀ Ë ÂA ÜW@ÆÀÄ  F AÁ ÜAÁ ÅÁ ËÂAB Ü AAÁ ÅÁ ËÂA Ü AÅA         logf    LG_DBG     Configuring Ethernet connection    fname_interfaces    a    write    auto eth0
    config    get    /network/dhcp    true    iface eth0 inet dhcp
      vendor NQuire200
    iface eth0 inet static
      address     /network/ip/address    
      netmask     /network/ip/netmask      gateway     /network/ip/gateway 8     pre-up while killall udhcpc; do sleep .1; done; true
    close    false    /network/interface    gprs    fname_resolv_conf    w    nameserver     /network/ip/ns1    /network/ip/ns2     `   $   $   $   $   $   (   (   (   (   )   )   )   +   +   +   +   -   -   .   .   .   /   /   /   /   1   1   1   2   2   2   2   2   2   2   2   2   3   3   3   3   3   3   3   3   3   4   4   4   4   4   4   4   4   4   6   6   6   7   7   7   8   8   <   <   <   <   <   <   <   <   =   =   =   =   >   >   >   >   >   >   >   >   >   ?   ?   ?   ?   ?   ?   ?   ?   ?   @   @   C         network     _      fd 	   _      dhcp    _      fd K   _         lgid    open_or_die     J          E   @  Ä     \@ EÀ  K Á Á@ \À   A ÅÀ  Ë ÁAÁ ÜÁ  A D A Á \ÁÂ AÁÂAÁÂ AÀÃÀ ÁÂ AÀ@Ä@ÁÂ AÁÂ AÁÂÂ AÀ Å@ÁÂB AÁÂ AÁÂÂ AÆA  ÆAF  ÀÆ À ËÁBA ÜA@ËÁBAB ÜAËÁBA Â  AÃ Á UÂÜAËÁBAB Â  A Á UÂÜAËÁBAÂ Â  A	 Á UÂÜAËÁBAB	 ÜAËÁBA	 ÜAËÁBAÂ	 ÜAËÁBA ÜAËFÜA  Ê @ÅÁ  ËÁAB
 ÜWÊÀÄ ÂJ A ÜÂÂ ÅÂ  ËÁAC Ü BÂÂ ÅÂ  ËÁA Ü BÆB   /      logf    LG_DBG    Configuring wifi connection    config    get    /network/dhcp    /network/wifi/key    /network/wifi/keytype    /network/wifi/essid    /tmp/wpa_supplicant.conf    w    write    network={
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
 ?     pre-up wpa_supplicant -B -iwlan0 -c/tmp/wpa_supplicant.conf
 C     post-down while killall wpa_supplicant; do sleep .1; done; true
    false    /network/interface    gprs    fname_resolv_conf    nameserver     /network/ip/ns1    /network/ip/ns2        L   L   L   L   L   N   N   N   N   O   O   O   O   P   P   P   P   Q   Q   Q   Q   U   U   U   U   W   W   W   X   X   X   Y   Y   Y   [   [   \   \   \   \   ]   ]   ^   ^   ^   _   _   _   `   `   `   `   a   a   b   b   b   c   c   c   e   e   e   f   f   m   m   m   m   o   o   p   p   p   p   r   r   r   s   s   s   s   s   s   s   s   s   t   t   t   t   t   t   t   t   t   u   u   u   u   u   u   u   u   u   w   w   w   x   x   x   y   y   y   {   {   {   |   |                                                                                                            network           dhcp 	         key          keytype          essid          fd          fd E         fd             lgid    open_or_die        /       E   @  Ä     \@ D  À@ Á  \@Á  ÁAA  @  @Â @   Á Á Ë@AE FÁÁ \ Ü@  Ë@BÜ@ Ä  A AÁ ÜAÁ ÁAÁ  A  AÂA Á DAA A  FD Á EÁ KÅÁA \WÅ AAÂ @ A ÆAF Â ËAA@ ÅÂ ËÅAÃ ÜUÂÜAËABÜA AA ÂAA Â EC ÅÂ ËÅA ÜÃG FH  A  ABA  ÆÁG Â ËAAE FÂÁB ÅÂ ËÅA ÜÃ EÃ EÃ KÅÁ	 \\  ÜA  ËABÜA ÅÁ ÆÄB	 FÂG BÜA Ä H AÂ ÜBÁ	 BBÂB Â DAB	 H UB  FBF Â KBAÅ ÆÂÁÃ	 EÃ KÅÁC \Ã EÄ Ü  \B  KBB\B   (      logf    LG_DBG    Configuring GPRS connection    fname_interfaces    a    write    string    format    iface gprs inet ppp
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
                                                                            ¡   ¡   ¡   ¶   ¡   ¡   ·   ·   º   º   º   º   »   »   »   Å   »   »   Æ   Æ   Ç   Ç   Ç   Ç   Ë   Ë   Ë   Ë   Ì   Ì   Ì   Ì   Í   Í   Î   Î   Î   Î   Î   Î   Ð   Ð   Ð   Ð   Ñ   Ñ   Ñ   Ñ   Ñ   Ñ   Ñ   Ñ   Ñ   Ò   Ò   Ô   Ô   Ô   ì   í   í   í   í   î   î   î   î   ï   ð   Ô   Ô   ñ   ñ   õ   õ   õ   õ   ö   ö   ö   	  
  
  
  
                  ö   ö                             "    #  #  $  $  $  $  $  $  (  (  (  (  )  )  )  )  *  *  *  *  +  +  +  +  )  )  -  -  /  
      network           fd 	         fd          fd !         fd 1      	   username 5         chapfd A   L      fd b         fd          fd             lgid    open_or_die     6  G   $   E   @  Ä     \@ D  À@ Á  \@Á  @@Á Á @@Á  @@Á A @@Á Á @Â @   À   @  À   @   À   @         logf    LG_INF    Configuring interfaces    fname_interfaces    w    write 8   # Auto-generated by validator application, do not edit
    
 	   auto lo
    iface lo inet loopback
    close     $   8  8  8  8  8  ;  ;  ;  ;  <  <  <  =  =  =  >  >  >  ?  ?  ?  @  @  @  A  A  C  C  C  D  D  D  E  E  E  G        network     #      fd 	   #         lgid    open_or_die    configure_ethernet    configure_wifi    configure_gprs     K  X           @@ A      ÀKÀ@ Á  \@A @ Á      ÀWÀÁ   @      @ C  ^          io    input    /sys/class/net/eth0/carrier    read       ð?   close     1        L  L  L  L  M  M  N  N  N  O  O  P  P  Q  Q  Q  S  S  S  S  S  T  V  V  X     
   fd_status          status 	              [  ^       E   F@À   \ À@   @        sys    get_macaddr    eth0    setraw        \  \  \  \  ]  ]  ]  ^        node           serial               a  n    
   
À  	@@	À@	 AE@ KÁ ÁÀ \F@    @BÀ  À Ú    EÁ   Á   @A        	   ethernet    eth0    wifi    wlan0    gprs    config    get    /network/interface    net    get_interface_ip    logf    LG_DMP    Interface %s: %s        c  c  c  c  d  d  d  d  d  f  f  f  f  h  h  i  i  i  i  i  i  i  l  n        convert_to_itf          itf 	         ip          err             lgid     t  Ï   	   A         À@  Å   AÁ  @       @AÁ @               À   @     À  BA B ÅÀ Ë ÃÜ Ú   @CÅÀ ËÃÜ Ú@  @Å@    D Á À Ü@Å  Ë@ÄÜ@   Ä Ü  ÁDA  À   A U@ A  EA  Á A Á C      AÁ U@Á C      A U@  AA U@FÀ ÁDA    AÁ U@BÀ   A U@ @CÀ   AA U@A  E   Á   A  ÁG    AH ÃÂ A	 ÉA	 IÁ	 Á
 A A  EA
  Á
   AA  EÁ
  Á   A   A @ ¤            äA       A  .          logf    LG_WRN    Double upping network: delayed    os    execute #   killall udhcpc wpa_supplicant ifup    config    get    /network/interface    wifi    Network    wlan_is_available    gprs    gprs_is_available (   No hardware for network on interface %s    beeper    beep_error    opt    n    ifdown -f eth0;     LG_DBG %   opt -n found: not shutting down eth0    ifdown -f wlan0;     ifdown gprs;  	   sleep 1; 	   ethernet 
   ifup eth0    ifup wlan0    sleep 2; ifup gprs .   Unknown interface '%s'. Not starting network.    is_up    evq    push    network_down       ð¿    led    set    blue    flash    LG_INF !   Bringing up network %s interface    LG_DMP    Running %q    runbg        ¹  É   '   W @  @  Å    AÁ    @       @      Å@  A D   À Ü@Ä  Ú@   I ÂÅ@ ËÂAÁ Ü@            À  @                 logf    LG_WRN -   An error occured configuring the network: %d    ?.?.?.?    LG_INF $   Configured network successfully: %s    is_up    evq    push    network_up     '   º  º  »  »  »  »  »  »  ¼  ¼  ¼  ¾  ¾  ¾  ¾  ¾  ¿  ¿  ¿  ¿  ¿  ¿  À  À  À  Á  Â  Â  Â  Â  Å  Å  Æ  Æ  Æ  Ç  Ç  Ç  É        status     &      network     &      ip             lgid    again    get_current_ip_addr    upping_network    up     Ê  Ì         Å@    A    @        logf    LG_DMP 	   ifup> %s        Ë  Ë  Ë  Ë  Ë  Ë  Ì        data           network              lgid    v  x  x  x  y  y  y  y  y  z  z  {  {  {  {  |  ~  ~                                                                                                                                                                   ¡  ¡  ¢  ¢  ¢  ¢  £  £  ¤  ¤  ¤  ¤  ¦  ¦  ¦  ¦  ¦  ¦  §  ª  ª  ª  ­  ­  ­  ­  ­  ­  ®  °  °  °  °  °  ²  ²  ²  ²  ²  ²  ¶  ¶  ¶  ¶  ¶  ¶  ·  ·  ¸  ¸  É  É  É  É  É  É  Ì  Ì  Í  ¸  Ï        network           cmd       
   interface          current_ip 8            upping_network    lgid    again    config_is_changed 
   configure    get_current_ip_addr    up     Ò  Ù      D   \ Z   À  @   @  @ A  @        setraw    ?        Ó  Ó  Ô  Ô  Õ  Õ  Õ  Õ  ×  ×  ×  Ù        node           ipaddr             get_current_ip_addr     Ü  ê   	+   E   F@À   \ Z@  À  Å    AA @      ËÀÁ A ÜË@Â@   UÜ   ËÀÂ Ü@    Ä  WÀ ÀÅÀ   D  A À    Ü@   Å   Ý  Þ           io    open    /proc/net/wireless    logf    LG_WRN "   Could not open /proc/net/wireless 	   tonumber    read    *all    match    :%s+%d+%s+%d+.%s*(%-?%d+)    close    LG_DMP    %s signal strength=%d     +   Ý  Ý  Ý  Ý  Þ  Þ  ß  ß  ß  ß  ß  à  à  â  â  â  â  â  â  â  â  â  â  ã  ã  å  å  å  å  å  æ  æ  æ  æ  æ  æ  æ  ç  é  é  é  é  ê        itf     *      fd    *      ss    *         lgid    prev_signalstrength     ì  +  	       Ä   Ü A  @Á  D \ Á    Z  @A@ A  WÀ ÀWA Ú   @Á Å  AB A  Á Å  AÂ A  Ã 
@ 	C 	Á  Á     Á   @Á @@  @DÁ Å  A A   @Á Å  AÂ Â AÁ   @ Á  WÁ  È W  AE DA @C@Á Å  AÂ A À A   Á Å  A A C@A F A   Á Å  AÂ A C@ A  ZA   A F   ÀÁ Å  A A  À A           flash    config    get    /network/interface    is_up 	   ethernet     logf    LG_INF    Carrier restored    LG_WRN ?   Network error: Carrier lost (network re-init or cable failure)    on    wifi    new_wlan_signal_strength    wlan0      àoÀ   wifi signal recovered    wifi signal lost. (%d dB)    led    set    blue    Network is up    Network is down    Network    wlan_is_available    wifi is down unexpected.    Trying to re-init the network.        í  î  î  ï  ï  ï  ï  ð  ð  ò  ò  ò  ò  ò  ó  ó  ô  ô  ô  õ  õ  õ  ö  ö  ö  ÷  ÷  ø  ø  ø  ø  ø  ø  ú  ú  ú  ú  ú  ý  ý  þ  ÿ                                                            	  	  	  	  
  	                                                                                              $  $  $  $  $  %  %  %  %  %  %  %  &  &  &  &  &  '  '  '  *  *  +        event           nw           new_led_status          current_carrier_status       
   interface          current_ip_addr 	      	      get_carrier_status    get_current_ip_addr    upping_network    carrier_status    lgid    get_wlan_signal_strength    wlan_signal_strength    led_status    up     .  4          @@  À@   @AÁ @ À   @AÁÀ @         config    get    /network/interface    wifi    os    execute     /cit200/reload_wlan_driver.sh & 7   while killall reload_wlan_driver.sh; do sleep .1; done        /  /  /  /  /  /  0  0  0  0  0  2  2  2  2  4        node           nw                8  S    i       @       @  @  @  ÀÀ   A @ E FÀÁ    Á  \Z    @BÀ  @  ÀAÀ    @   ÀBÀ   EÁ  KÁÁA \  @   CÀ  @  ÀCÀ   @ @DÀ   AÁ  Å  A D  ÛA   ÁÁ Ü@   @Ë FAA ÜÚ      Â   @ Â@  Â  È   Ä   Ú   @Å   D Á Ü@  Å  A D  Ü@ Å Æ@Â  Ü@ @  Å@  A   @              Scanner_1d    is_available    config    get    /dev/modem/device    sys    open    r    close    rw    set_baudrate 	   tonumber    /dev/modem/baudrate    tcflush    write    AT 	   readport       4@     @@   logf    LG_DBG    gprs_is_available() data='%s'    <nil>    find    OK    LG_INF    GPRS hardware detected.    No GPRS hardware detected.    LG_WRN =   GPRS modem device '%s' not found (should probably be ttyS1).     i   9  9  9  :  :  ;  ;  ;  ;  ;  <  <  <  <  =  =  =  =  =  >  >  ?  ?  ?  ?  @  @  @  @  @  @  A  A  A  A  A  A  A  A  A  A  B  B  B  B  C  C  C  C  C  D  D  D  D  D  D  E  E  E  E  E  E  E  E  F  F  F  F  F  F  F  F  F  F  F  F  F  G  G  G  H  H  H  H  H  H  J  J  J  J  J  L  L  L  L  L  N  N  N  N  N  N  R  R  S        dev    f      fd    f      data 8   _         has_gprs_hw    lgid     V  `           @@ A  À      K A \@ B  ^  @ B   ^          io    open    /sys/class/net/wlan0    r    close        X  X  X  X  X  Y  Y  Z  Z  [  [  [  ]  ]  `        fd               g    	  L   
@ 	@@	À@	@A	ÀA	@B	ÀB	@CD   	@ D  	@E  K@Ä Á \@EÀ K Å Á@  D   \@ EÀ K Å ÁÀ  D  \@ D \ H  d     À  E AA  À  @ À  E AA  À  @ À  EÁ AA À  @  Ã    @   GA D   @  GA CÁ @C @            fname_resolv_conf    /etc/resolv.conf    fname_interfaces    /etc/network/interfaces    fname_peer    /etc/ppp/peers/gprs    fname_chat_connect    /etc/ppp/gprs-connect-chat    fname_chat_disconnect    /etc/ppp/gprs-disconnect-chat    fname_chap_secrets    /etc/ppp/chap-secrets    is_up  
   configure    up    evq    signal_add    SIGCHLD    config 
   add_watch    /network/macaddress    get    /network/current_ip 	   /network    set    /dev/modem    /network/interface 	   register    check_network_status_timer    push        @                       @@  CÁ  @ Á @         evq    push    network_reconfigure       ð¿   up                                    node     
      nw     
         config_is_changed L   i  l  m  n  o  p  q  r  u  u  v  v  y  y  y  y  {  {  {  {  {  {  {  |  |  |  |  |  |  |  ~  ~  ~                                                                                              netwrk    K      reconfigure #   K   	   
   configure    up    get_macaddress    get_current_ip    carrier_status    get_carrier_status    config_is_changed    on_interface_changed    on_check_network_status_timer M                     	   
                     C   C   C            /  /  /  G  G  G  G  G  G  X  ^  n  n  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ï  Ù  Ù  Û  ê  ê  ê  +  +  +  +  +  +  +  +  +  +  4  7  S  S  S  8  `  V                      g          lgid    L      led_status    L      carrier_status    L      upping_network 	   L      again 
   L      wlan_signal_strength    L      config_is_changed    L      open_or_die    L      configure_ethernet    L      configure_wifi    L      configure_gprs    L   
   configure    L      get_carrier_status    L      get_macaddress    L      get_current_ip_addr !   L      up )   L      get_current_ip +   L      prev_signalstrength ,   L      get_wlan_signal_strength /   L      on_check_network_status_timer 9   L      on_interface_changed :   L      has_gprs_hw ;   L       