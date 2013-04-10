#!/bin/bash

#orng preprocess
#push (orng, orng.sc, busybox) to device, push to /data folder generally.
#if ok, exit 0. or exit 1

#set $BUSYBOX
. ./set_busybox.sh
ADB=adb
FIND="$ADB shell $BUSYBOX find"
DEVDIR=/data
MTFILE=(./bin/orng ./sc/orng.sc)

for file in ${MTFILE[@]} ; do
    #maybe need some check...
    [ -z $($FIND ${DEVDIR} -name ${file}) ] || continue
    [ -f ${file} ] || { echo ${file} does not exist; exit 1; }
        
    $ADB push ${file} ${DEVDIR}
    $ADB shell chmod 777 ${DEVDIR}/$(basename ${file})
done

