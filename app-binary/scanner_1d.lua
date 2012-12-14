LuaQ     @scanner_1d.lua           ,      A@  ��  ��@@�  d       �@      �      $�      d     �A     �     $�       � d   � �B � $� d GC dC      �     �        �  �  �      G�  �       module    Scanner_1d    package    seeall    scanner    is_available    new           :    [   � @ �@@�@� W�   � � ��  ��@�@ �  �@A�@� � ����   @����   � �I������ � �AA ���E� �� �   EB ��� �� \�\A  �   ��@��A   ��� I����� �   AB ���A���� ��� E� � \ �W@E���������� �   A� ���C�B�@ �a�   �B  @�E� � �  � \B � E KB��� 
�  	ȏ	Á�	�\B � �ŀ  A� �@� � $      data    fd    beeper    beep_ok    sys    read       p@   scanbuf    match    (.-)[
](.*)    logf    LG_DMP    Scanbuf:
%s    dump       $@       LG_DBG    Scanned barcode '%s'    (.)(.+)    ipairs 	   prefixes  
   prefix_1d    Scanned %q barcode type    name    prefix_out    Scanned unknown barcode type    ?    evq    push    scanner    result    ok    barcode    prefix /   event but no data received from scanner device     [                                                                                                                                                   %   %   %   &   (   (   (   (   )   )   )   )   )   *   *   *   *   *   *   +   ,   (   -   0   0   1   1   1   1   1   2   5   5   5   5   5   5   5   5   6   8   8   8   8   :         event     Z      scanner     Z      data    Z      t1    U      t2    U      barcode $   U   
   prefix_in 1   U      barcode 1   U      prefix_out 2   U      (for generator) 5   E      (for state) 5   E      (for control) 5   E      _ 6   C      i 6   C         lgid     =   K    %   �   W@� @ ���   �A�  �  �@�� �@ �  ���B @� ܀��   @�� �� �  @��@�   � ���@@��@ � D  �� � ���@ �   �                       �@   sys    sleep {�G�z�?   read    fd    logf    LG_DMP    <      %   >   ?   ?   ?   ?   ?   B   B   B   B   C   C   C   C   C   D   D   D   D   D   E   E   E   G   G   G   G   G   I   I   I   I   I   I   I   J   K         scanner     $      n     $      data    $      buf             lgid     M   ^    )   A   �  W@@� ��  �� ���  � �AA A� ܀�� �M�� �� ���  A D  �� �@ �� �  ��  � �A �@ @��  �C � � ��  � D  � � ���@ �   �          $@            sys    read    fd       �@      �?   logf    LG_DBG 8   Nothing received from scanner within timout of 1 second        sleep �������?   flush    LG_DMP    Scanner returned      )   N   O   P   P   P   P   P   Q   Q   Q   Q   Q   Q   R   S   S   T   T   T   T   T   U   U   W   W   W   W   W   Z   Z   Z   Z   \   \   \   \   \   \   \   ]   ^         scanner     (      delay    (      buff    (         lgid     h   q    
#   �   �@��@ @� �@���   D  �A ��   �@ ˀA ܀ � B@��A ��A  @��  E� �  ��  �@� A  �B  � �B� � �       sys    write    fd    logf    LG_DBG    Sent %s to scanner (%s)    read    string    find    ^!.+;    LG_WRN 4   Error '%s' on scanner command %s during programming     #   i   i   i   i   i   j   j   j   j   j   j   j   k   k   l   l   l   l   l   l   l   m   m   m   m   m   m   m   n   n   n   p   p   p   q         scanner     "      cmd     "      cmd_txt_label     "      answer    "         lgid     t   }       E   �@  �   �  \@ E�  F � �@A �� \@�K�A \� W � ���   �@   A� ��B �@��   �  � C A A� �  �    �       logf    LG_DMP    Switching to programming mode    sys    write    fd    $$$$    read    @@@@    LG_WRN A   Scanner %s might not work (Could not switch to programming mode)    device    cmd    #99900031;    Code programming on        u   u   u   u   u   v   v   v   v   v   w   w   x   x   y   y   y   y   y   y   z   z   |   |   |   |   |   }         scanner           answer             lgid     �   �    	"   E   �@  �   �  \@ K�@ �  A \� ŀ ���B AA �@�ˀB ܀ � C@��A ��A  ��  E� �  �� D A�   �   �       logf    LG_DMP    Switching to normal mode    cmd    #99900032;    Code programming off    sys    write    fd    %%%%    read    string    find 
   %^%^%^%^$    LG_WRN ,   Scanner %s: Could not switch to normal mode    device     "   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         scanner     !      answer1 	   !      result 	   !      answer2    !         lgid     �   �    	@   �   @ @@���  E�  �  �  � A� �@� ���A �� � � � ��  �	�@� ���A �� �� � � ��  �   @��A � �� � � ��  ��@� ���A �� �� � � ��  �    ��A �� � � � ��  @��A �A �� � � ��    @�� �       fd     logf    LG_WRN 5   nil-file descriptor. Scanning mode %s not activated.    Off    cmd    #99900102;    Sleep 	   Blinking    #99900151;#99900000;#99900001    Short Interval length    #99900112;    Sensor mode    #99900113;    #99900152;    High sensitivity    #99900114;     @   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         scanner     ?      mode     ?      data     ?      retval    ?         lgid     �      �   K @ \@ E@  K�� ��   \@ 	���E� �  �   A FAA \@�E� F�� �@A �  \��Z@  ���� A D  �� �AA   �@  � 	@��	@D�ŀ ƀ� � B� �@�ŀ ��� � A �@��@ ˀ�@� �@��@ ���A� �� �  �@�� F ܀ �@    � � �@F A� �� ��   ��K��A \��Z  ���� ��G ����AH ��A�  @�KAF �� � \�   � �  @�KAF �	 B	 \�   � �  @�KAF ��	 �	 \�   � �  @�KAF �
 B
 \�   � �  @�KAF ��
 �
 \�   � �  ��KK Ł �A�A� ��\�    � �E� � \���B�ł ���A� � U��܂��  �	�   	�C�� �L���  ��CF �C ��� ���   ���  ��  @�C��  N@�C�  ��CF �C �C�� ���   ���  ��  a�  @�   �EA  K����  B \A K�N \� ZA    � �   @�E� � �  B \A  �E� �A �  � \A  � ?      close    led    set    yellow    flash    device    /dev/ttyS1    logf    LG_DBG    Opening scanner on device %s    sys    open    rw    LG_WRN %   Could not open scanner device %s: %s    fd    scanbuf        set_noncanonical    set_baudrate      ��@   evq    fd_add 	   register    switch_to_programming_mode    cmd    #99900301;    Query the hardware version    match    {(.+);    config    lookup    /dev/scanner/version    setraw    #99900030;     All settings to factory default    #99904020;    Disable User Prefix    #99904111;    Enable Stop Suffix )   #99904112;#99900000;#99900015;#99900020;    Program Stop Suffix 0x0d    #99904041;    Allow Code ID Prefix    activate_scanning_mode    get    /dev/scanner/1d_scanning_mode    ipairs    enable_disable_HR100    name    /dev/scanner/enable-disable/    false    off    #    ;    disable scanning code     true    on    enabling scanning code     switch_to_normal_mode    LG_INF 1   Successfully detected and configured 1D scanner. =   Errors during scanner configuration: Scanner might not work.     �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                     scanner     �      fd    �      err    �      data <   �      good <   �      version A   J      (for generator)    �      (for state)    �      (for control)    �      _ �   �      code �   �      id �   �      node �   �         lgid    on_fd_scanner     
        F @ Z   @�K@@ \@ E�  K�� � @ \@�E�  K � �     @  \@�E@ F�� � @ �   \@�E@ F�� � @ \@ 	 B� � 	      fd    disable    evq    fd_del    unregister    sys    set_noncanonical    close                                                                   scanner              on_fd_scanner       "       K @ \� Z    �K@@ ŀ  ���A � �\@  K@A \@ E� K�� �  A \@  � 
      switch_to_programming_mode    activate_scanning_mode    config    get    /dev/scanner/1d_scanning_mode    switch_to_normal_mode    led    set    yellow    on                                               "        scanner                )  1       K @ \� Z   @�K@@ ��  \@�K�@ \@ E  K@� �� � \@  �       switch_to_programming_mode    activate_scanning_mode    Off    switch_to_normal_mode    led    set    yellow    off        *  *  *  *  ,  ,  ,  -  -  /  /  /  /  /  1        scanner                3  5        �            5        scanner            name            on_off            wait_for_ack                 7  9           @@ ��       �       Scanner_2d    is_available        8  8  8  8  8  9              B  g    0   
  	@@�	@@�	 ��	���E  	@��D   	@��D � 	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��K@B \@ E  K@� �� � d      �  \@ E  K@� �� $A      @  \@�   �       fd     device    scanbuf        type    1d    enable_disable    enable_disable_HR100    open    close    enable    disable    cmd    flush    read    activate_scanning_mode    switch_to_programming_mode    switch_to_normal_mode    barcode_on_off    config 
   add_watch    /dev/scanner    set    evq 	   register    reinit_scanner        b  b           @ @  �       open        b  b  b  b            scanner     c  c           @ @  �       open        c  c  c  c            scanner 0   D  G  H  I  J  K  K  N  N  O  O  P  P  Q  Q  S  S  T  T  W  W  Y  Y  Z  Z  [  [  ]  ]  `  `  b  b  b  b  b  b  b  b  c  c  c  c  c  c  c  e  g        scanner    /         open    close    enable    disable    cmd    flush    read    activate_scanning_mode    switch_to_programming_mode    switch_to_normal_mode    barcode_on_off ,                     :   :   K   K   ^   ^   q   q   }   }   �   �   �   �             "  1  5  9  7  g  g  g  g  g  g  g  g  g  g  g  g  B  g        lgid    +      on_fd_scanner    +      flush 
   +      read    +      cmd    +      switch_to_programming_mode    +      switch_to_normal_mode    +      activate_scanning_mode    +      open    +      close    +      enable    +      disable    +      barcode_on_off    +       