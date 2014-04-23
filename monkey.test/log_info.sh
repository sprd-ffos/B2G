#!/bin/bash

#log_info.sh log_dir
. ./system.config

[ $# -eq 1 ] || exit 1

log=$1
[ -d $log ] || exit 1

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb

# here can add any info about device if need
echo "[LOGGING] info: cmd"
for cmd in uptime b2g-ps b2g-procrank ps df dumpsys procrank dmesg
do
    $ADB shell $cmd > ${log}/$cmd
done

echo "[LOGGING] info: file"
for file in /proc/meminfo /proc/cmdline /proc/buddyinfo /proc/yaffs /proc/slabinfo
do
    $ADB pull $file ${log}/
done

#ganap
$ADB shell $GSNAP ${DEVDIR}/${SNAPSHOT_NAME}3.jpg /dev/graphics/fb0 >/dev/null 2>&1 
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}1.jpg $log
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}2.jpg $log
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}3.jpg $log

echo "[LOGGING] info: logcat"
#main system radio events
for buffer in main system radio
do
    $ADB logcat -d -b $buffer > ${log}/logcat.$buffer
done

echo "[LOGGING] info: bugreport. This will take a while..."
$ADB bugreport > ${log}/bugreport

#coredump
mkdir -p ${log}/coredump
[ -n "$coredump_path" ] || coredump_path=$($ADB shell mount|awk '{if($2!="/mnt/secure/asec" && $3=="vfat") print $2}'|head -n 1)/coredump
$ADB pull $coredump_path ${log}/coredump
$ADB shell rm ${coredump_path}/*

exit 0
