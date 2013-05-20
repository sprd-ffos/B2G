#!/bin/bash

#call test once script to run test
. ./system.config
. ./test.config

#push files before test
./push_test_files.sh
error_test $? $0 $LINENO

while true
do
    #reboot firt, make a clean env
    $ADB reboot
    $ADB wait-for-device

    #test once
    #if test completed, enter next test
    #if test error, try to fix it, and go on test
    ./test_once.sh
    #if exception, we get demsg
    if [ $? -ne 0 ]
    then
        $ADB wait-for-device

        ./exception_report.sh
        ./push_report.sh
    fi
done
