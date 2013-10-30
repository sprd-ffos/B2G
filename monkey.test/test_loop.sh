#!/bin/bash

#call test once script to run test
. ./system.config
. $TEST_CONFIG

trap 'log_file "End looping test."' EXIT
log_file "Begin looping test."

#check passw
echo $passwd | sudo -S echo 
error_test $? $0 $LINENO

$ADB wait-for-device && sleep 10 && $ADB root
$ADB wait-for-device && sleep 10 && $ADB remount
$ADB wait-for-device

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
    $ADB wait-for-device && $ADB reboot
    $ADB wait-for-device && sleep 10 && $ADB root
    $ADB wait-for-device && sleep 10 && $ADB remount
    $ADB wait-for-device

    #wait for system run stable...
    tick=60
    tick_part=3
    echo -n "Wait for system run stable ."
    while [ $tick -gt 0 ]
    do
        echo -n "."
        sleep $tick_part
        tick=$(( tick - tick_part ))
    done
    #give a newline
    echo

    #coredump path set
    coredump_path=$($ADB shell mount|awk '{if($2!="/mnt/secure/asec" && $3=="vfat") print $2}'|head -n 1)/coredump
    export coredump_path
    $ADB shell mkdir -p $coredump_path
    $ADB shell "echo $coredump_path/core.%e.%p > /proc/sys/kernel/core_pattern"

    #make sure that the slog is open
    $ADB shell slogctl enable

    #test once
    #if test completed, enter next test
    #if test error, stop test. There must be bugs we can't deal...
    ./test_once.sh
    error_test $? $0 $LINENO
done
