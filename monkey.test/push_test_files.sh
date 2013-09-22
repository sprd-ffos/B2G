#!/bin/bash

#push all files those need in test
. ./system.config
. ./test.config
. $DEVICE_CONFIG

trap 'exit 1' ERR

$ADB root
$ADB remount
MTFILE=(./bin/orng ./bin/busybox ./bin/gsnap)

for file in ${MTFILE[@]} 
do
    $ADB push $file $DEVDIR
    $ADB shell chmod 777 ${DEVDIR}/$(basename $file)
done

unlock_sc=(./sc/unlock_${DEV_RESOLUTION}.sc)
$ADB push $unlock_sc $DEVDIR

$ADB shell "echo tap $DEV_HOME_X $DEV_HOME_Y 3 200 > /data/home.sc"

