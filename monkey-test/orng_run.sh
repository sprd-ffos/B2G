#!/bin/bash

#run orangutan
#get the ts event
#generate the script. We use a script to randmon write operator for orangutan

[ $# -ne 1 ] && echo "Usage: $(basename $0) [touchscreen device event]"

ts_event=$1
ADB=adb

#orng is running
$ADB shell ps | grep '/data/orng' > /dev/null && exit 0

./gen_script.sh --steps 10000 > ./sc/orng.sc

./orng_pre.sh
[ $? -ne 0 ] && exit 1

$ADB logcat > adb_log &
$ADB shell /data/orng $ts_event /data/orng.sc > /dev/null &
echo orng is running now...
