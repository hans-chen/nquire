LuaQ     @beeper.lua                 A@    ΐ@@  d       €@      δ  $Α  d            GA         module    Beeper    package    seeall    beeper    new                   E   K@ΐ Α  \ΐ  Ε    AA  @  Bΐ  ΐ Ηΐ 	 A @  ΐ  Ε@   A  ΕΑ @         config    get    /dev/beeper/device    logf    LG_DBG    Opening beeper on device %s    beepthread    err    new    LG_WRN    Can't open beeper %s: %s                                                                                                beeper           device             lgid     )   O    _    @ @      @  Α  Α  A A AΒ BΕA  D  Β ΐ άAΕ ΖAΓ  A άΓ ΐ    C     Δ  CDΕ ΖΔΔ @ άΪ    Ε  ΜCΕΕ  ΝCΕΔ FAD ΖB	F@ KΗΐ E
@ \DG@@ GD  ΟDΟ	D ΐG Ϋ@   Α  @H [A   A H A   Α  I  Ν@Ε@I  Μ@Εα ξ  &      beepthread                @       @      ^@   config    get    /dev/beeper/volume       @   logf    LG_DMP    Playing %s    string    gmatch $   ([cdefgabpotdl><])([#-]?)(%d*)(%.?) 	   tonumber    .       ψ?   find    c d ef g a b    #       π?   -    math    pow cyΩσπ?      (@     [@   beep       n@   p    o       @   t    l       0@   <    >     _   +   +   +   ,   /   0   1   2   3   3   3   3   3   5   5   5   5   5   5   7   7   7   7   7   7   9   9   9   9   :   :   :   ;   ;   ;   =   =   =   =   =   >   >   ?   ?   ?   @   @   @   A   A   A   A   A   A   A   A   B   B   B   B   B   B   B   E   E   F   F   F   F   F   F   I   I   I   I   I   J   J   J   J   J   K   K   K   K   K   L   L   L   M   M   M   7   M   O         beeper     ^      song     ^      note    ^      oct    ^      deflen    ^      tempo    ^      volume    ^      (for generator)    ^      (for state)    ^      (for control)    ^      char    \      mod    \      num    \      dot    \      len     \      note (   \      freq 8   ?         lgid     T   Z           @@  Wΐ@@ Z   ΐ   @@ @    @ Ε   Λ@ΐA  UάΑA A        config    get    /cit/disable_scan_beep    false    /dev/beeper/beeptype    1    /dev/beeper/tune_    play        U   U   U   U   U   U   U   U   V   V   V   V   V   V   V   W   W   W   W   W   W   X   X   X   Z         beeper           always           tune_nr          tune               a   d        E   K@ΐ Α  \ΐ@   A@  @          config    get    /dev/beeper/tune_error    play        b   b   b   b   c   c   c   c   c   c   d         beeper     
      tune    
           m           
@ 	@@D   	@ D  	@D  	@ D 	@K@ \@ E KΐΑ Α  A d    \@     
      beepthread     init    play    beep_ok    beep_error    config 
   add_watch    /dev/beeper/device    set        ~        	    ΐ      ΐ @@@ ΐ @         beepthread    free    init     	                                    node           beeper               o   r   u   u   v   v   w   w   x   x   {   {   }   }   }   }         }               beeper 
            init    play    beep_ok    beep_error                              O   O   Z   d                  m            lgid          init          play 
         beep_ok          beep_error           