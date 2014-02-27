#!/bin/bash

#*!!!*This script must call by 'sudo <this-file>'

. _source_config_check.sh

trap 'exit 1' ERR

if [ ! -d $MTCFG_IMG_FOLDER ]
then
    log "[ERROR]No image folder: $MTCFG_IMG_FOLDER"
    exit 1
fi

FASTBOOT=bin/fastboot
[ -f "$FASTBOOT" ]

echo $passwd | sudo -S echo -n

$ADB reboot-bootloader
while true
do
    sudo $FASTBOOT devices | grep -P '^\d+\s+fastboot'  && break
    sleep 1
done

[ -n "$MTCFG_FLASH_IMGS" ] || MTCFG_FLASH_IMGS=("2ndbl" "boot" "system" "userdata")

for partition in ${MTCFG_FLASH_IMGS[*]}
do
    case "$partition" in
    "2ndbl")
        image=$MTCFG_IMG_FOLDER/u-boot.bin
        ;;
    *)
        image=$MTCFG_IMG_FOLDER/${partition}.img
        ;;
    esac

    if [ -e "$image" ]
    then
        sudo $FASTBOOT flash $partition $image
    fi
done

sudo $FASTBOOT reboot
$ADB wait-for-device

echo We will wait 60s for device run stable. If you want take the device and stop script, you can.
sleep 60
