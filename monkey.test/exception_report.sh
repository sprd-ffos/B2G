#!/bin/bash

. ./system.config
. ./test.config
. $DEVICE_CONFIG


./kill_orng.sh

#gen time tag
tag=${EXLOGHEAD}-${DEV_NAME}-${TEST_VERSION}-$(cat /etc/hostname)-$(date +%y%m%d%H%M$S)

mkdir $tag

$ADB pull /proc/last_kmsg $tag

#manifest.xml
cp ${IMAGE_FOLDER}/manifest.xml ${tag}/

if [ $TEST_VERSION = "daily" ]
then
    #cp .config and .userconfig
    cp ../.config ${tag}/config
    cp ../.userconfig ${tag}/userconfig
fi

#tar files
tar -caf ${tag}.tar.bz2 ${tag}/*

rm -rf $tag

