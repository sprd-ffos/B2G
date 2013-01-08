#!/bin/bash

SCRIPT_NAME=$(basename $0)
. load-config.sh

ADB=adb
B2G_BIN=/system/b2g/b2g
ORNG_BIN=/data/orng
SCRIPT_SRC=/data/script
ORNG_BIN_NATIVE=./monkey-tool/orng


EXIST_ORNG_BIN=`$ADB shell toolbox ls $ORNG_BIN | awk '{ print \$2; }'`

if [ -n "$EXIST_ORNG_BIN" ]; then
    if [ ! -f "$ORNG_BIN_NATIVE" ]; then
        echo "The orng is not exist in your computer, please download it from sprd b2g wiki"
        exit 1;
    fi
    echo "The orng is not exist, push it in the phone..."
    $ADB push ./monkey-tool/orng /data
    $ADB shell chmod 777 $ORNG_BIN
    $ADB push ./monkey-tool/script /data
    $ADB shell chmod 777 $SCRIPT_SRC
fi

B2G_PID=$($ADB shell 'toolbox ps b2g | (read header; read user pid rest; echo -n $pid)')
ORNG_PID=`$ADB shell toolbox ps | grep "orng" | awk '{ print \$2; }'`

if [ -n "$ORNG_PID" ]; then
    echo "Kill orng process...!"
    $ADB shell kill $ORNG_PID
fi

$ADB logcat > result.txt &
$ADB shell /data/orng /dev/input/event2 /data/script > /dev/zero &

./run-gdb.sh attach $B2G_PID
