#!/bin/bash

#check $ADB, and try to start $ADB server when it is down

if [ $# -ne 1 ]
then
    echo Usage: $0 passwd
    exit 1
fi

ADB=$(which adb)
passwd=$1
start_cnt=0

#null command to save passwd
echo $passwd | sudo -S test

while ! $ADB shell echo -n
do
    sudo $ADB kill-server
    sudo $ADB start-server

    [ $(( start_cnt++ )) -lt 3 ] || exit 1 
done

sudo -K
