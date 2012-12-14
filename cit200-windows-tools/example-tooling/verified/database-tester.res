
BEGIN TESTCASE test_Tag_value
tv1("bla=abc")=bla,abc
tv2=little tag,this is the value
tv2=ok
tv3=isbad

BEGIN TESTCASE test_Format
f1.merge_tag_values(values1)=\${var1}='variable value 1'\n\${var2}='variable value 2'

BEGIN TESTCASE test_Barcode_db
Barcode1:
Format1:the first value is "this is barcode 1"\nand the second is "content of value 2"
Barcode2:
Format2:de eerste is "this is barcode 2"\nde tweede is "content of value 2"
Barcode3:
Onbekende format
Onbekende barcode:
Formatting from format "onbekend"
