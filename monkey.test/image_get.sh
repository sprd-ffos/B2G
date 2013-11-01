#!/bin/bash

#get current release image from server

. ./system.config
. $TEST_CONFIG
. $IMAGE_SERVER_CONFIG

[ -d $IMAGE_FOLDER ] && rm -rf $IMAGE_FOLDER

./ssh_passwd.sh --passwd $image_passwd -c "scp $image_user@$image_server:$image_folder/$image_package ./$IMAGE_FOLDER.tar.bz2"

[ -f $IMAGE_FOLDER.tar.bz2 ] || exit 1

tar -xf $IMAGE_FOLDER.tar.bz2
[ $? -eq 0 ] || exit 1

rm $IMAGE_FOLDER.tar.bz2 

