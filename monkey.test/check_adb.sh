#!/bin/bash

#check $ADB, and try to start $ADB server when it is down

. ./system.config

if [ $# -ne 1 ]
then
    echo Usage: $0 passwd
    exit 1
fi

passwd=$1
try_cnt=0

#null command to save passwd
echo $passwd | sudo -S echo -n 
error_test $? $0 $LINENO

if [ $ADB = "bin/adb" ]
then
    sudo chown root:root $ADB
    sudo chmod u+s $ADB
fi

while ! $ADB shell echo -n
do
    sudo $ADB kill-server
    sudo $ADB start-server

    [ $(( try_cnt++ )) -lt 3 ] || exit 1 
done

sudo -K
