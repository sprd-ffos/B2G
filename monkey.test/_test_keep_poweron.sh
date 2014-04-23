#!/bin/bash

#to do...
exit 0

. _source_config_check.sh

trap 'exit 1' ERR

while true 
do
    $ADB shell cat /sys/power/wait_for_fb_sleep >/dev/null 2>&1 

    #send a power key press
    $ADB shell sendevent $MTCFG_DEV_KEYPAD_EVENT 1 $MTCFG_DEV_POWER_KEY 1 >/dev/null 2>&1 
    $ADB shell sendevent $MTCFG_DEV_KEYPAD_EVENT 0 0 0 >/dev/null 2>&1 
    $ADB shell sendevent $MTCFG_DEV_KEYPAD_EVENT 1 $MTCFG_DEV_POWER_KEY 0 >/dev/null 2>&1 
    $ADB shell sendevent $MTCFG_DEV_KEYPAD_EVENT 0 0 0 >/dev/null 2>&1 
done
