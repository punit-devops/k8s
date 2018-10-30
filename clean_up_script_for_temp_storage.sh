#!/bin/bash

###########################################
#   Cleanup for scratch_disk NFS mount    #
#          Created by Punit Goyal         #
#                                         #
#   It can be used for a location which   #
#  application team will use as temporary #
#      storage or as scratch disk.        #
###########################################

# Usage:
# bash cleanup_scratch_disk_v0.1.sh <Name_of_NFS_Mount>

FS=/nfs/scratch_disk/$1
cd $FS
cat /dev/null > /tmp/list_of_files_to_be_deleted.txt

#Finding the list of files which are not modified in last 13 days
find $FS -type f -mtime +13  -exec ls -lh {} >> /tmp/list_of_files_to_be_deleted.txt \;

#Counting number of files
Number_of_files=$(cat /tmp/list_of_files_to_be_deleted.txt | awk '{ print $3}' | grep -v root | wc -l )
echo -e "There are total $Number_of_files file in /nfs/scratch_disk/$1, which were not used/modified in last 13 days. And these will be deleted tomorrow.\nThere is no backup being taken for these file, so if you need these files permanently, please edit them or move to another location \n \n"  > /tmp/mail_body


#Finding list of users who own the older files
result=$(cat /tmp/list_of_files_to_be_deleted.txt | awk '{ print $3}' | uniq | grep -v root)
if [ -z "$result" ]; then
     exit 1
fi


#Creating a user list for sending emails
users_list="$(printf "$result" | awk -F/ '{print $NF"@company-domain.com"}')"

#Sending the list of files to the users
cat /tmp/mail_body /tmp/list_of_files_to_be_deleted.txt | mail -r svc_sciops@dunnhumby.co.uk -c Admin@company-domain.com -s "Files to be removed from /nfs/scratch_disk for location - $1" $users_list

# Moving the files which are not modified in last 14 days to a trash location
find $FS -type f -mtime +14 -exec rm -rf {} \;
