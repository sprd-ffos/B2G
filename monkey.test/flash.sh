#!/bin/bash

#flash image to device

. ./system.config
. $TEST_CONFIG

trap 'exit 1' ERR

update_time()
{
	TIMEZONE=`date +%Z%:::z|tr +- -+`
	echo Attempting to set the time on the device
	$ADB wait-for-device && sleep 10 && $ADB root &&
    sleep 10 && $ADB remount && sleep 10 &&
	$ADB shell toolbox date `date +%s` &&
	$ADB shell setprop persist.sys.timezone $TIMEZONE
}

#add a protect, for the reboot is so dangerouse
[ -n "$ADB" ] || exit 1
#flash_fastboot nounlock $PROJECT
$ADB reboot bootloader
while true
do
    [ $($FASTBOOT devices|wc -l) -gt 0 ] && break
done

image_list=("boot" "system" "2ndbl" "vmjaluna" "userdata")

for partition in ${image_list[*]}
do
    case "$partition" in
    "2ndbl")
        image=$IMAGE_FOLDER/u-boot.bin
        ;;
    "vmjaluna")
        image=$IMAGE_FOLDER/vmjaluna.image
        ;;
    *)
        image=$IMAGE_FOLDER/${partition}.img
        ;;
    esac

    if [ -e $image ]
    then
        $FASTBOOT flash $partition $image
    fi
done

$FASTBOOT reboot && update_time

