LuaQ     @webserver.lua                 A@  ��  ��@@�$   d@      ��    � ��     $    dA �� � �� �A �   �  �   ��  �       module 
   Webserver    package    seeall    url_decode    url_encode    new 	       "   �        E  �A  ��  �  FA �B�   ��B �B   ��B \A�J�  IA ��  I����  I����  ���  �����  ����� �A�  A� ���I���I�  ��E FB�� �� $    �\B E  �� ��   @�� \B KB��� \� �KCC�� \À���Ƀ�aB   �E KB��� \����@�IAG�F��F��Z  @�E FB������G�� \��Z  @�� �BH���� �BC� � CF�� ��  � CF�	 �� �� �IAI�  �IAI��� ��KJ�B
 ���J\� IA��KJ���Ƃ��B�\�� �F�Z  ��E�
 ��@ �K\�
�����CK������  @	�	�K��  	���  	����� ���   @����À�  ���Ä́� �MFL � ���DL ����AED F���� �D ��	܄� �K ��	\��	D� ��Aτ� @�D���a�  @�FBBZB   ���τF��PB��A��� ��AЄF�AI�P��хF�A��A�BQ�B  @ ���B� I��F�A��A��Q�B    ��� I��F�A��A�R�B  @ �����RI��F�A��A�R�B    ��B I��J  ��
 ��A������C� �A� � �� �I���  @����BJI�R�� ��M���� �S AC �CB�� UÃ�B��S @ �B��S F�B�B���A��@���˂S �B �  � A�  �� �B   � P      logf    LG_DMP 
   webserver 8   handle_request(client.address=%s, method='%s',uri='%s')    address    nil    method    header    param    result     data    string    match    ([^%?]+)%??(.*)    path    query    gsub    ([^&=]+)=([^&;]*)[&;]?    LG_DBG    path=%s, query=%s    gmatch 	   ([^
]+)    (%S+): (.+)    config    get    /dev/auth/enable    true    auth_ok     Authorization    Basic (.+)    base64    decode 
   (.-):(.+)    /dev/auth/username    /dev/auth/password    POST 
   post_data    sub       �?   Content-Length    pairs    handler_list    find    cache_time     `U}�
   resp_data    resp_header 	   safecall    fn    fndata    200 OK    table    concat    Expires    os    date    %a, %d %b %Y %H:%M:%S GMT    time 
   500 Error E   <h1>Error</h1>
An error occured while handling the request:<br><pre>    404 Not found F   <h1>Not found</h1>
The requested URL %s was not found on this server.    401 Authorization Required    WWW-Authenticate "   Basic realm="Please authenticate" !   <h1>Authorization required</h1>
    Content-length    Content-Type    text/html; charset=iso-8859-1    Connection    Close    :     
    send 
   HTTP/1.1     close    Client closed, no keepalive        9   ;    
   �   � @�@     ܀ A  @� � � � �       param    url_decode     
   :   :   :   :   :   :   :   :   :   ;         name     	      attr     	         request    $   $   $   $   $   $   $   $   $   $   $   $   &   '   (   (   )   )   ,   -   .   .   /   /   4   4   4   4   4   5   6   7   7   8   8   8   8   ;   ;   8   ?   ?   ?   ?   ?   ?   ?   C   C   C   C   D   D   D   E   E   C   E   H   H   H   H   H   H   I   J   J   J   J   K   K   K   K   K   K   L   L   M   M   M   M   M   M   M   N   N   N   N   N   N   N   N   N   N   N   N   O   R   T   W   W   X   X   X   X   X   X   Y   Y   Y   Y   Y   Y   `   `   `   b   b   b   b   b   d   d   d   d   d   d   h   i   i   j   j   k   k   k   k   k   k   o   o   p   q   q   q   q   q   r   r   s   s   s   s   s   s   s   s   s   s   s   s   u   v   v   v   v   b   y   ~   ~   ~      �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �          client     �      method     �      uri     �      headers     �   	   next_buf     �      request    �   	   response    �      path    �      query    �      (for generator) 2   :      (for state) 2   :      (for control) 2   :      line 3   8      key 6   8      val 6   8      auth K   a   	   username T   a   	   password T   a      (for generator) x   �      (for state) x   �      (for control) x   �      _ y   �      handler y   �      ok �   �      err �   �      h �   �      (for generator) �   �      (for state) �   �      (for control) �   �      k �   �      v �   �      headers �   �           �   �    d   � @ �@@�@� W�   � � ��� �� �@  ����   AA �� �@ ��� �@  � � �   � �I� �� � �@�A� ܀��   ��� �B� ��� F� K���A�\����C� �� D �D  �� �  �@ ��\� @��
