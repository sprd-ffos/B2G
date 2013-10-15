#!/bin/bash

#crash report
#just get report, if there are...
#find the file from device
#if there are, get it and tar it, and exit 0
#or exit 1
. ./system.config
. ./test.config
. $DEVICE_CONFIG

DMPDIR=/data/b2g/mozilla
DUMPTOOL=./bin/minidump_stackwalk

file_cnt=$($FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | wc -l)

#if no dmp file, do nothing...
if [ $file_cnt -eq 0 ]
then
    exit 0
fi

./kill_orng.sh

if [ "$TEST_VERSION" = "release" ]
then
    SYMBDIR=./$IMAGE_FOLDER/crashreporter-symbols
elif [[ "$TEST_VERSION" == custom* ]]
then
    SYMBDIR=./$IMAGE_FOLDER/objdir-gecko/dist/crashreporter-symbols
else
    SYMBDIR=../objdir-gecko/dist/crashreporter-symbols
fi

#gen time tag
tag=${LOGHEAD}-$(echo ${DEV_NAME} | sed 's/-/_/g')-$(echo ${TEST_VERSION} | sed 's/-/_/g')-$(cat /etc/hostname | sed 's/-/_/g')-$(date +%y%m%d%H%M)

mkdir $tag

#ganap
$ADB shell $GSNAP ${DEVDIR}/${SNAPSHOT_NAME}3.jpg /dev/graphics/fb0 >/dev/null 2>&1 
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}1.jpg $tag
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}2.jpg $tag
$ADB pull ${DEVDIR}/${SNAPSHOT_NAME}3.jpg $tag

#bugreport is enough
$ADB shell bugreport > ${tag}/bugreport
$ADB shell b2g-ps > ${tag}/b2g-ps
$ADB shell b2g-procrank > ${tag}/b2g-procrank

#dump files
$FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | sed 's/\r//'| while read file
do
    #pull file
    $ADB pull "$file" $tag
    #delete dmp file
    $ADB shell rm "$file"
done

#parse files, maybe need 5 minute
if [ -f $DUMPTOOL ] && [ -d $SYMBDIR ]
then
    $DUMPTOOL ${tag}/*.dmp $SYMBDIR > ${tag}/dump_parse
fi
    
#manifest.xml
cp ${IMAGE_FOLDER}/manifest.xml ${tag}/

if [ $TEST_VERSION = "daily" ]
then
    #cp .config and .userconfig
    cp ../.config ${tag}/config
    cp ../.userconfig ${tag}/userconfig
fi

#tombstones
$ADB pull $TOMBSTONES $tag
$ADB shell rm -r $TOMBSTONES

#slog
$ADB pull ${SLOGDIR}_bak $tag
$ADB pull $SLOGDIR $tag

#build_number
[ -f "${IMAGE_FOLDER}/build_number" ] && cp ${IMAGE_FOLDER}/build_number $tag/

#tar files
tar -caf ${tag}.tar.bz2 ${tag}/*

rm -rf $tag

exit $EXIT_TEST_CRASH_DETECT

