#!/bin/bash

#monitor the device, if fb sleeping, wake it and unlock the screen
#we have only hvga now~

ADB=adb
#options
VGA=hvga
KEYDEV=/dev/input/event1
POWERKEY=116
TSDEV=/dev/input/event2

usage()
{
    echo "Usage: $(basename $0) [wvga|hvga(default)|qvga] [--tsdev touchscreen_dev] [--keydev keypad_dev] [--key power_key] [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    wvga|hvga|qvga)
        DEV=$1
        ;;
    --tsdev)
        shift
        TSDEV=$1
        ;;
    --keydev)
        shift
        KEYDEV=$1
        ;;
    --key)
        shift
        POWEKEY=$1
        ;;
    --help | -h)
        usage 0
        ;;
    -*)
        echo "Unrecognized option $1"
        usage 1
        ;;
    *)
        break
        ;;
    esac

    shift
done


while true 
do
    $ADB shell cat /sys/power/wait_for_fb_sleep > /dev/null 2>&1 
    [ $? -ne 0 ] && exit 1
    $ADB shell sendevent $KEYDEV 1 $POWERKEY 1 > /dev/null 2>&1 
    [ $? -ne 0 ] && exit 1
    $ADB shell sendevent $KEYDEV 0 0 0 > /dev/null 2>&1 
    [ $? -ne 0 ] && exit 1
    $ADB shell sendevent $KEYDEV 1 $POWERKEY 0 > /dev/null 2>&1 
    [ $? -ne 0 ] && exit 1
    $ADB shell sendevent $KEYDEV 0 0 0 > /dev/null 2>&1 
    [ $? -ne 0 ] && exit 1
    for((i=0;i<2;i++))
    do
        sleep 1
        $ADB shell /data/orng $TSDEV /data/unlock_${VGA}.sc > /dev/null 2>&1 
        [ $? -ne 0 ] && exit 1
    done
done
