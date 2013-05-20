#!/bin/bash

#get current release image from server

. ./system.config
. ./test.config
. $IMAGE_SERVER_CONFIG
. ./local_image.config

[ -d $IMAGE_FOLDER ] && rm -rf $IMAGE_FOLDER
mkdir $IMAGE_FOLDER

for partition in ${image_list[*]}
do
    ./pscp.sh --passwd $image_passwd -c "$image_user@$image_server:$image_folder/$partition.img $IMAGE_FOLDER/"
    error_test $? $0 $LINENO
done

./pscp.sh --passwd $image_passwd -c "$image_user@$image_server:$image_folder/manifest.xml $IMAGE_FOLDER/"
