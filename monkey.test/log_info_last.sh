#!/bin/bash

#log_slog_last.sh log_dir

[ $# -eq 1 ] || exit 1

log=$1
[ -d $log ] || exit 1

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb

echo "[LOGGING] last_kmsg"
$ADB pull /proc/last_kmsg ${log}/

echo "[LOGGING] snapshot"
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}1.jpg $log
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}2.jpg $log

internal=$(adb shell slogctl query | grep "^internal" | cut -d',' -f2)
external=$(adb shell slogctl query | grep "^external" | cut -d',' -f2)

slog_last=${log}/slog/last_log
mkdir -p ${slog_last}/internal
mkdir -p ${slog_last}/external

echo "[LOGGING] slog last: internal external"
$ADB pull ${internal}/last_log ${slog_last}/internal/
$ADB pull ${external}/last_log ${slog_last}/external/

exit 0
