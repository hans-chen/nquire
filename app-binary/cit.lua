LuaQ  	   @cit.lua           $å      A@    À@@  A@ @  AÀ   Á@  @Á ÁÁ  AB   ÁÂ $  dC                 ¤    äÃ       d        äD    	    
E JÅ  IEDIÅB¤           I	EJÅ  IEDIÅB¤Å           I	EJÅ  IEIÅE¤        I	EJÅ  IEFIÅE¤E      I	EJÅ  IÅFIG¤                         I	EJÅ  IGIÅB¤Å I	EJÅ  IHIÅB¤ I	EJÅ  IHIÅH¤E           I	EJÅ  IEIIÅB¤ I	EJÅ  IÅIIÅH¤Å I	EJÅ  IEJIÅH¤ I	EJÅ  IÅJIÅH¤E I	EJÅ  IEKIÅB¤ I	EJÅ  IÅKIÅB¤Å I	EJÅ  IELIÅE¤ I	EJÅ  IÅLIÅB¤E    I	EJÅ  IEMIÅH¤   	I	EdÅ                    
¤      
  äE    $    dÆ    ¤   äF     $      dÇ   ¤ äG $        	          dÈ           	     ¤	     äH	                   Ç   7      module    CIT    package    seeall    require    cit-codepages       n@      `@
   arial.ttf       8@      @@           l    t    normal       B@   name    clear screen    nparam    fn      B@     C@   set cursor position        @      F@   set pixel position       G@   align string of text       :@      P@   sleep      @P@   wakeup      P@   select font set       ð?     V@   soft reset      ÀV@   enable/disable scanning       W@   enable/disable backlight      @W@   slaap/wakeup barcode scanner      W@   beep      ÀW@   get firmware version      _@   Set GPIO output      Ào@   show configuration      ào@
   fake scan    new &       %   5     $      @    @Ê   A  J    Á@À   T   bA   W@ATLÁB     É!   ý ÁA@        	      codepage_to_utf8    ipairs    string    byte       ð?           table    concat         $   '   '   )   )   *   +   +   +   +   +   +   +   +   +   +   +   ,   ,   -   -   -   -   -   -   -   +   .   0   0   0   0   0   1   1   3   5   
      text     #      page     #      xlat    #      out    !      (for generator)          (for state)          (for control)          _          c          out     !           <   S    A   ÀB  AB   À  @B  AB     À  D  ÀÀ  D  Á@  O@AÁ  D  ÀA@ @A B   A B @A A ÁB   Á Á@ BAM  Á  M ÀA BÁBA  B@ BÁ B C À B B BC  B        sub       ð?   small    large    c        @   r    m    b    display 	   set_font    get_text_size    gotoxy 
   draw_text     A   >   >   >   >   >   ?   ?   ?   ?   ?   @   @   @   A   A   A   C   C   C   C   D   D   D   E   E   E   E   F   F   F   H   H   H   H   H   I   I   I   I   K   K   K   K   L   L   L   M   M   M   M   M   N   N   N   N   P   P   P   P   P   Q   Q   Q   Q   S         text     @      xpos     @      ypos     @      align_h     @      align_v     @      size     @      text_w '   @      text_h '   @         fontsize_small    fontsize_big    dpy_w    dpy_h    font     V   r     B   
 A   @  Á  Á  A A Á Â A "@E@ KÂ ÁÀ Á \@ E@ K Ã Á@ \@E@ KÃ \@ E@ K Ã ÁÀ \@A@ G  E    \ Á E Ä  BEA ÂE AB  Á  AC ÜAÅ ÌÆÇ a  úEÀ   Á@  \@ EÀ K È Á@  A \@  #   
   /dev/name    /dev/version    /dev/build    /network/current_ip    /network/interface    /network/macaddress    /dev/display/contrast    /dev/beeper/beeptype    /dev/beeper/volume    display    gotoxy         
   set_color    black    clear    white    y       ð?   ipairs    config    lookup    label    :     get           *@      ,@   logf    LG_DMP    cit &   Initiating cit_idle_msg in 10 seconds    evq    push    cit_idle_msg       $@    B   X   Y   Z   [   \   ]   ^   _   `   b   b   d   d   d   d   d   e   e   e   e   f   f   f   g   g   g   g   i   i   j   j   j   j   k   k   k   k   l   l   l   l   l   l   l   l   l   l   l   l   m   m   m   j   m   p   p   p   p   p   q   q   q   q   q   q   r         keys    A      (for generator)     6      (for state)     6      (for control)     6      _ !   4      key !   4      node %   4         format_text     z       F      @@Á   ÅÀ  Ë ÁAA ÜÁ  A E  FÁÁ À    A ÕA @ \AE  FAÂ \A E Á C\@Â  AC C Å  ÆÂÃD@   Á UÃÜBÅ  ÆÂÃD@   UÜBa  ÀùB  H  EA Á  A \  Á EB CA        net    socket    udp    config    get    /cit/remote_ip    /cit/udp_port    sendto    
    close    pairs    cit    client_list    /dev/scanner/enable_barcode_id    true    send    sock 	   tonumber    /cit/messages/error/timeout    evq    push    cit_error_msg     F   ~   ~   ~   ~                                                                                                                                                                                                               barcode     E      prefix     E      sock    E      addr    E      port    E      (for generator)    7      (for state)    7      (for control)    7      client    5      _    5      enable_prefix #   5      timeout ?   E         message_received        Ñ    
