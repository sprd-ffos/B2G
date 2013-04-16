#!/bin/bash

#check $ADB, and try to start $ADB server when it is down

if [ $# -ne 1 ]
then
    echo Usage: $0 passwd
    exit 1
fi

ADB=adb
passwd=$1
start_cnt=0

while ! $ADB shell echo -n
do
    expect -c "

    spawn sudo -s
    sleep 1
    send \"$passwd\r\"
    sleep 3
    send \"$ADB kill-server\r\"
    sleep 3
    send \"$ADB start-server\r\"
    sleep 10
    send \"exit\r\"
    "

    [ $(( start_cnt++ )) -lt 3 ] || exit 1 
done
