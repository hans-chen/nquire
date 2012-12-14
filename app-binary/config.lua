LuaQ     @config.lua           /      A@  ��  ��@@�  A@ @   A� @ � d     �     �@      �      $�      d �A     �     $�     d     �B � $�   �         �  �  �     �            �  � 	      module    Config    package    seeall    require    config_node 
   typecheck    config    new           ^    F   �@ �       �� ��@      �����         �� ���  �  A� ��  AA� ���  �A� ������� �����@  $�  � �A @ ��A�� @� � A  ���� � � AB ��C ���A �� �   �A�� � �� �A  ��� E �� �B �C @�B $    @ ��� � A� �B \B��  �       group    object    include    string    find    sub    match 	   tonumber    __index    setmetatable 	   loadfile    logf    LG_FTL "   Could not load schema from %s: %s    fname_schema    setfenv    pcall    Error loading schema %q: %s    prio    mode               
   E   F@� �   �   \����  �   � � ���� @ �A���  ��^   �       Config_node    new    ipairs 
   add_child                                                              def           node          (for generator)          (for state)          (for control)          i 	         c 	            config     "   &    	   E   F@� �   �   \����� I� �^   �       Config_node    new    value    default     	   #   #   #   #   #   $   $   %   &         def           node             config     *   ,       D   � � �   ] �^    �            +   +   +   +   +   ,         fname              load_schema    config     :   <        �   �@   � A�  �@��  �@� �       error    Unknown keyword '    '        @       ;   ;   ;   ;   ;   ;   ;   <         _           key                Q   X       � @ � ���A  �� � �Ƃ��B    �Ƃ I���   ��  �� � �A��@  �� �       each_child    pairs        R   R   R   S   S   S   S   T   T   T   T   T   S   T   V   V   V   V   R   V   X         node           keys           (for generator)          (for state)          (for control)          child          (for generator)          (for state)          (for control)          _          key             inherit F               &   &   &   ,   ,   ,   ,   0   1   1   1   2   2   2   3   3   3   4   6   6   9   <   <   ?   ?   ?   ?   C   C   C   D   D   E   E   E   E   E   E   E   H   H   H   H   J   J   J   K   K   L   L   L   L   L   L   L   X   X   Z   Z   Z   Z   Z   Z   Z   \   ^   	      config     E      fname     E      env    E   	   env_meta    E      chunk "   E      err "   E      ok 2   E      db 2   E      inherit =   E         load_schema    lgid     j   �    +     A@@� ��  ��A  @ �� � �  ��   D  �B �B�  ��� �A���A�@��B KCB�� � \� � ܂ �    ��� �A  ����B�A � �A� � ܁ ��	 ��  �       io    open    r    logf    LG_INF    Loading config %s        lines    set_config_item    gsub    $    close    sys    lstat    mtime     +   l   l   l   l   l   m   m   n   n   q   s   s   s   s   s   s   s   s   t   t   t   u   u   u   u   u   u   u   u   u   v   t   w   z   z   |   |   |   |   }   }      �         config     *   	   fname_db     *      nowatch     *      comment     *      fd    *      err    *      changed 
   *      (for generator)    !      (for state)    !      (for control)    !      l          s '   *         lgid     �   �    w   �   � �A  ��    ��  Z   ���  � �� ��  ��� A  ���A � D  �� �� �A��   ��B @ ܁��  @�B��B@���  ���� C �B�W@C@�B�W�C��B�W�C� �B�W D  �B  � C��B ��  ���@ Z  �	����B�@�@�ł  �A� ܂�������AC �C ܂ ��@���A� �� ܂ ��������� ���A� � ܂ ���B�@ � � ܂��  ��� �  ��B ł   A� � �B�@�B E� �  ��   B�@  @��   �       match    ^#            [;%s]*(%S+)%s*=%s*(.*)        logf    LG_WRN    Could not read line '%s'    lookup    type    enum    config_type    number    string 	   password    pattern    custom    fetch_value    escapes_to_binstr    "    sub       �?      �       @       �   set !   Could not read value for node %s    Unrecognized node %s     w   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         config     v      l     v      nowatch     v      changed    v      fid    t      rest    t      next_tv    t      node    s   
   is_string 6   l      value 7   l      vvalue @   e         lgid     �      j   �      W � ���@@ �  � ��  A@��A ��A  ���� ��   A �B�  ��B �B�  ��B �A  � � � �B A� �A �CB �A��C� �A��CB �A���C�A � �AD��B@ ����D@��� ��   A� �A  ��� �   AB �A ŀ � D  �� �F �@��  �@�� FF A�@ �  �@�� FA@ � �F ��@ �  �@�A FF A�@ �  �@�� FF A�@ �� � �F ܀ �   � �A�	 ��� � �H�� 	 �� � #   	   fname_db    .tmp    io    open    w    logf    LG_WRN $   Could not write to config db %s: %s    nil    db        write    
    # End
    close    os    rename  %   Error saving configuration database.    LG_INF    Saved configuration database.    LG_DBG *   Duplicating configuration database to %s.    fname_db_ext    execute    rm -f     cp -a          chown ftp.ftp     chmod 664     sys    lstat    mtime    time        �   �    W   � � ܀ �   @��@� ܀ �   @�ˀ@A�  � ܀ A� W�A��A� �A� �� @B �A� W�B@�A� W�B� �A�  C��AC ���� �� A �B Ƃ� � A �C ����� ��A� �AC ���� �� A� ��� � ��A��@� ܀ �   ���@C A� ��� �A    �� � U���@��@� � @�� BF�   � �  A� ��CՁ  @  � ��B �@  �� �       is_persistent 	   has_data    gsub    ^%.        type    string    enum    config_type    number 	   password    pattern    custom    write    /    id     = "    binstr_to_escapes    value       @@      p@   "    "
     =     
    has_children    
