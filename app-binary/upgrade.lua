LuaQ     @upgrade.lua           "      A@    ΐ@@  A@  Κ@ 
A  	ABΙ 
A  	ΑBΙ 
A  	ACΙ 
A  	ΑCΙ 
A  	ADΙ   d              €A             module    Upgrade    package    seeall 
   /home/ftp    /bin/target_unpack_tar.sh      ΐr@   kernel    option    -k    app    -s    rootfs    -r    logo    -l 	   firmware    -f    new                 ³      @@ D   ΐ @     Εΐ   AA   ΐ @          @  Ε  AΑ @     @B Ε    ά #  AΒ Υ  C@ FBCZ   E FBΒ\ CMΒΓ B   Ϊ     Z  @  Γ  @  Ε  A ΐC Γ Ε ΖCΕ @DάΓ Ϊ   KΔΕΑ \ΔΓE @ 	Z    ΖD @E  Δ  Α Ε @ \D 	E   Α  \D J  Δ	G	ΐbD PD  ΕΔ  A DD H	Ε A	 D   Ε  AE	 D   	 ΐ$      D@E  Δ  Α Ε	 @ \D @  ΕΓ   A
 C@@  Ε D
 @C JΐΓ C  @  EΔ  Δ
 ΐ D£  α  ΫΒ  ή    ,      sys    readdir    logf    LG_WRN    upgrade     Could not read directory %s: %s    LG_INF    Upgrade in progress    os    time    ipairs    /    lstat    isreg    mtime    match !   .+/(.-)%-(.-)%-(.-)%-(.-)%.image       @)   Found %s image file %s, veryfing md5 sum        io    popen    md5sum     read    *a    (%S+)    close     Could not calculate md5 sum: %s 1   MD5 sum verified and correct, initiating upgrade     /bin/target_unpack_tar.sh %s %s    option    LG_DBG    Running command %q    cit    show_message 
   Upgrading 	   firmware    Starting upgrade    runbg .   Checksum mismatch (%s != %s), can not upgrade &   Unknown component %q, can not upgrade @   Found stale file %s which is older then %d seconds, cleaning up    remove    Could not erase %s: %s        a   n    %    @ E@  Fΐ ΐ  \@ E  F@Α  \@ Eΐ   Α@  \@ Eΐ K Γ Α@  \@ E@  FΐΓ    \@ E@  Fΐ   \@  Eΐ @ Α@  \@ B   H                  os    execute    sync    sys    sleep        @   logf    LG_INF    upgrade    Upgrade successfull    cit    show_message    Upgrade ok 
   rebooting    remove    reboot    LG_WRN    Upgrade failed     %   b   b   c   c   c   c   d   d   d   d   e   e   e   e   e   f   f   f   f   f   g   g   g   g   h   h   h   h   h   j   j   j   j   j   m   m   n         rv     $         file    upgrade_busy ³   "   "   "   "   #   #   $   $   $   $   $   $   $   %   %   (   (   (   )   )   )   )   )   *   -   -   -   /   /   /   /   1   1   1   1   5   5   5   5   7   7   7   ;   ;   ;   ;   ;   ?   ?   ?   A   A   A   A   A   A   A   A   A   A   C   C   C   C   E   E   E   E   E   E   E   I   J   J   J   J   J   J   K   K   L   L   L   M   M   M   M   N   N   N   O   O   O   Q   Q   Q   Q   Q   Q   V   V   W   W   W   W   W   Y   Y   Y   Y   Y   Y   Y   Z   Z   Z   Z   Z   Z   \   \   \   \   \   ]   ]   ]   ]   ]   _   _   a   a   n   n   n   a   n   q   q   q   q   q   q   q   r   u   u   u   u   u   u   z   z   z   {   {   {   {   {   {   |   |   |   |   }   }   ~   ~   ~   ~   ~   ~      /                     files    ²      err    ²      now    ²      (for generator)    °      (for state)    °      (for control)    °      _    ­      file    ­      stat '   ­      age /   ­      product 2   ­   
   component 2   ­      version 2   ­      md5sum 2   ­      real_md5sum H         fd N         err N         tmp S   \      cmd q         ok ₯   ­      err ₯   ­         path_upgrade_dir    upgrade_busy    component_list    max_age_cleanup                  @@  D  @    ΐ@  C @        evq 	   register    upgrade_timer    push       $@                                                 device        	   baudrate              on_upgrade_timer "                                                                                                               path_upgrade_dir    !      path_upgrade_script    !      max_age_cleanup    !      component_list    !      upgrade_busy    !      on_upgrade_timer    !       