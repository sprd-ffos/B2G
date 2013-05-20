#!/bin/bash

#push report
. ./system.config
. ./test.config
. $DEVICE_CONFIG
. ./log_server.config

#push to server
push_files=*log-*.tar.bz2

srv_folder=$log_user@$log_server:$log_folder

#use device name as the folder name on server
push_folder=${srv_folder}/${DEV_NAME}/

#if no folder, create it
expect -c "

spawn ssh $log_user@$log_server \"\[ -d ${log_folder}/${DEV} \] || mkdir ${log_folder}/${DEV}\"
set timeout -1
expect {
    \"*@*'s password:\" {send \"$log_passwd\r\"; exp_continue}
    \"Are you sure you want to continue connecting *?\" {send \"yes\r\"; exp_continue}
}
expect eof"

#there is something wrong with wildcard characters in expect, so use find
for file in $push_files
do
    ./pscp.sh --passwd "$log_passwd" -c "$file $push_folder"
done

#mv to backup folder
BACKUP=crash_report_backup
[ ! -d $BACKUP ] && mkdir $BACKUP
mv $push_files $BACKUP


