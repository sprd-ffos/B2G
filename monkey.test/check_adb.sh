#!/bin/bash

#check $ADB, and try to start $ADB server when it is down

. ./system.config

#check passwd and save passwd
echo $passwd | sudo -S echo 
error_test $? $0 $LINENO

TRY_TIMES=3
try_cnt=0

if [ $ADB = "bin/adb" ]
then
    sudo chown root:root $ADB
    sudo chmod u+s $ADB
fi

while ! $ADB shell echo -n
do
    sudo $ADB kill-server
    sudo $ADB start-server

    [ $(( try_cnt++ )) -lt $TRY_TIMES ] || exit 1 
done

sudo -K
