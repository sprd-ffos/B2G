#!/bin/bash

#1 get report from server, ../server.config
#2 parse cr, base on the database in current folder, then give all report

. ./server.config

cpfolder=cr_from_server_$(date +%y%m%d%H%M$S)

mkdir $cpfolder

expect -c "

spawn scp -r $suser@$sserver:$sfolder $cpfolder
set timeout -1 
expect {
    \"*@*'s password:\" {send \"$spasswd\r\"; exp_continue}
    \"Are you sure you want to continue connecting *?\" {send \"yes\r\"; exp_continue}
}"

./add_folder.sh $cpfolder

rm -rf $cpfolder

