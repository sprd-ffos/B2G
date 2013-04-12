#!/bin/bash

#set busybox
#call this script by "source ..." mode to save the value $BUSYBOX

ADB=adb

[ -f ./bin/busybox ] || exit 1

while true
do
    #test defined busybox or system busybox, if one has?
    foo=${BUSYBOX:=busybox}
    foo=$($ADB shell $BUSYBOX | grep ": not found")
    [ $? -eq 0 ] || break

    #test /data/busybox, has?
    BUSYBOX=/data/busybox
    foo=$($ADB shell $BUSYBOX | grep ": not found")
    [ $? -eq 0 ] || break

    #no busybox, push one to /data
    $ADB push ./bin/busybox /data
    $ADB shell chmod 777 $BUSYBOX
    
    break
done
