#!/bin/bash

#push report
. ./system.config
. $TEST_CONFIG
. $LOG_SERVER_CONFIG

#if local test, do not push crash report
[ $TEST_VERSION = "local" ] && exit 0

#push to server
push_files=mtlog-*.tar.bz2

srv_folder=$log_user@$log_server:$log_folder

#use device name as the folder name on server
push_folder=${srv_folder}/

#if no folder, create it
expect -c "

spawn ssh $log_user@$log_server \"\[ -d $log_folder \] || mkdir $log_folder}\"
set timeout -1
expect {
    \"*@*'s password:\" {send \"$log_passwd\r\"; exp_continue}
    \"Are you sure you want to continue connecting *?\" {send \"yes\r\"; exp_continue}
}"

#there is something wrong with wildcard characters in expect, so use find
for file in $push_files
do
    ./pscp.sh --passwd "$log_passwd" -c "$file $push_folder"
done

#mv to backup folder
[ ! -d $LOGBACKUP ] && mkdir $LOGBACKUP
mv $push_files $LOGBACKUP

exit 0
