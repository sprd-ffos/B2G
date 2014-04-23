#!/bin/bash

. _source_config_check.sh

trap 'exit 1' ERR

echo $passwd | sudo -S echo -n

#check $ADB, and try to start $ADB server when it is down
try_cnt=3

if [ $ADB = "bin/adb" ]
then
    sudo chown root:root $ADB
    sudo chmod u+s $ADB
fi

while ! $ADB shell echo -n
do
    sudo $ADB kill-server
    sudo $ADB start-server

    [ $(( try_cnt-- )) -gt 0 ] || exit 1 
done

#check sdcard, if no sdcard, then refuse to test
if [ $($ADB shell mount | grep -P "^/dev/block/vold/" | wc -l) -lt 2 ]
then
    if [ "$MTCFG_TEST_NEED_SDCARD" == "YES" ]
    then
        log "[ERROR]No external sdcard, test is stopped."
        exit 1
    else
        log "[WARNING]No external sdcard..."
    fi
fi


