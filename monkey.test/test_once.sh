#!/bin/bash

#test once
#exit when crashed or error
. ./system.config
. ./test.config
. $DEVICE_CONFIG

#time define
TICK=10
HOME_TICK=120
POWER_TICK=180

hometick=$HOME_TICK
powertick=$POWER_TICK

trap './kill_unlock.sh' EXIT

echo "["$(date)"] Begin a new test."

while true
do
    #check crash report, the dmp file
    ./crash_report.sh
    case "$?" in
    "$EXIT_TEST_CRASH_DETECT")
        ./push_report.sh
        exit 0
        ;;
    *)
        error_test $? $0 $LINENO
        ;;
    esac

    #test fix operating, such as unlock, home key, etc.
    if [ $hometick -gt 0 ]
    then
        hometick=$(( hometick - TICK ))
    else
        hometick=$HOME_TICK
        $ADB shell /data/orng $DEV_TOUCHSCREEN_EVENT /data/home.sc
    fi

    if [ $powertick -gt 0 ]
    then
        powertick=$(( powertick - TICK ))
    else
        powertick=$POWER_TICK
        $ADB shell /data/orng $DEV_TOUCHSCREEN_EVENT /data/unlock_${DEV_RESOLUTION}.sc
    fi

    #keep running unlock, include keep lcd on
    pgrep keep_unlock.sh > /dev/null || ./keep_unlock.sh &

    #keep running orng, or other monkey tools
    ./keep_test.sh 
    error_test $? $0 $LINENO

    sleep $TICK

    #tick do - 
    ./tick_collect_info.sh
    error_test $? $0 $LINENO
done