v                 Å@    AÁ    @  @A ÀA   @       B A    @Å   A  A   À Ü@Å  ËÀÁAÁ  À  Â Ü@Ë B AA ÜÚ     EA    Á  A ÁAÁ Å  Ü ÌÄ AB A   @E  A  Á   @ \AE KÁÁÁÁ  @  B \AKB Á \Z  @@Å   ÅA    A A Á FÁA A Æ   ÅA    AÂ A Á FÁ A Á FÁA A @Ç@  A Ç@            logf    LG_INF    cit &   Programming product serial number: %s    config    lookup    /dev/serial    set    match 
   ^0203(..) 2   Scanned 'beeper volume' barcode, set volume to %s    /dev/beeper/volume 	   tonumber 
   ^0204(..) :   Scanned 'beeper sound type' barcode, set sound type to %s    /dev/beeper/beeptype       ð?
   ^0205(..) 7   Scanned 'display contrast' barcode, set contrast to %s    /dev/display/contrast 
   ^0207(..)    00 +   Scanned 'reboot' barcode, rebooting system    os    execute    reboot    01 C   Scanned 'factory defaults' barcode, restoring and rebooting system    rm -f cit.conf    02    04     v                                                         ¡   ¡   ¦   ¦   ¦   §   §   ¨   ¨   ¨   ¨   ¨   ¨   ©   ©   ©   ©   ©   ©   ©   ©   ®   ®   ®   ¯   ¯   °   °   °   °   °   °   ±   ±   ±   ±   ±   ±   ±   ±   ±   ¶   ¶   ¶   ·   ·   ¸   ¸   ¸   ¸   ¸   ¸   ¹   ¹   ¹   ¹   ¹   ¹   ¹   ¹   ¾   ¾   ¾   ¿   ¿   À   À   Á   Á   Á   Á   Á   Â   Â   Â   Â   Ä   Ä   Å   Å   Å   Å   Å   Æ   Æ   Æ   Æ   Ç   Ç   Ç   Ç   É   É   Ê   Ê   Ì   Ì   Í   Í   Ñ         barcode     u      prefix     u      tmp    u      tmp *   u      tmp >   u      tmp Q   u         next_barcode_is_serial    show_configuration     Ü   ù    
