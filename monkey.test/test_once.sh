#!/bin/bash

#test once
#exit when crashed or error
. ./system.config
. $TEST_CONFIG
. $DEVICE_CONFIG

#check passw
echo $passwd | sudo -S echo 
error_test $? $0 $LINENO

DMPDIR=/data/b2g/mozilla
#time define
TICK=10
HOME_TICK=120
POWER_TICK=180
SLOG_TICK=900

hometick=$HOME_TICK
powertick=$POWER_TICK
slogtick=$SLOG_TICK
last_uptime=0
uptime=0

trap './kill_unlock.sh' EXIT

echo "["$(date)"] Begin a new test."

while true
do
    $ADB wait-for-device

    #status check
    uptime=$($ADB shell cat /proc/uptime | cut -d'.' -f1)
    [[ "$uptime" == *[!0-9]* ]] && exit 1
    if [ $uptime -gt $last_uptime ]
    then
        last_uptime=$uptime
    else
        echo "[LOGGING] Test stopped, catch the last log."
        ./kill_orng.sh
        ./kill_unlock.sh
        ./log4last.sh $passwd
        ./push_report.sh
        exit 0
    fi

    minidump_file_cnt=$($FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | wc -l)
    coredump_file_cnt=$($ADB shell ls $coredump_path | wc -l)
    #if has dmp file, catch log, and enter next test
    if [ $minidump_file_cnt -gt 0 ] || [ $coredump_file_cnt -gt 0 ]
    then
        echo "[LOGGING] Test stopped, catch the current log."
        ./kill_orng.sh
        ./kill_unlock.sh
        #echo "[WAITING] 5 minutes for the dump file genaration"
        #sleep 300
        ./log4now.sh
        ./push_report.sh
        exit 0
    fi

    #test fix operating, such as unlock, home key, etc.
    if [ $hometick -gt 0 ]
    then
        hometick=$(( hometick - TICK ))
    else
        #press home key
        if [ $DEV_HOME_KEY ]
        then
            $ADB shell sendevent $DEV_KEYPAD_EVENT 1 $DEV_HOME_KEY 1 >/dev/null 2>&1
            $ADB shell sendevent $DEV_KEYPAD_EVENT 0 0 0 >/dev/null 2>&1
            $ADB shell sendevent $DEV_KEYPAD_EVENT 1 $DEV_HOME_KEY 0 >/dev/null 2>&1
            $ADB shell sendevent $DEV_KEYPAD_EVENT 0 0 0 >/dev/null 2>&1
        fi

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

    if [ $slogtick -gt 0 ]
    then
        slogtick=$(( slogtick - TICK ))
    else
        slogtick=$SLOG_TICK
        echo -n "slogctl clear... "
        $ADB shell slogctl clear
    fi

    #keep running unlock, include keep lcd on
    pgrep keep_unlock.sh > /dev/null || ./keep_unlock.sh &

    #keep running orng, or other monkey tools
    ./keep_test.sh 
    error_test $? $0 $LINENO

    #collect device information inter-test, such as screenshot
    ./tick_collect_info.sh

    sleep $TICK
done
