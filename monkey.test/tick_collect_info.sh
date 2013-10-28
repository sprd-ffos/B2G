#!/bin/bash

#do every tick, collect info for debug
. ./system.config
. $TEST_CONFIG
. $DEVICE_CONFIG

$ADB shell mv ${DEVDIR}/${SNAPSHOT_NAME}2.jpg ${DEVDIR}/${SNAPSHOT_NAME}1.jpg >/dev/null 2>&1 
$ADB shell $GSNAP ${DEVDIR}/${SNAPSHOT_NAME}2.jpg /dev/graphics/fb0 >/dev/null 2>&1 

exit 0