I    @ @@@      Æ @ ÆÀÀÚ@    Á   AA ÁÁ A    B@BÀ EÁ  ÁA A    @ @ A   C@ÀCÀ    EÁ  Á A À  @ AA DÁ A     EA KÄÁA   Õ\ ÁE A AA A A         data    barcode    ?    prefix    led    set    yellow    off    normal    %#$^*%    logf    LG_INF    cit #   Scanned 'programming mode' barcode    programming    %*^$#%    Scanned 'normal mode' barcode    config    get    /dev/beeper/beeptype    1    /dev/beeper/tune_    beeper    play    on     I   Þ   Þ   Þ   Þ   Þ   ß   ß   ß   ß   ß   á   á   á   á   á   ã   ã   ã   ä   ä   å   å   å   å   å   æ   æ   æ   è   è   è   è   é   ê   ê   ê   ë   ë   ì   ì   í   í   í   í   í   í   ï   ï   ï   ï   ó   ó   ó   ó   ó   ó   ó   ô   ô   ô   ô   ô   ô   õ   õ   õ   õ   ÷   ÷   ÷   ÷   ÷   ù         event     H      cit     H      barcode    H      prefix 
   H      tune 9   H      tune ?   H         barcode_mode    handle_barcode_normal    handle_barcode_programming             E   K@À Á    \@ E   KÀÀ Á  \@E   K@Á \@ E   KÀÀ Á \@A  H   A  H  AÀ H  A  H   	      display    gotoxy         
   set_color    black    clear    white    l    t                          	  	  	  
  
  
  
                          cit              pixel_x    pixel_y    align_h    align_v             E   K@À Á    \@ E   KÀÀ Á  \@E   K@Á \@ E   KÀÀ Á \@A  H   A  H  AÀ H  A  H   	      display    gotoxy         
   set_color    black    clear    white    l    t                                                                cit              pixel_x    pixel_y    align_h    align_v     $  '      Í À Î@ÀÈ   Í @ Î È             H@       @       %  %  %  &  &  &  &  '        cit           x           y              pixel_x    pixel_y 	   fontsize     -  0      Í À È   Í @È             H@       .  .  /  /  0        cit           x           y              pixel_x    pixel_y     6  R  	   ÊÀ 
 AA  A  Á  Â  "A É 
 D  OAÁA  Á Â  "A É 
 D  A  Á Â  "A É 
 AA   AAÁ   "A É 
 D  OAÁ AAÁ  "A É 
 D   AAÁ  "A É 
 AA   Á   "A É 
 D  OAÁ Á  "A É 
 D   Á  "A É 
 AA   Á   "A É 
 D  OAÁ Á  "A É 
 D   Á  "A É 
 CA  ÃÂ  "A É 
 C AAÃ "A É 
 C Ã "A É A  ÀAÁEA      AFA    A Fe    D  ÆÁF \ D Ä D Ä \A           H@           l    t      H@       @   c       I@   r      I@   m       J@     J@      K@   b      K@      L@     L@      M@     M@      N@     N@      O@      @      @   string    char 	   codepage        8  9  9  9  9  9  9  9  :  :  :  :  :  :  :  :  ;  ;  ;  ;  ;  ;  ;  <  <  <  <  <  <  <  <  =  =  =  =  =  =  =  =  =  >  >  >  >  >  >  >  >  ?  ?  ?  ?  ?  ?  ?  @  @  @  @  @  @  @  @  A  A  A  A  A  A  A  B  B  B  B  B  B  B  C  C  C  C  C  C  C  C  D  D  D  D  D  D  D  E  E  E  E  E  E  E  F  F  F  F  F  F  F  F  G  G  G  G  G  G  G  J  J  J  K  K  K  K  K  K  L  L  L  L  L  L  O  O  O  O  P  P  P  P  P  Q  Q  Q  Q  Q  Q  Q  Q  R        cit           pos           arg           align r         text       	      dpy_w    dpy_h    align_h    align_v    to_utf8    format_text    pixel_x    pixel_y 	   fontsize     X  Y                    Y        cit                 _  `                    `        cit                 f  n       À @      @À @        À@D  @            H@     H@   display 	   set_font        g  g  h  h  j  j  k  k  m  m  m  m  m  n        cit           f           	   fontsize    fontsize_small    fontsize_big    font     t  w    
   E   @  Á  Á  \@ E  F@Á  \@         logf    LG_WRN    cit    Reset not implemented    os    execute    reboot     
   u  u  u  u  u  v  v  v  v  w        cit     	           }          À  @  @@ ÀÀ  @   A@            H@   scanner    disable      H@   enable        ~  ~                          cit     
      onoff     
                       Å@    AÁ  @         logf    LG_WRN    cit )   Backlight enable/disable not implemneted                          cit           onoff                          À  @  @@ ÀÀ  @   A@            H@   scanner    disable      H@   enable                                    cit     
      onoff     
             ¡       E   K@À Á  \@        beeper    play 	   o3c16g16                    ¡        cit                §  ª       E   @  Á  Á  \@ E  K@Á Á ] ^           logf    LG_WRN    cit $   Returning data not yet implmenented    config    get    /info/version/version        ¨  ¨  ¨  ¨  ¨  ©  ©  ©  ©  ©  ª        cit     
           °  ¸    
   M À  @Å@    AÁ   À   Ü@ Å@ ÆÁ  @ ÜÀÚ@  @EA  Á ÁÁ   @ \A  	         H@   logf    LG_INF    cit    Setting GPIO port %q to %q    sys 	   gpio_set    LG_WRN "   Error performing GPIO command: %s        ±  ²  ³  ³  ³  ³  ³  ³  ³  ´  ´  ´  ´  ´  µ  µ  ¶  ¶  ¶  ¶  ¶  ¶  ¸        cit           nr           state           ok          err               À  Â         @              Á  Á  Â        cit           n              show_configuration     Ê  Ò       À @ @      Ä   