�@D��K�C�� \��L����  � C AC ���B���  � C A� ���B�Z   ���@@���  � C A� �B ���  ��   @�� ���� @ @�E�  � �B C @ \B�I@� �  ��� �       data    fd    recv    logf    LG_DBG 
   webserver    Client closed connection    close    buf    find    

    sub       �?      @   match    ^(%S+) (%S+).-[
]+(%S.+)    GET    POST    Content[-]Length:%s+(%d+)            LG_DMP    Content-Length=%d    #next_buf=%d (   Not all data received. Next time better    LG_WRN %   Could not handle http request [[%s]]     d   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   
      event     c      client     c      data    c      offset    b      buf !   `   	   next_buf %   `      method (   `      uri (   `      headers (   `      content_length 9   X         handle_request     �      
5   � @ �@@�@� W�   � � ��  ��@�@� ��  EA �� ��  �A�
A 	� �	A �	���	�	ÅJ  	A��J  	A�d  	A��dA  	A�d�       � 	A��d�  	A�d 	A��dA 	A�EA K���A@\A�EA K���A    @ \A�F� IAF �       data    fd    net    accept    logf    LG_DBG 
   webserver    New connection from %s    address    buf        evq_handler  
   resp_data    resp_header    recv    send    close 	   add_data    set_header 
   set_cache    evq    fd_add 	   register    client_list              	   �   �@@ƀ@ A�   ��  � ��    �       net    recv    fd       �@    	                           client           len                         �   �@@ƀ@  � � ��    �       net    send    fd                            client           buf                  
      E   F@� ��@ \@ E�  K � ��    @  \@�E�  K@� ƀ@ \@�D � F�� I�A  �       net    close    fd    evq    unregister    fd_del    client_list                                     	  	  	  
        client              on_fd_client 
   webserver           	   � @ � @ � ��@��  @� � � � �    
   resp_data       �?	   tostring     	                           client           data                         � @ ɀ�  �       resp_header                    client           key           val                         	@ � �       cache_time                  client           seconds            5   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �   �           
  
  
  
                                              event     4   
   webserver     4      fd 
   4      address 
   4      client (   4         on_fd_client       ,   7   J  �   �@  b@ ��  ��@�  �� �@ � @�  �E�  F��� �   \� Z  � ��   �@��B � A� � � �B�!�   ��  AC@ �� A�	��� AD��C A� �D�� �     A�A E� �� �  �A� �          T@     @�@   net    socket    tcp            ipairs    bind    0.0.0.0    logf    LG_WRN 
   webserver    Bind to port 80 failed: %s    listen       @   fd    evq    fd_add 	   register    LG_INF !   HTTP server listening on port %q     7                                               !  "  "  $  $  $  $  $  $    %  '  '  '  '  '  (  )  )  )  )  *  *  *  *  *  *  +  +  +  +  +  +  ,     
   webserver     6   
   port_list    6      s    6      port 	   6      (for generator)           (for state)           (for control)           _       	   try_port          ok          err             on_fd_server     3  ;      E   �@@ \ @ ���@�A a�  ��E�  K � �@   @  \@�E�  K�� �@A \@�E� F�� �@A \@ E  �@ �� � \@  �       pairs    client_list    close    evq    unregister    fd    fd_del    net    logf    LG_INF 
   webserver    HTTP server stopped        4  4  4  4  5  5  4  5  7  7  7  7  7  7  8  8  8  8  9  9  9  9  :  :  :  :  :  ;     
   webserver           (for generator)          (for state)          (for control)          client          _             on_fd_server     B  J       
�  AA  �� ��  U��	A�	���	� �FAA �AA � ��AI �       path    ^    $    fn    fndata    handler_list       �?       C  D  D  D  D  D  E  F  I  I  I  I  I  J     
   webserver           path           fn           fndata           handler               N  R       E   F@� �   ��  �  \�   � E   F@� �   �  $  ]  ^    �       string    gsub    %+      	   %%(%x%x)        Q  Q    	   E   F@� ��  �   �  � �]   ^    �       string    char 	   tonumber       0@    	   Q  Q  Q  Q  Q  Q  Q  Q  Q        xx               O  O  O  O  O  O  O  P  P  P  P  Q  P  Q  R        field                U  Z        @ @ �A@  ^  d   ��  ��@�    @� ��       �            string    gsub    (['"&<>%c])        W  W    
   E   F@� ��  �   ���   �  ]   ^    �       string    format    &#%02d;    byte     
   W  W  W  W  W  W  W  W  W  W        aValue     	          V  V  V  V  W  X  X  X  X  X  X  X  Y  Z        s        
   aFunction               a  w       
@ 	@@�J   	@ �	@��J   	@ �D   	@��D � 	@ �D  	@��E  	@ �E@ 	@��   � 
      fd     client_list    evq_handler    handler_list 	   register    start    stop    url_decode    url_encode        c  g  h  h  i  j  j  n  n  o  o  p  p  q  q  r  r  u  w     
   webserver          	   register    start    stop                   �   �   �       ,  ,  ;  ;  J  R  N  Z  U  w  w  w  w  a  w        handle_request          on_fd_client          on_fd_server 
         start          stop       	   register           