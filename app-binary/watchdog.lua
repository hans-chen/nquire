LuaQ     @watchdog.lua                 A@  ��  ��@@�$   d@      ��    � �   �       module 	   Watchdog    package    seeall    new                
   � � �@@�  �@�� � ��@�@ � � �   �       fd    write    
    flush     
   	   	   	   	   
   
   
                  event     	      wdt     	                     E   F@� ��  ��  \��Z@  ���  A A� �� � �@� � 	@ ��@ ˀ�A� �  �  �@��@ � �A� �  �A �@� �       io    open    /dev/watchdog    w    logf    LG_WRN 	   watchdog #   Could not open watchdog device: %s    fd    evq 	   register 
   wdt_timer    push       �?                                                                                                 wdt           fd          err             on_wdt_timer     #   0        
�  	@@�D   	@ �   �       fd     start        %   (   +   +   .   0         wdt             start                            0   0   #   0         on_wdt_timer          start           