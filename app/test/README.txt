nquire app/test/README.txt

Manually verify whether there are no resource leaks on the target:

[root@NEWLAND_CIT /cit200] (while true; do cat /proc/sys/fs/file-nr; sleep 1; done) &

The first minus the second number of the output represents the number of 
currently opened files. 


