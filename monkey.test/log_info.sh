#!/bin/bash

#log_info.sh log_dir
. ./system.config

[ $# -eq 1 ] || exit 1

log=$1
[ -d $log ] || exit 1

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb

# here can add any info about device if need
echo "[LOGGING] info: uptime ps procrank b2g-ps b2g-procrank df..."
$ADB shell uptime >${log}/uptime
$ADB shell ps > ${log}/ps
$ADB shell procrank > ${log}/procrank
$ADB shell b2g-ps > ${log}/b2g-ps
$ADB shell b2g-procrank > ${log}/b2g-procrank
$ADB shell df > ${log}/df

echo "[LOGGING] info: logcat"
$ADB logcat -d > ${log}/logcat

#ganap
$ADB shell $GSNAP ${DEVDIR}/${SNAPSHOT_NAME}3.jpg /dev/graphics/fb0 >/dev/null 2>&1 
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}1.jpg $log
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}2.jpg $log
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}3.jpg $log

#coredump
mkdir -p ${log}/coredump
[ -n "$coredump_path" ] || coredump_path=$($ADB shell mount|awk '{if($2!="/mnt/secure/asec" && $3=="vfat") print $2}'|head -n 1)/coredump
$ADB pull $coredump_path ${log}/coredump
$ADB shell rm ${coredump_path}/*

exit 0
