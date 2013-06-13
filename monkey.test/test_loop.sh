#!/bin/bash

#call test once script to run test
. ./system.config
. ./test.config

#push files before test
./push_test_files.sh
error_test $? $0 $LINENO

#double check -
#adb
$ADB shell echo >/dev/null 2>&1
error_test $? $0 $LINENO
#busybox
foo=$($ADB shell $BUSYBOX | grep ': not found' | wc -l)
[ $foo -eq 1 ] && error_test 1 $0 $LINENO
#gsnap
foo=$($ADB shell $GSNAP | grep ': not found' | wc -l)
[ $foo -eq 1 ] && error_test 1 $0 $LINENO

while true
do
    #reboot firt, make a clean env
    $ADB reboot
    $ADB wait-for-device

    #wait for system run stable...
    tick=120
    echo -n "Wait for system run stable ."
    while [ $tick -gt 0 ]
    do
        echo -n "."
        tick_part=3
        sleep $tick_part
        tick=$(( tick - tick_part ))
    done
    #give a newline
    echo

    #test once
    #if test completed, enter next test
    #if test error, try to fix it, and go on test
    ./test_once.sh
    #if exception, we get demsg
    if [ $? -ne 0 ]
    then
        $ADB wait-for-device

        ./exception_report.sh
        [ $? -eq 0 ] && ./push_report.sh
    fi
done
