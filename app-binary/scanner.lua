LuaQ     @scanner.lua           K     J �
�@ ��@��@A��@A��@���@B�ʀ ɀB���B�� C�� Ã�@C���C�
A 	D�	AD�	�D�	�ă	�D�J� IE�IAE�IAD�IAăI�E�I�E��A �F��AF���F���ƃ��F�ʁ �G��AG��AF��AƃɁG���G�
B 	H�	BH�	BH�	�ȃ	�H�JB I�H�II�II�IɃIBI��B ��I���I���I���Ƀ�J��B �BJ�ɂH�ɂJ�ɂʃ�BF�
� 	�J�	K�	CK�	˃	K�	�K�J� IL�ICL�ICK�IC̃ICL�I�K��� ��L���L��CK���̃��L���K�ʃ �M��C��CK��Ã�C���K�
� 	DM�	�F�	DK�	�ƃ	�F�	�K�JD I�M�I�M�I�M�I�̓I�M��D �N��DN��DN��D΃�DN��D ɄN���N���L���̃�O�
E 	EO�	�O�	�O�	�σ	�O�JE I�O�IEH�IP�IЃIP��E �EP���P���P���Ѓ��P��E ��P��Q��EQ��Eу�Q�
F 	�Q�	�Q�	FL�	F̃	R�JF IFR�I�R�I�H�IF̃IR���  ��R��S�b@�G@  J ���  ��@���S���  ɀB���S��@T�
�  	D�	�S�	�T�J�  IE�I�S�I�T���  �F���S��U���  �G���S��AU�
 	H�	�S�	�U�	�էJ IBO�I�S�IV�IB֧��  ��H���S���V���  ɂI���S���V�
�  	CJ�	�S�	W�J�  IN�IT�ICק� ��N���S���W���ק� ��O��T��X��Cا
 	DP�	�S�	�X�	�اJ I�P�I�S�IY�ID٧� ��Q���S���Y���٧� �DR���S��Z��Dڧb@ 	G@ J ���  ��@���S���  ɀB���S���Z�
�  	D�	�S�	[�J�  IE�I�S�IA[���  �F���S���[���  �G���S���[�
�  	H�	�S�	\�J�  I�O�IT�IBܧ��  ��H���S���\���  ɂI���S���\�
 	CJ�	T�	]�	CݧJ�  I�J�I�S�I�]�� �L���S���]��ާ��  ɃL���S��C^�
 	M�	�S�	�^�	�ާJ�  IDM�I�S�I_��D ��M���S��D_���ߧ���D ɄN���S��D`�Ʉ���b@ 	G� d   G�  d@  G ! d�  G@! d�  G�!  � �      scanner 	   prefixes    name    Code128 
   prefix_2d    j 
   prefix_1d    prefix_hid    prefix_out    #    UCC_EAN-128    J    u    P 
   cmd_HR200    0004030    EAN-8    d    g    FF    EAN-13    D    F    0004050    UPC-E    c    h    E    UPC-A    C    A    0004070    Interleaved-2_of_5    e    i    Code39    b    *    Codabar    a    %    Code93    y    PDF417    r    ?    layout    2D    QR_Code    s    Aztec    z    DataMatrix    Chinese-Sensible    GS1_Databar    R    ISBN    B    Code-11    H    Z    2_5-Matrix    v    ITF14    q    MSI-Plessey    m    Plessey    n    p    2_5-Standard    f    o    2_5-Industrial    I    mifare    MF    enable_disable_HR100    default    on    off 	   99910101 	   99910401 	   99910501 	   99911001 	   99911101 	   99911201 	   99911202 	   99912001 	   99912002 	   99912401 	   99912501 	   99912601 	   99910702 	   99912701 	   99912702 	   99911401 	   99911403 	   99913101 	   99913102 	   99913001 	   99913002 	   99912201 	   99912202 	   99912101 	   99912102    enable_disable_HR200    0412010    0401010    0402010    0403010    0404010    0405010    0405090    0408010    0409010    0410010    0410020    0501010    0502010    0502020    0503010    0504010    0504020    0508010    0413010    0413020    firmware_min 	   3.06.004    0415010    0415020    find_by_name    is_2d_code    find_prefix_def    does_firmware_support        m   t        �   �   � � ��A@@�  �� ��  @��  �   �       ipairs    name        n   n   n   n   o   o   o   p   n   q   s   s   t         table           name           (for generator)    
      (for state)    
      (for control)    
      _          rec               w   ~        E   �@  \ �����   �����   ����W A  ��A  �� � a�  @�B   ^   �       ipairs 	   prefixes    name    layout    2D        x   x   x   x   y   y   y   z   z   z   z   z   z   z   z   z   x   {   }   }   ~         name           (for generator)          (for state)          (for control)          _          record               �   �        E   �@  �   ] �^    �       find_by_name 	   prefixes        �   �   �   �   �   �         name                �   �     -   F @ Z   �	�E@  F�� � @ ��  \ �Z   ���   @��   ��A  �@E KA��� \���� �  @�Z  ���  @�X@ @�@ @ �X��@�@ @���� �� @ ��  � B � ^   �       firmware_min    string    match    (%d+).(%d+).(%d+)    config    get    /dev/scanner/version    fw:(%d+).(%d+).(%d+)     -   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �         code     ,   
   major_req    *   
   minor_req    *      nn_req    *      major    *      minor    *      nn    *       K             !   !   !   !   !   !   "   "   "   "   "   "   "   #   #   #   #   #   #   $   $   $   $   $   $   $   %   %   %   %   %   %   &   &   &   &   &   &   &   '   '   '   '   '   '   (   (   (   (   (   (   )   )   )   )   )   )   *   *   *   *   *   *   +   +   +   +   +   +   +   ,   ,   ,   ,   ,   ,   ,   -   -   -   -   -   -   -   .   .   .   .   .   .   .   /   /   /   /   /   /   /   0   0   0   0   0   0   1   1   1   1   1   1   2   2   2   2   2   2   3   3   3   3   3   3   4   4   4   4   4   4   5   5   5   5   5   5   6   6   6   6   6   6   7   7   7   7   7   7   8   8   8   8   8   8   :   :   ;   ;   B   B   C   C   C   D   D   D   D   E   E   E   E   F   F   F   F   G   G   G   G   H   H   H   H   I   I   I   I   I   J   J   J   J   J   K   K   K   K   L   L   L   L   M   M   M   M   N   N   N   N   O   O   O   O   O   P   P   P   P   P   Q   Q   Q   Q   Q   R   R   R   R   R   S   S   S   S   S   T   T   T   T   U   U   X   X   Y   Y   Y   Z   Z   Z   Z   [   [   [   [   \   \   \   \   ]   ]   ]   ]   ^   ^   ^   ^   _   _   _   _   `   `   `   `   a   a   a   a   b   b   b   b   c   c   c   c   c   d   d   d   d   e   e   e   e   e   f   f   f   f   g   g   g   g   g   h   h   h   h   i   i   i   i   i   i   j   j   j   j   j   k   k   t   m   ~   w   �   �   �   �   �         lgid    J      