#!/bin/bash

#log_common.sh log_dir

[ $# -eq 1 ] || exit 1

log=$1
[ -d $log ] || exit 1

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb

echo "[LOGGING] common: getprop"
$ADB shell getprop > ${log}/getprop
echo "[LOGGING] common: slogctl.query"
$ADB shell slogctl query > ${log}/slogctl.query

exit 0
