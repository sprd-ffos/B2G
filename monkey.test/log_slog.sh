#!/bin/bash

#log_slog.sh log_dir

[ $# -eq 1 ] || exit 1

log=$1
[ -d $log ] || exit 1

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb

internal=$($ADB shell slogctl query | grep "^internal" | cut -d',' -f2)
external=$($ADB shell slogctl query | grep "^external" | cut -d',' -f2)

echo "capture logs..."
$ADB shell slogctl screen
$ADB shell slogctl snap
$ADB shell slogctl snap bugreport

slog=${log}/slog
mkdir -p ${slog}/internal
mkdir -p ${slog}/external

echo "[LOGGING] slog: internal external"
$ADB pull ${internal} ${slog}/internal/
$ADB pull ${external} ${slog}/external/

#echo "[LOGGING] slog, remove last_log"
#rm -rf ${slog}/internal/last_log
#rm -rf ${slog}/external/last_log

exit 0
