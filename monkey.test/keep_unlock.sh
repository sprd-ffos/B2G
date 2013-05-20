#!/bin/bash

#monitor the device, if fb sleeping, wake it and unlock the screen
#we have only hvga now~
. ./system.config
. ./test.config
. $DEVICE_CONFIG

trap 'exit 1' ERR

while true 
do
    #send a power key press
    $ADB shell sendevent $DEV_KEYPAD_EVENT 1 $DEV_POWER_KEY 1 >/dev/null 2>&1 
    $ADB shell sendevent $DEV_KEYPAD_EVENT 0 0 0 >/dev/null 2>&1 
    $ADB shell sendevent $DEV_KEYPAD_EVENT 1 $DEV_POWER_KEY 0 >/dev/null 2>&1 
    $ADB shell sendevent $DEV_KEYPAD_EVENT 0 0 0 >/dev/null 2>&1 

    #simulator a unlock tap
    for((i=0;i<2;i++))
    do
        sleep 1
        $ADB shell /data/orng $DEV_TOUCHSCREEN_EVENT /data/unlock_${DEV_RESOLUTION}.sc >/dev/null 2>&1 
    done
    $ADB shell cat /sys/power/wait_for_fb_sleep >/dev/null 2>&1 
done
