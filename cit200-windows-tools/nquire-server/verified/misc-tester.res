
BEGIN TESTCASE test_bytes_to_text
\n='\n'
\r='\r'
\t='\t'
\e='\e'
\[='\['
\]='\]'
\$='\$'
\#='\#'
\\='\\'
\x1f='\x1f'
\x20=' '
\x7f=''
\x80='\x80'

BEGIN TESTCASE test_text_to_bytes
newline: \n
return: \r
tab: \t
escape: \x1b
brackets: \[\]
dollar: \$
hekje: \#
backslash: \\
hex codes: \x03\x80\xa0\xff

BEGIN TESTCASE test_get_local_ip_addresses
addr[0]=127.0.0.1
addr[1]=192.168.1.129
addr[2]=192.168.1.223
addr[3]=::
addr[4]=0:0:fe80::21b:38ff
addr[5]=0:0:fe80::213:e8ff
