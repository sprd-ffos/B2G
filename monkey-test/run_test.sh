#!/bin/bash

#run test...

trap 'pkill unlock.sh' EXIT
. ./set_gsnap.sh
ADB=adb
config=
foo=${DEV:=dev}
TICK=10
HOME_TICK=120
hometick=$HOME_TICK

usage()
{
    echo "Usage: $(basename $0) --config config_file [--no-symbols] [--test-app] [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --no-symbols | --no-symb | -s)
        no_symb=yes
        ;;
    --config)
        shift
        config=$1
        ;;
    --test-app)
        test_app=yes
        ;;
    --help | -h)
        usage 0
        ;;
    -*)
        echo "Unrecognized option $1"
        usage 1
        ;;
    *)
        break
        ;;
    esac

    shift
done

if [ -z $config ]
then
   echo "Please give a config file for test."
   usage 1
fi

if [ ! -f $config ]
then
    echo [ERROR!!] File $config does not exist!
    exit 1
fi

#build symbols
[ "$no_symb" = "yes" ] || ./build_symb.sh 

. $config

if [ "$UNLOCK" = "y" ]
then
    $ADB push ./sc/unlock_${VGA}.sc /data
fi

$ADB shell "echo tap $HOMEX $HOMEY 3 200 > /data/home.sc"

while true
do
       
    #crash report
    ./crash_report.sh --dev $DEV --usr $(cat /etc/hostname)
    if [ $? -eq 0 ]
    then
        pkill unlock.sh

        #push crash report to server
        ./push_report.sh --dev $DEV
	
        $ADB reboot
        #wait for restart device
        sleep 60

        
     else
	$ADB shell mv /data/2.jpg /data/1.jpg
	$ADB shell $GSNAP /data/2.jpg /dev/graphics/fb0
    fi

    if [ "$UNLOCK" = "y" ]
    then
        pgrep unlock.sh > /dev/null || ./unlock.sh $VGA --tsdev $TOUCHSCREEN_DEV --keydev $KEYPAD_DEV --key $POWERKEY &
    fi

    sleep $TICK

    if [ $hometick -le 0 ]
    then
        hometick=$HOME_TICK
        [ "$UNLOCK" = "y" ] && $ADB shell /data/orng $TOUCHSCREEN_DEV /data/unlock_${VGA}.sc
        sleep 1
        $ADB shell /data/orng $TOUCHSCREEN_DEV /data/home.sc
    else
        hometick=$(( hometick - TICK ))
    fi

    #running
    ./orng_run.sh $TOUCHSCREEN_DEV
    [ $? -ne 0 ] && exit 1
done