A  JA  I 	A@  Ü@           ð?   4918734981    9869087697    data    barcode        Ì  Ì  Í  Í  Ï  Ñ  Ñ  Ñ  Ñ  Ñ  Ñ  Ñ  Ò        cit           n           barcode              on_barcode     Ü         @ @@@@À @ @   À À  Å  A A @ 	ÀA@W Â @ @Â À@       Ä  À     Ä  Í @ @     ÀB  D @ @  Å  Æ@Ã  Ü C Å ËÀÃA Ü@Å Ë@ÄD Ü@ Å ËÀÂD   Ü@ Å ËÄ@ Ü  Á     @ ÀAÀ  @    À  @ 	ÀD  E@@ À  Å  A AA ÁD E@ÀD ÀEÀ   @ 	@@@
   	 	@F@	À  Å A AÁ  @	@@@W Ç  @ GÆ F   @W Ç @ F   ÆÀD Æ ÅÀ À  Å  A AA ÁD E@ÀD ÀEÀ   Á FF  @  	@@         n               ;@   logf    LG_DBG    cit    Start of escape sequence       ð?      $@      *@   display    gotoxy    string    char 	   codepage 
   set_color    white 	   set_font 
   draw_text    cmd    nparam    Handling command %q    name    fn    param        @   LG_WRN /   Unknown/unhandled escape command %02x received       @   table    insert    unpack        à  à  à  ä  ä  å  å  æ  æ  ç  ç  ç  ç  ç  è  è  é  é  é  é  ê  ê  ë  ë  ë  ë  ì  ì  ì  ì  ì  ì  ì  ì  í  í  í  í  í  í  ï  ï  ï  ï  ï  ï  ï  ð  ð  ð  ð  ñ  ñ  ñ  ñ  ñ  ò  ò  ò  ò  ò  ó  ó  ó  ó  ô  ô  ô  õ  ÷  ÷  ÷  û  û  û  û  ü  ü  ü  ý  ý  ý  ý  þ  þ  þ  þ  þ  þ  þ  ÿ  ÿ  ÿ  ÿ                                                                                                    cit           c           nop          text /   D      w A   D         pixel_x    pixel_y 	   fontsize    dpy_h    to_utf8    font    command_list       *   
