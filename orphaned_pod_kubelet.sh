##################################################
######### This Script is for handling ############
######### Orphaned pod Issue in kubelet ##########
##################################################
############ Created By: Punit Goyal #############
##################################################

#!/bin/bash
var1=`journalctl -u kubelet -S  "1 hour ago" | grep "Orphaned pod" | awk -F' ' '{print $12}' | sort | uniq | tr "\"" " " `

if [ -z "$var1" ]; then
    exit 0
fi

var2=`echo $var1 | tr " " "\n"`

for i in $var2
do
   m1=`mount | grep $i | awk '{print $3}'`
   m2=`echo $m1 | tr " " "\n"`
   for j in $m2
   do
     umount $j
   done
   rm -r /var/lib/kubelet/pods/$var2
done
