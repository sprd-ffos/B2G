#!/bin/bash

#run orangutan
#get the ts event
#generate the script. We use a script to randmon write operator for orangutan
. ./system.config
. ./test.config
. $DEVICE_CONFIG

trap 'exit 1' ERR

#orng is running
$ADB shell ps | grep "${DEVDIR}/orng" >/dev/null && exit 0

orng_sc=sc/orng.sc
./gen_script.sh $DEV_RESOLUTION --steps 10000 >$orng_sc
$ADB push $orng_sc $DEVDIR

echo orng is running now...
$ADB shell ${DEVDIR}/orng $DEV_TOUCHSCREEN_EVENT ${DEVDIR}/orng.sc >/dev/null &
