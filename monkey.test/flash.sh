#!/bin/bash

#flash image to device

. ./system.config
. ./test.config
. ./local_image.config

trap 'exit 1' ERR

update_time()
{
	TIMEZONE=`date +%Z%:::z|tr +- -+`
	echo Attempting to set the time on the device
	$ADB wait-for-device &&
	$ADB shell toolbox date `date +%s` &&
	$ADB shell setprop persist.sys.timezone $TIMEZONE
}

#add a protect, for the reboot is so dangerouse
[ -n "$ADB" ] || exit 1

#flash_fastboot nounlock $PROJECT
$ADB reboot bootloader
$FASTBOOT devices

$FASTBOOT erase cache && $FASTBOOT erase userdata

image_list=("boot" "system" "2ndbl" "vmjaluna" "userdata")

for partition in ${image_list[*]}
do
    image=$IMAGE_FOLDER/${partition}.img
    if [ -e $image ]
    then
        $FASTBOOT flash $partition $image
    fi
done

$FASTBOOT reboot && update_time

