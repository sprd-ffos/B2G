#!/bin/bash

. _source_config_check.sh

trap 'exit 1' ERR

MTFILE=(./bin/orng ./bin/busybox)

for file in ${MTFILE[@]} 
do
    $ADB push $file /data
    $ADB shell chmod 777 /data/$(basename $file)
done

$ADB wait-for-device && sleep 3 && $ADB root
$ADB wait-for-device && sleep 3 && $ADB remount
$ADB wait-for-device

unlock_sc=(./sc/unlock_${MTCFG_DEV_RESOLUTION}.sc)
$ADB push $unlock_sc /data

$ADB shell "echo tap $MTCFG_DEV_HOME_X $MTCFG_DEV_HOME_Y 3 200 > /data/home.sc"

if [ "$MTCFG_TEST_ASSIGN_APP" == "YES" ]
then
    $ADB push ./sc/assign_app.sc /data
    echo "Please drag the assigned application to the left-top corner."
    read -p "If ready, press any key to continue..." -n 1
fi

if [ "$MTCFG_TEST_BAN_SETTINGS" == "YES" ]
then
    $ADB shell rm -r /data/local/webapps/settings.gaiamobile.org
    $ADB remount system && sleep 3 && $ADB wait-for-device
    $ADB shell rm -r /system/b2g/webapps/settings.gaiamobile.org
fi

if [ "$MTCFG_TEST_REFERENCE_WORKLOAD" == "YES" ]
then
    reference-workload/makeReferenceWorkload.sh
fi

if [ "$MTCFG_TICK_COLLECT_INFO_B2G" == "YES" ]
then
    rm -rf tick_collect_info
fi
