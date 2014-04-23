#!/bin/bash

#*!!!*This script must call by 'sudo <this-file>'

. _source_config_check.sh

update_time()
{
    TIMEZONE=`date +%Z%:::z|tr +- -+`
	echo Attempting to set the time on the device
	$ADB wait-for-device &&
	$ADB root &&
	$ADB shell toolbox date `date +%s` &&
	$ADB shell setprop persist.sys.timezone $TIMEZONE
}

[ "$MTCFG_FLASH" == "YES" ] || exit 0

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
sudo $FASTBOOT devices

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

sudo $FASTBOOT reboot && update_time
$ADB wait-for-device

echo We will wait 60s for device run stable. If you want take the device and stop script, you can.
sleep 60
