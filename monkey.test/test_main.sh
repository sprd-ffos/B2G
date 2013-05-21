#!/bin/bash

#0 adb check
#1 get the release
#2 flash image
#3 adb check
#4 push files which are the test needs
#5 run test
#6 check crash report
#7 make log
#8 pull report & log
#9 reboot and start next test

. ./system.config
. ./test.config

#get passwd
echo -n "Enter your password:"
read -s passwd
echo

./check_local_file.sh
error_test $? $0 $LINENO

./check_adb.sh $passwd
error_test $? $0 $LINENO

if [ "$IS_LOCAL_TEST" = "y" ]
then
    [ "$NEED_REBUILD_ALL" = "y" ] && ./env_pre.sh --passwd $passwd
    ./build_symb.sh
else
    if [ $NEED_GET_IMAGE = "y" ]
    then
        ./get_image.sh
        error_test $? $0 $LINENO
    fi
    
    if [ $NEED_FLASH = "y" ]
    then
        echo $passwd | sudo -S ./flash.sh 
        error_test $? $0 $LINENO
        sudo -K
    fi
fi

#after flash, we need to make sure that adb is job well
./check_adb.sh $passwd
error_test $? $0 $LINENO

#test
./test_loop.sh
error_test $? $0 $LINENO