'           Ê   AÀ   Ô  â@   À Ä    @ ÜA¡  @þÀ  Å  Ë@ÁA Ü   ÅÀ  AA  Ü@ ÅÀ Ë ÃAA  À Ü@Å ÆÀÃÜ È          ipairs    byte       ð?	   tonumber    config    get    /cit/messages/idle/timeout    logf    LG_DMP    cit %   Initiating cit_idle_msg with timeout    evq    push    cit_idle_msg    sys 
   hirestime     '       !  !  !  !  !  !  !  !  !  "  "  "  "  !  "  %  %  %  %  %  %  &  &  &  &  &  '  '  '  '  '  '  (  (  (  (  *        cit     &      command     &      (for generator) 
         (for state) 
         (for control) 
         _          c          timeout    &         message_received    handle_byte 
   t_lastcmd     5  A       @ @@ÆÀ WÀ     ÅÀ  Æ ÁÀ AA ÜÚ    À   @ A        data    fd 	   sock_udp    net    recv       @               7  7  8  8  8  8  :  :  :  :  :  <  <  <  <  <  =  =  =  =  A        event           cit           fd          command             handle_bytes     H  V       À Æ@@ ÆÀÁÀ W      AA@   ÀT @ D   À \A@ KÂ \A   	      cit    data    fd    sock    net    recv       @           close        J  K  K  L  L  L  L  N  N  N  N  N  P  P  P  P  P  Q  Q  Q  Q  Q  S  S  V        event           client           cit          fd          command             handle_bytes     ]  z      
