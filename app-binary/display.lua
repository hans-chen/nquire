LuaQ     @display.lua           <      A@  ��  ��@@�  d       �@  �      $�      d     �A �     $�     d �  �B        $�   �    d�   �� �C $� d� �     �D $� d�   �            �  �  �     �     �     �     �   	  �	       
GE  �       module    Display    package    seeall    display    new           T    X   E   K@� ��  \����  �  �@ �  ��A��� 	������  � �FAA KA��  �W�B  �BB  B� \��ZA  @���  D  �B � �A�� 
�  	ć	�Ĉ��
�  	Ň	�Ĉ���
�  	Ň	�Ĉ���
�  	�Ň	ƈ��
�  	�Ň	�ƈ���
�  	Ǉ	Bǈ���
�  	�Ǉ	Ȉ��
�  	�ȇ	�Ȉ���B�  ��E	 � \  �	@a�   �	���	� �K�I �
 �C \B KBJ ��
 \B�K�J � \B�^  � -      config    get    /dev/display/mode    require    dpydrv    drv    new    match    (%d+)x(%d+)(.)    open    c    logf    LG_FTL    Could not open display: %s    128x64m    native_font_size       (@   virtkbd_size  	   240x128m        @	   320x160c 	   480x800c       2@      @@	   800x480c      �F@	   800x600c       4@      I@
   1024x768c       9@      P@   1280x1024c       >@      T@   pairs    w    h 	   set_font 
   arial.ttf 
   set_color    white    set_background_color    black     X                                                                                                    !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?   @   C   D   D   E   E   E   E   F   E   F   J   K   M   M   M   M   P   P   P   Q   Q   Q   S   T         display     W      mode    W      w    W      h    W      c    W      update_freq    W      err    W      dpyinfo @   W      i A   W      (for generator) F   J      (for state) F   J      (for control) F   J      k G   H      v G   H         lgid     [   _        F @ Z   � �F @ K@� \@  �       drv    close        \   \   \   ]   ]   ]   _         display                h   q       Z@  @�  EA  �  ��  A  � �@ A�� �  ���A  @��  �A    AB ���A� �       logf    LG_WRN    No image fname given    drv    draw_image    draw_image: %s        i   i   j   j   j   j   j   k   m   m   m   m   m   m   n   n   o   o   o   o   o   o   q         display           fname           xpos           ypos           ok          err             lgid     t   }       Z@  @�  EA  �  ��  A  � �@ A�� �  ���A  @��  �A    AB ���A� �       logf    LG_WRN    No image fname given    drv    draw_video    draw_video: %s        u   u   v   v   v   v   v   w   y   y   y   y   y   y   z   z   {   {   {   {   {   {   }         display           fname           w           h           ok          err             lgid     �   �    	   � @ �@@ @� �� �@  @��  E�  �  �  �A� �       drv    draw_image    logf    LG_WRN    draw_image: %s        �   �   �   �   �   �   �   �   �   �   �   �   �   �         display           blob           ok          err             lgid     �   �        � @ �@�@� � �@  �       drv    gotoxy        �   �   �   �   �   �         display           x           y                �   �    &     EA  ��  ��  B�   � [B   �AB A A�   ��A 	 �A   ��A 	 ��A�  �B 	 �AB �B��A ��A B ��A  @��  ��   A ���A� �       logf    LG_DMP    display    set_font( family=%s, size=%d )    nil            font_family 
   font_size 
   font_attr    drv 	   set_font    LG_WRN    set_font: %s     &   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         display     %      family     %      size     %      attr     %      ok    %      err    %         lgid     �   �       
  e  "A    � �
  e  "A  � �   �� � A@ �@��A��  E �  �B  �@ ���  �B�  @�� ��� �               drv 
   draw_text    logf    LG_DMP    txt='%s':w=%d,h=%d,x=%d,y=%d         �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         display           fmt           arg           buf           w          h          x          y             lgid     �   �       
  e  "A    � �
  e  "A  � �   �� � A@ �@���� � � ���� �               drv 
   draw_text        �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         display           fmt           arg           buf           w          h               �      x      ��Z   @��   � ��    � @ �  �   � � ����@@ A�  � ��    �  ��Z   ��  �  �� �  � �  ����A������  � �   ���A�����  � �  ����A�����@�� �AB�� �  ����  �	���B����C AC �  ܂ C@�� ��� ��  ��Z  @��  ���  
  � �  ��DA����  ��D����  ��DA���@ ��A  @��D�A �   � ��   ���   � ����   �AD  F�F���  @��@ � D� �� �    � �@  � ��   �        match    #(%x%x)(%x%x)(%x%x)    r    0x       p@   g    b    io    open    /etc/X11/rgb.txt    lines    gsub    .    (%d+)%s+(%d+)%s+(%d+)%s+    $    close    logf    LG_WRN    Color %s not found 	   tostring        �   �        A   �@  ��@�   �� �@  ���   ܀  U � ^   �       [    string    lower    upper    ]        �   �   �   �   �   �   �   �   �   �   �   �   �         c            x   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �           v1     w      v2     w      v3     w      r    ^      g    ^      b    ^      fd 5   ^      (for generator) 9   \      (for state) 9   \      (for control) 9   \      l :   Z      name >   Z      r D   Z      g D   Z      b D   Z         colorcache    lgid               @� � ���  B  D� ��  �B   ���  C�  ��  [C   �A�  �A�W A@��AA ˁ�@ ��� �A� �       logf    LG_DMP    r=%d, g=%d, b=%d       �    drv 
   set_color                                              	  	  
  
  
  
  
  
          display           v1           v2           v3           r          g          b             get_rgb    lgid               @� � ��W @@��A@ ˁ�@ ��� �A� �        drv    set_background_color                                          display           v1           v2           v3           r          g          b             get_rgb           	   @ A@�� �  �A� �       drv 	   draw_box                            display           w           h           r                   "    	   @ A@�� �  �A� �       drv    draw_filled_box        !  !  !  !  !  !  "        display           w           h           r                (  +    	   E   �@  ��  �  \@ F A K@� \@  �       logf    LG_DMP    display    clear()    drv    clear     	   )  )  )  )  )  *  *  *  +        display                2  4       � @ �@@ � �@� �       drv    update        3  3  3  3  4        display           force                9  b   q   �  B  D  ��  �  �@ ���C   ���@ �A��   �	����A �A�F�@ �A�ˁAA� �� ܁  �ˁ�A� �� ܁ @��  A � �B Ƃ� � A� ܂��E ��\@��DC  ��Ā��A	�C� ��C D
OD	�@
@D@ ��C ��
�����D D
N�O�
E
M�ANń
�@
 �@��D N�E
M�ANń
�@
  EE  �  �E   @�E �E � ��E �
��E  ��E���@ @�   �  �� 
BW  �W��� �W �  ��@�a�  ��@�� ��  ^� �       logf    LG_DBG A   format_text( xpos=%d, ypos=%d, align_h=%s, align_v=%s, size=%d ) 
   font_size    drv    set_font_size    sub       �?           string    split    
    pairs    get_text_size    c    w        @   r    m    h    b    gotoxy(%d,%d)    gotoxy 
   draw_text     q   ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  ;  <  <  =  >  >  >  >  A  A  A  A  A  B  B  B  B  B  E  F  G  H  I  I  I  I  I  J  K  K  K  K  M  M  M  P  R  R  R  R  R  R  S  S  S  S  T  T  T  T  T  T  T  T  T  T  U  U  U  U  U  U  U  U  W  W  W  W  W  W  W  X  X  X  X  Y  Z  Z  Z  Z  Z  Z  Z  [  [  [  \  ^  ^  ^  ^  ^  ^  ^  K  ^  a  a  a  a  a  b        display     p      text     p      xpos     p      ypos     p      align_h     p      align_v     p      size     p      w    p      h    p      x     p      y !   p      ll &   p      n '   p      (for generator) *   k      (for state) *   k      (for control) *   k      i +   i      l +   i      text_w .   i      text_h .   i      lw W   i      lh W   i         lgid     i  �    J   �@ AB  �B  �A ˁ@ �A ��  Z    �A �� �B   �AC �� B��A ���    �A � �B   �AC �� B��A ���    �A ���B   �AC �� B��A ��   �A � �B   �AC �� B��A ��Z   �A ���B   �AC �� B��A ���   �A � �B   �AC �� B��A �� �       gotoxy            clear       $@   format_text    c     
   font_size     J   j  j  j  j  k  k  l  m  m  n  n  n  n  n  n  n  o  o  q  q  r  r  r  r  r  r  r  s  s  u  u  v  v  v  v  v  v  v  w  w  y  y  z  z  z  z  z  z  z  {  {  }  }  ~  ~  ~  ~  ~  ~  ~      �  �  �  �  �  �  �  �  �  �  �  �        display     I      msg1     I      msg2     I      msg3     I      msg4     I      msg5     I      msg6     I      y    I           �  �       � � �@ � � �   �       update        �  �  �  �  �        event           display                �  �    N   
� 	@@�	�@�	@A�	�@�	 D   	@��D � 	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��D �	@ �D  	@��K@B \� �� �� �A �� �@��@ ��G� D 	�  �@��@ � H� @  �A���@��� ��H	 AA	 �  �  �@ �@  ŀ ���A�	 �A	 � �@��  �@�    � '      drv     native_size        @   font_family    Sans 
   font_size 
   font_attr        open    close    gotoxy 
   set_color    set_background_color 	   set_font    draw_image    draw_video    draw_image_blob 
   draw_text    get_text_size 	   draw_box    draw_filled_box    clear    update    format_text    show_message    logf    LG_DBG $   Display update frequency is %.1f hz    evq 	   register    display_timer    push       �?   config 
   add_watch    /dev/display/mode    set    /dev/display/contrast        �  �       � � �@ �@� �@  �       close    open        �  �  �  �  �        node           display                �  �     	#      @@ ��  ��E   K@� ��  \���   �@@ ����@ ��  �@��� ŀ ��� AA ����   @�K���  \A�K��\A  �E �A ��   \A  �       config    get    /dev/display/contrast    /dev/display/contrast_min    /dev/display/contrast_max       @   io    open %   /sys/class/display/display0/contrast    w    write    close    logf    LG_WRN +   Could not open display contrast driver: %s     #   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �     	   contrast    "      min    "      max    "      fd    "      err    "       N   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        display (   M      update_freq *   M      set_contrast D   M         open    close    gotoxy 
   set_color    set_background_color 	   set_font    draw_image    draw_video    draw_image_blob 
   draw_text    get_text_size 	   draw_box    draw_filled_box    clear    update    format_text    show_message    lgid    on_display_timer <   	   	   	   	   	      T   T   _   q   q   }   }   �   �   �   �   �   �   �   �   �                     "  +  4  b  b  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        lgid    ;      open    ;      close 	   ;      draw_image    ;      draw_video    ;      draw_image_blob    ;      gotoxy    ;   	   set_font    ;   
   draw_text    ;      get_text_size    ;      colorcache    ;      get_rgb    ;   
   set_color    ;      set_background_color    ;   	   draw_box    ;      draw_filled_box     ;      clear !   ;      update "   ;      format_text $   ;      show_message %   ;      on_display_timer &   ;       