#     label    

    each_child     W   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   	      fd     V      node     V      prefix     V      prefix2    6      (for generator) E   V      (for state) E   V      (for control) E   V      node_child F   T   
   newprefix G   T         s j   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �                                         config     i   	   dup_only     i      s    i   
   fname_tmp    <      fd    <      err    <      s `   i         lgid              � @ �@@ � � ��    �       db    lookup                          config           fid                         � @  � ����   � ��@@�  �   ��ŀ  �  D  � �� �@��@ �   �       lookup    get    logf    LG_WRN    Trying to get unknown node %q                                                       config           fid           node             lgid     '  /   
   @ �� ��  @�KA@�  �] ^  ��E�  ��  �   @� \A�B  ^  �       lookup    set    logf    LG_WRN    Trying to set unknown node %q        (  (  (  )  )  *  *  *  *  *  *  ,  ,  ,  ,  ,  ,  -  -  /        config           fid           value           now           node             lgid     6  >      K@ �� \��Z  ���A�  @�� ���  ����  ��    A �� �A��  �  �       lookup 
   add_watch    logf    LG_WRN #   Trying to register unknown node %q        7  7  7  8  8  9  9  9  9  9  9  9  ;  ;  ;  ;  ;  ;  <  <  >        config           fid           action           fn           fndata           node             lgid     E  T      d     � �   �@    A�  �@ � � ��@ �@ � A �@  �       logf    LG_INF    Restoring factory defaults    db    save_db        G  O      F @ Z   � �K@@ � @ \@���K�@ \ � �D  � \A a@  �� �       default    set    each_child        H  H  H  I  I  I  I  K  K  K  L  L  L  K  L  O        node           (for generator) 	         (for state) 	         (for control) 	         child 
            setdef    O  O  Q  Q  Q  Q  Q  R  R  R  S  S  T        config           setdef             lgid     [  n       �   �@@ƀ� �� �@  � ���� B� �@�@�� A� W �@��@� F�� � �� ܀�W��� ���� B� �@�� � �   �       sys    lstat    fname_db_ext    save_db    mtime    load_db 	   from ftp        _  _  _  _  a  a  b  b  b  b  c  c  c  c  g  g  g  g  g  g  g  h  h  h  m  m  n        event           config           s               q  z       E   F@� ��  ��  \��Z   ��� � �� �@� �@ ˀA @ �@�� ���A � �@� �       io    open    /sys/block/mmcblk0/device/name    r    read    close    setraw            r  r  r  r  r  s  s  t  t  u  u  v  v  v  v  x  x  x  z        node           fd          data 	              �  �   
7   �@ 
  � �� ���@ �ɀ��  � �� � �� � ��� �� � ��� �� � ��� �� � ���  ��� �A �C�� �� �A�A D�� ��B A���� �A $    @�A ��� �� �C�A �   �       db    fname_schema 	   fname_db    fname_db_ext    load_schema    load_db    save_db    set_config_item    lookup    set    get    restore_defaults 
   add_watch    evq 	   register    config_timer    push       �?   //    /dev/mmcblk        �  �      �   �@    A�  �@ ��� �@  �       logf    LG_DBG *   Node '//' change ==> saving configuration    save_db        �  �  �  �  �  �  �  �        node           config              lgid 7   �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        fname_schema     6   	   fname_db     6      fname_db_extern     6      config    6         load_schema    load_db    save_db    set_config_item    lookup    set    get    restore_defaults 
   add_watch    on_config_timer    lgid    get_mmcblk /                                       ^   ^   ^   �   �   �   �               /  /  >  >  T  T  n  z  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �        lgid    .      load_schema    .      load_db    .      set_config_item    .      save_db    .      lookup    .      get    .      set    .   
   add_watch    .      restore_defaults    .      on_config_timer    .      get_mmcblk     .       