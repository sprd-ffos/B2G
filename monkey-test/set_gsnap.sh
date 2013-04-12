#!/bin/bash

#set gsnap
#call this script by "source ..." mode to save the value $GSNAP

ADB=adb

[ -f ./bin/gsnap ] || exit 1

while true
do
    #test defined gsnap or system gsnap, if one has?
    foo=${GSNAP:=gsnap}
    foo=$($ADB shell $GSNAP | grep ": not found")
    [ $? -eq 0 ] || break

    #test /data/gsnap, has?
    GSNAP=/data/gsnap
    foo=$($ADB shell $GSNAP | grep ": not found")
    [ $? -eq 0 ] || break

    #no gsnap, push one to /data
    $ADB push ./bin/gsnap /data
    $ADB shell chmod 777 $GSNAP
    
    break
done
