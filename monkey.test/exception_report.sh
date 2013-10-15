#!/bin/bash

. ./system.config
. ./test.config
. $DEVICE_CONFIG


./kill_orng.sh

#gen time tag
tag=${EXLOGHEAD}-$(echo ${DEV_NAME} | sed 's/-/_/g')-$(echo ${TEST_VERSION} | sed 's/-/_/g')-$(cat /etc/hostname | sed 's/-/_/g')-$(date +%y%m%d%H%M)

mkdir $tag

$ADB pull /proc/last_kmsg $tag

kmsg_parse=$(tempfile)

grep -f crdb.exception.filter ${tag}/last_kmsg > $kmsg_parse
[ $? -eq 0 ] && cp $kmsg_parse ${tag}/kmsg_parse

#tombstones
$ADB pull $TOMBSTONES $tag
$ADB shell rm -r $TOMBSTONES

#slog
$ADB pull ${SLOGDIR}_bak $tag
$ADB pull $SLOGDIR $tag

#manifest.xml
cp ${IMAGE_FOLDER}/manifest.xml ${tag}/

#build_number
[ -f "${IMAGE_FOLDER}/build_number" ] && cp ${IMAGE_FOLDER}/build_number $tag/

if [ $TEST_VERSION = "daily" ]
then
    #cp .config and .userconfig
    cp ../.config ${tag}/config
    cp ../.userconfig ${tag}/userconfig
fi

#tar files
tar -caf ${tag}.tar.bz2 ${tag}/*

rm -rf $tag