A 	 	A	 	Ád         	AFAA I	ÀAE KAÂÀ \AE KÂÁÁ   @ \AE A Á   @ \A         cit    sock    addr    port    close    client_list    client_connected    evq    fd_add 	   register    fd    logf    LG_INF    Connected to %s:%d        j  q      E   F@À @ \@ EÀ  K Á Æ@ \@EÀ  K@Á Á   @  \@D  FÀÁ I B E@  ÁÀ  FAC C \@ D  I Ä        net    close    sock    evq    fd_del    unregister    fd    client_list     logf    LG_INF    cit !   Closed TCP connection from %s:%d    addr    port    client_connected         k  k  k  k  l  l  l  l  m  m  m  m  m  m  n  n  n  o  o  o  o  o  o  o  p  p  q        client              on_tcp_client    cit    _  c  d  e  f  q  q  q  q  t  t  u  v  v  v  v  w  w  w  w  w  w  x  x  x  x  x  x  x  z        cit           sock           addr           port           client 	            on_tcp_client              @ @@ÆÀ WÀ     ÅÀ  Æ Á  Ü Ú@  ÀA  ÅÁ  AB B A    À  @   
      data    fd 	   sock_tcp    net    accept    err    logf    LG_WRN    cit    Error accepting client: %s                                                                    event           cit           fd          sock 
         addr 
         port 
         client             client_new       ¾   f   E   @  Á  Á  \@ E  F@Á \    M  ÀA @B      ÀB @ @C@  ÀB @ ÀC ÀA @D  DÁÀ À      @ @E A  U  ÅÂ   A B BF B!  û@ Á A  À ÁABÅ ËÁÁPBÜ ÂABE KÂÁÐB\ ÂACÅ ËÂÁPCÜ @ À  @ C÷  !      logf    LG_DBG    cit    draw_idle_msg    sys 
   hirestime    config    get    /cit/messages/idle/timeout       ð?   display 
   set_color    black    clear    white    lookup %   /cit/messages/idle/show_idle_picture    true    readdir    /cit200/img    ipairs    welcome.gif    /cit200/img/    LG_DMP    using welcome image %s    draw_image       @   /cit/messages/idle/%s/text    /cit/messages/idle/%s/xpos    /cit/messages/idle/%s/ypos    /cit/messages/idle/%s/halign    /cit/messages/idle/%s/valign    /cit/messages/idle/%s/size     f                                       ¡  ¡  ¡  ¡  ¢  ¢  ¢  £  £  £  £  ¦  ¦  ¦  ¦  ¦  ¦  ¦  ¦  §  §  §  §  ¨  ¨  ©  ©  ©  ©  ª  ª  «  «  «  ¬  ¬  ¬  ¬  ¬  ¬  ­  ­  ­  ­  ©  ®  ´  ´  ´  ´  µ  µ  µ  µ  ¶  ¶  ¶  ¶  ·  ·  ·  ·  ¸  ¸  ¸  ¸  ¹  ¹  ¹  ¹  º  º  º  º  »  »  »  »  »  »  »  »  ´  ¾        cit     e   	   idletime 
   e      files )   @      err )   @      (for generator) .   @      (for state) .   @      (for control) .   @      _ /   >      file /   >      image_path 4   >      (for index) C   e      (for limit) C   e      (for step) C   e      row D   d      msg H   d      xpos L   d      ypos P   d      align_h T   d      align_v X   d      size \   d      
   t_lastcmd    format_text     Å  Ù   @   D   Z       E   K@À Á  \@E   KÀÀ \@ E   K@À Á  \@A@  Á@ `ÀEÁ KÂÐ\Á BÅÁ ËÂPÜÂ BEÂ KÂÐ\Â BÄ  @ À  @ ÜB_÷EÀ   Á@  \@ EÀ K Å Á@  A \@        display 
   set_color    black    clear    white       ð?       @   config    get    /cit/messages/error/%s/text    /cit/messages/error/%s/xpos    /cit/messages/error/%s/ypos    /cit/messages/error/%s/halign    /cit/messages/error/%s/valign    /cit/messages/error/%s/size    logf    LG_DMP    cit %   Initiating cit_idle_msg in 5 seconds    evq    push    cit_idle_msg       @    @   Ç  Ç  Ç  Ç  É  É  É  É  Ê  Ê  Ê  Ë  Ë  Ë  Ë  Í  Í  Í  Í  Î  Î  Î  Î  Ï  Ï  Ï  Ï  Ð  Ð  Ð  Ð  Ñ  Ñ  Ñ  Ñ  Ò  Ò  Ò  Ò  Ó  Ó  Ó  Ó  Ô  Ô  Ô  Ô  Ô  Ô  Ô  Ô  Í  ×  ×  ×  ×  ×  Ø  Ø  Ø  Ø  Ø  Ø  Ù        cit     ?      (for index)    4      (for limit)    4      (for step)    4      row    3      msg    3      xpos    3      ypos    3      align_h #   3      align_v '   3      size +   3         message_received    format_text     Ü     T      @@  À@@ Â  Þ  Æ Á Ú   @ Â  Þ  Å   Ë@ÀAA Ü  A@ EÁ FÂA \ Á BÀ @ Á A   
Â  J  	BJB  IBÃ	BJ  	BEÂ FÄ ÁB \ZB     Á Â ÂDÀ ÂÀ W@E  A       @ À  B@Â E@B Â E B Á  B          config    get 
   /cit/mode    server    client_connected    /cit/remote_ip    /cit/tcp_port    net    socket    tcp    connect    r    w    e    sys    select       à?   timeout    getsockopt 	   SO_ERROR            close    logf    LG_DBG    cit    Could not connect: %s     T   à  à  à  à  á  á  â  â  ç  ç  ç  è  è  í  í  í  í  î  î  î  î  ï  ï  ï  ï  ð  ð  ð  ð  ð  ð  ò  ò  ó  ó  ó  ó  ó  ó  ó  ó  ô  ô  ô  ô  ô  õ  õ  ö  ÷  ÷  ù  ù  ù  ù  ù  ù  ù  ú  ú  ú  ú  þ  þ  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ  ÿ                            
      event     S      cit     S      mode    S      addr    S      port    S      sock    S      ok    S      err    S      fds_in )   >      fds_out .   >         client_new       
        À @         draw_idle_msg        	  	  
        event           cit                          À @         draw_error_msg                    event           cit                  `   ±   E   @  Á  Á  \@ E  K@Á Á \  @AÁ Å  Æ@Â Ü  ÁB@ À A A CAA ÁC Ä     A	À  EA    Á   AÀÄ À AA E FAÂA \  ÁBÀ @ A  EÀÂ AA C AA ÁC D   A	@  ÅA    AB  A AAÁ 	  GÁ ÁA $      E A A ÁC Ä    AA ÁCÁ Ä   AA ÁC Ä    A  
 AA  ÁÁ 	 "A EA	 KÉÁÁ	 Â	 \A EA	 KÊÁA
 \AEA	 KÊ\A EA	 KÊÁÁ
 \AAA G E  \ ÂK Ä LAC CA AC  Á  AÄ ÜBÅ ÌÍÇ a  úE  A Á   \A EA KÁÍÁÁ  A \AEA KAÇÁ Â \A   <      logf    LG_INF    cit    Starting CIT server    config    get 
   /cit/mode    /cit/udp_port    net    socket    udp    bind    0.0.0.0    evq    fd_add 	   register    fd 	   sock_udp    Listening on UDP port %d    server    /cit/tcp_port    tcp    listen       @	   sock_tcp    Listening on TCP port %d 	   codepage    /cit/codepage 
   add_watch    set    scanner    cit_idle_msg    cit_error_msg 
   /dev/name    /dev/version    /dev/build 
   /dev/date    display    gotoxy         
   set_color    black    clear    white    y       ð?   ipairs    lookup    label    :            *@      ,@   LG_DMP %   Initiating cit_idle_msg in 2 seconds    push        @   led    yellow    on        5  7          E@  KÀ ÁÀ  \	@      	   codepage    config    get    /cit/codepage        6  6  6  6  6  6  7            cit ±                                                                           !  "  "  "  "  "  "  &  &  '  '  '  '  (  (  (  (  )  )  )  )  )  )  *  *  *  *  *  +  +  +  +  ,  ,  ,  ,  ,  ,  -  .  .  .  .  .  .  4  4  4  4  4  5  5  5  5  7  7  7  5  ;  ;  ;  ;  ;  ;  ?  ?  ?  ?  ?  ?  @  @  @  @  @  @  D  D  F  G  H  I  K  K  M  M  M  M  M  N  N  N  N  O  O  O  P  P  P  P  R  R  S  S  S  S  T  T  T  T  U  U  U  U  U  U  U  U  U  U  U  U  V  V  V  S  V  Y  Y  Y  Y  Y  Z  Z  Z  Z  Z  Z  ^  ^  ^  ^  ^  `        cit     °      mode 	   °   	   udp_port    °      sock    °   	   tcp_port .   N      sock 2   N      keys u   °      (for generator)           (for state)           (for control)           _          key          node             on_udp    on_tcp_server    on_barcode    on_draw_idle_msg    on_draw_error_msg    message_received    format_text     g     Q   E   @  Á  Á  \@ F A Z   ÀE@ FÁ  A \@ EÀ K Â Æ A \@EÀ K@Â Á   @  \@FÀB Z   @E@ FÁ ÀB \@ EÀ K Â ÆÀB \@EÀ K@Â Á  @  \@E  @C \ ÀA AÆCA Á BCAÁ AB D  AAC ÁCa  @û	@DEÀ K@Â Á @  \@EÀ K@Â ÁÀ  @  \@EÀ K@Â Á  @  \@        logf    LG_INF    cit    Stopping CIT server 	   sock_udp    net    close    evq    fd_del    unregister    fd 	   sock_tcp    pairs    client_list    sock     client_connected     scanner    cit_idle_msg    cit_error_msg     Q   i  i  i  i  i  k  k  k  l  l  l  l  m  m  m  m  o  o  o  o  o  o  q  q  q  r  r  r  r  s  s  s  s  t  t  t  t  t  t  w  w  w  w  x  x  x  x  y  y  y  y  z  z  z  z  z  z  {  {  w  {  }                                              cit     P      (for generator) *   =      (for state) *   =      (for control) *   =      client +   ;      _ +   ;         on_udp    on_tcp_server    on_tcp_client    on_barcode    on_draw_idle_msg    on_draw_error_msg          *   Å   Ë@ÀA    Ü@ Å   ËÀÀA Ü@Å   Ë@ÁÜ@ Å   ËÀÀA Ü@ÁÀ Z   @  @   À AB  A Ì    @  @   À AB  A Ì   
      display    gotoxy         
   set_color    black    clear    white       $@   c         *                                                                                             cit     )      msg1     )      msg2     )      y    )         format_text    fontsize_small       Ì    
D   
À 	@@	À@J   	@ 	ÁJ   	@	@BD   	@ D  	@D  	@ D 	@D  	@ EÀ K Ä Á@  d      \@EÀ F Å @ \ Z   À À   @ËÁEA ÜÚ   B @B@ ¡  Àü ÀF D   @ @G @   @À Å  A A @    #      n            cmd     param 	   codepage    utf-8    client_list    client_connected     start    stop    draw_idle_msg    draw_error_msg    show_message    config 
   add_watch    /cit    set    sys    readdir    /mnt    ipairs    match    .+.ttf$    /mnt/    evq 	   register    connect_timer    push       @   logf    LG_INF    cit    Using font file %q        ±  ´           @ @    @@ @         stop    start        ²  ²  ²  ³  ³  ³  ´            cit D     ¡  ¢  £  £  ¤  ¥  ¥  ¦  ª  ª  «  «  ¬  ¬  ­  ­  ®  ®  ±  ±  ±  ±  ´  ´  ±  ¸  ¸  ¸  ¸  ¹  ¹  º  º  º  º  »  »  »  ¼  ¼  ½  ½  ½  ½  ¾  º  ¿  Å  Å  Å  Å  Å  Å  Æ  Æ  Æ  Æ  Æ  Æ  È  È  È  È  È  È  Ê  Ì        cit    C      files    C      (for generator) #   0      (for state) #   0      (for control) #   0      _ $   .      file $   .      tmp '   .         start    stop    draw_idle_msg    draw_error_msg    show_message    font    on_connect_timer å                           	   
                                 5   S   S   S   S   S   S   r   r            Ñ   Ñ   Ñ   Ù   ù   ù   ù   ù                                             !  "  #  '  '  '  '  '  (  *  +  ,  0  0  0  0  1  3  4  5  R  R  R  R  R  R  R  R  R  R  R  S  U  V  W  Y  Y  Z  \  ]  ^  `  `  a  c  d  e  n  n  n  n  n  n  o  q  r  s  w  w  x  z  {  |                                      ¡  ¡  ¢  ¤  ¥  ¦  ª  ª  «  ­  ®  ¯  ¸  ¸  ¹  ½  ¾  ¿  Â  Â  Â  Ã  Ç  È  É  Ò  Ò  Ò  Ó                  *  *  *  *  A  A  V  V  z  z      ¾  ¾  ¾  Ù  Ù  Ù      
    `  `  `  `  `  `  `  `                      Ì  Ì  Ì  Ì  Ì  Ì  Ì  Ì    Ì  #      dpy_w 	   ä      dpy_h 
   ä      font    ä      fontsize_small    ä      fontsize_big    ä   	   fontsize    ä      pixel_x    ä      pixel_y    ä      align_h    ä      align_v    ä      message_received    ä   
   t_lastcmd    ä      to_utf8    ä      format_text    ä      show_configuration    ä      handle_barcode_normal    ä      next_barcode_is_serial     ä      handle_barcode_programming #   ä      barcode_mode $   ä      on_barcode (   ä      command_list «   ä      handle_byte ³   ä      handle_bytes ·   ä      on_udp ¹   ä      on_tcp_client »   ä      client_new ½   ä      on_tcp_server ¿   ä      draw_idle_msg Â   ä      draw_error_msg Å   ä      on_connect_timer Ç   ä      on_draw_idle_msg È   ä      on_draw_error_msg É   ä      start Ñ   ä      stop Ø   ä      show_message Û   ä       