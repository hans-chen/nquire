LuaQ     @watchdog.lua                 A@    Ā@@$   d@      Ī      äĀ        Į          module 	   Watchdog    package    seeall    new                
    Ā @@  @ Ā Ā@@             fd    write    
    flush     
   	   	   	   	   
   
   
                  event     	      wdt     	                     E   F@Ā   ÁĀ  \ĀZ@  Å  A A Á Ā Ü@  	@ Å@ ËÂAÁ   Ā  Ü@Å@ Ë ÃAÁ   ÁA Ü@        io    open    /dev/watchdog    w    logf    LG_WRN 	   watchdog #   Could not open watchdog device: %s    fd    evq 	   register 
   wdt_timer    push       ð?                                                                                                 wdt           fd          err             on_wdt_timer        "       E   K@Ā Á    @  \@EĀ  F Á @A \@         evq    unregister 
   wdt_timer    io    close    fd                                !   !   !   !   "         wdt     
         on_wdt_timer     )   7        
Ā  	@@D   	@ D  	@          fd     start    stop        +   .   1   1   2   2   5   7         wdt             start    stop                            "   "   7   7   7   )   7         on_wdt_timer          start          stop 
          