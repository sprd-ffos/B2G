#!/bin/bash

. _source_config_check.sh

[ "$MTCFG_IMG_GET" == "NONE" ] && exit 0

trap 'exit 1' ERR

case "$MTCFG_IMG_GET" in
"URL")
    [ -n "$MTCFG_IMG_URL" ]
    [[ "$MTCFG_IMG_URL" == */*.tar.* ]]
    tar_file=${MTCFG_IMG_URL##*/}
    [ -f $tar_file ] && rm -f $tar_file
    wget $MTCFG_IMG_URL
    ;;

"SSHFS")
    #to do... scp from server
    ;;
"FS")
    #to do... cp from local
    ;;
esac

if [[ "$tar_file" == *.tar.* ]]
then
    [ -d $MTCFG_IMG_FOLDER ] && rm -rf $MTCFG_IMG_FOLDER
    mkdir $MTCFG_IMG_FOLDER
    tar -xaf $tar_file -C $MTCFG_IMG_FOLDER
    rm $tar_file
fi

