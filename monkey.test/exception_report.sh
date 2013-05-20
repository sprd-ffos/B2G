#!/bin/bash

. ./system.config
. ./test.config
. $DEVICE_CONFIG


./kill_orng.sh

if [ "$IS_LOCAL_TEST" = "y" ]
then
    VERSION="local"
else
    VERSION="release"
fi

#gen time tag
tag=${EXLOGHEAD}-${DEV_NAME}-${VERSION}-$(cat /etc/hostname)-$(date +%y%m%d%H%M$S)

mkdir $tag

$ADB pull /proc/last_kmsg $tag

#manifest.xml
cp ${IMAGE_FOLDER}/manifest.xml ${tag}/

if [ $IS_LOCAL_TEST = "y" ]
then
    #cp .config and .userconfig
    cp ../.config ${tag}/config
    cp ../.userconfig ${tag}/userconfig
fi

#tar files
tar -caf ${tag}.tar.bz2 ${tag}/*

rm -rf $tag

