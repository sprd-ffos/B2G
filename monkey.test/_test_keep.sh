#!/bin/bash

#run orangutan
#get the ts event
#generate the script. We use a script to randmon write operator for orangutan
. _source_config_check.sh

trap 'exit 1' ERR

#orng is running
$ADB shell ps | grep -F '/data/orng' >/dev/null && exit 0

#keep last operation sequence, maybe can recurrent exceptions
orng_sc=sc/orng.sc
./gen_script.sh $DEV_RESOLUTION --steps 1000 >$orng_sc
$ADB push $orng_sc /data 

#keep screen on
./_test_keep_poweron.sh
#keep unlock by simulator a unlock tap(3 times for confirm...)
for((i=0;i<2;i++))
do
    $ADB shell /data/orng $MTCFG_DEV_TOUCHSCREEN_EVENT /data/unlock_${DEV_RESOLUTION}.sc >/dev/null 2>&1 
    sleep 1
done
#keep test from homescreen, give a 'HOME' key
$ADB shell /data/orng $MTCFG_DEV_TOUCHSCREEN_EVENT /data/home.sc >/dev/null 2>&1

if [ "$MTCFG_TEST_ASSIGN_APP" == "YES" ]
then
    $ADB shell /data/orng $MTCFG_DEV_TOUCHSCREEN_EVENT /data/assign_app.sc >/dev/null 2>&1
fi

$ADB shell /data/orng $MTCFG_DEV_TOUCHSCREEN_EVENT /data/orng.sc >/dev/null &
log "[$(date +'%m-%d.%H:%M')]New orng is running now..."
