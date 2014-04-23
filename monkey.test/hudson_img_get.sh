#!/bin/bash

. ./system.config
. $TEST_CONFIG
#1 get img from hunson
#2 follow the tar file struct to extract the files
#3 put the files to the image folder, use flash.sh to flash them

# hudson file struct
# file type *.tar.gz
# file struct -
#boot.img
#fdl1.bin
#fdl2.bin
#objdir-gecko/
#ramdisk-recovery.img
#ramdisk.img
#recovery.img
#symbols/
#system/
#system.img
#u-boot-spl-16k.bin
#u-boot.bin
#u-boot_autopoweron.bin
#userdata.img
# we need boot/system/2ndbl/vmjaluna/userdata img and symbols(objdir-gecko/dist/crashreporter-symbols/)
# vmjaluna is not necessary

#1 wget $URL
[ -n "$HUDSON_FILE_URL" ] || exit 1
[[ "$HUDSON_FILE_URL" == */*.tar.gz ]] || exit 1
pac_file=${HUDSON_FILE_URL##*/}
[ -f $pac_file ] && rm -f $pac_file
wget $HUDSON_FILE_URL
[ $? -eq 0 ] || exit 1

#2 get file and extract the need partitions
[ -d $IMAGE_FOLDER ] && rm -rf $IMAGE_FOLDER
mkdir $IMAGE_FOLDER
#tar
tar -xaf $pac_file -C $IMAGE_FOLDER
[ $? -eq 0 ] || exit 1

rm $pac_file

exit 0
