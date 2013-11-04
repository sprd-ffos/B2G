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
./ssh_passwd.sh --passwd "$log_passwd" -c "ssh $log_user@$log_server \"\[ -d $log_folder \] || mkdir $log_folder\""

#there is something wrong with wildcard characters in expect, so use find
for file in $push_files
do
    log_file "log path: ${push_folder}$file (user: $log_user, passwd: $log_passwd)"
    ./ssh_passwd.sh --passwd "$log_passwd" -c "scp $file $push_folder"
    ./log2server.sh --server $LOG_SERVER_CONFIG -s "$(date +%y%m%d.%H:%M) ${USER}@$(cat /etc/hostname) push log: $file."
done

#mv to backup folder
[ ! -d $LOGBACKUP ] && mkdir $LOGBACKUP
mv $push_files $LOGBACKUP

exit 0
