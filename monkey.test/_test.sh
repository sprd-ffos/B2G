#!/bin/bash

. _source_config_check.sh

trap "log \"[$(date +'%m-%d.%H:%M')]Test end at $(date +'%s')\"" EXIT

#time define
TICK=60
last_uptime=0
uptime=0

log "[$(date +'%m-%d.%H:%M')]Test begin at $(date +'%s')"
#test time limit check
if [ -n "$MTCFG_TEST_TIME_LIMIT" ] && [ $MTCFG_TEST_TIME_LIMIT -gt 0 ]
then
    END_TIME=$(($(date +"%s")+MTCFG_TEST_TIME_LIMIT*60*60))
    log "[$(date +'%m-%d.%H:%M')]Test will end after $MTCFG_TEST_TIME_LIMIT hours($END_TIME)."
fi

while true
do
    $ADB wait-for-device

    #reboot check
    uptime=$($ADB shell cat /proc/uptime | cut -d'.' -f1)
    if [ -z "$uptime" ] || [[ "$uptime" == *[!0-9]* ]]
    then
        log "[$(date +'%m-%d.%H:%M')][WARNING]Get uptime failed!"
    elif [ $uptime -gt $last_uptime ]
    then
        last_uptime=$uptime
    else
        log "[$(date +'%m-%d.%H:%M')]The device is rebooted at $(date +'%s'), prepare to get log..."
        ./_log.sh "reboot"
        #if reboot, we will stop any operations to preserve the spot
        exit 0
    fi

    #test time limit check
    if [ -n "$MTCFG_TEST_TIME_LIMIT" ] && [ $MTCFG_TEST_TIME_LIMIT -gt 0 ] && [ $(date +"%s") -gt $END_TIME ]
    then
        log "[$(date +'%m-%d.%H:%M')]Test run $MTCFG_TEST_TIME_LIMIT hours successful at $(date +'%s'). Get log..."
        ./_log.sh "end"
        exit 0
    fi

    #keep running orng
    ./_test_keep.sh 
    [ $? -ne 0 ] && log "[ERROR]$0($LINENO) test keep" && exit 1

    sleep $TICK 
done
