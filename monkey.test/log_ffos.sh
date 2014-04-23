#!/bin/bash

#log_ffos.sh log_dir symbol_dir
. ./system.config
[ -n "$TEST_CONFIG" ] && . $TEST_CONFIG

[ $# -ge 1 ] || exit 1

log=$1
[ -d $log ] || exit 1
symbol=$2

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb
BUSYBOX=/data/busybox
FIND="$ADB shell $BUSYBOX find"
DMPDIR=/data/b2g/mozilla
DUMPTOOL=bin/minidump_stackwalk

#dump files
$FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | sed 's/\r//'| while read file
do
    echo "[LOGGING] ffos: '$file'"
    $ADB pull "$file" ${log}/
    echo "[LOGGING] rm '$file' from device"
    $ADB shell rm "$file"
done

if ls ${log}/*dmp > /dev/null 2>&1 && [ -f $DUMPTOOL ] && [ -d "$symbol" ]
then
    echo "[LOGGING] ffos: dump parse..."
    $DUMPTOOL ${log}/*.dmp $symbol > ${log}/dump_parse
fi

if [ -n "$TEST_CONFIG" ]
then
    echo "[LOGGING] ffos: manifest.xml"
    cp ${IMAGE_FOLDER}/manifest.xml ${log}/

    if [ $TEST_VERSION = "daily" ]
    then
        echo "[LOGGING] ffos: .config .userconfig"
        cp ../.config ${log}/config
        cp ../.userconfig ${log}/userconfig
    fi
fi

exit 0
