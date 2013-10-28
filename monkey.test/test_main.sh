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

if [ ! -f "$TEST_CONFIG" ]
then
    echo "You must set the evn $TEST_CONFIG"
    echo "example: TEST_CONFIG=test-config/test.config ./test_main.sh"
    exit 1
fi

. ./system.config
. $TEST_CONFIG

#get passwd
echo -n "Enter your password:"
read -s passwd
echo

# check passwd
echo $passwd | sudo -S echo 
error_test $? $0 $LINENO

export passwd

./check_adb.sh
error_test $? $0 $LINENO

case "$TEST_VERSION" in
"release")
    if [ $NEED_GET_IMAGE = "y" ]
    then
        ./get_image.sh
        error_test $? $0 $LINENO
    fi
    
    if [ $NEED_FLASH = "y" ]
    then
        echo $passwd | sudo -S env PATH=$PATH TEST_CONFIG=$TEST_CONFIG ./flash.sh
        error_test $? $0 $LINENO
        sudo -K
    fi
    ;;
"daily")
    [ "$NEED_REBUILD_ALL" = "y" ] && ./env_pre.sh --passwd $passwd
    error_test $? $0 $LINENO
    ./build_symb.sh
    ;;
"local")
    ./build_symb.sh
    ;;
"custom"*)
    [ -f "$CUSTOM_IMG_SC" ] || error_test 1 $0 $LINENO
    ./$CUSTOM_IMG_SC
    error_test $? $0 $LINENO

    [ -f "$CUSTOM_FLASH_SC" ] || error_test 1 $0 $LINENO
    echo $passwd | sudo -S env PATH=$PATH TEST_CONFIG=$TEST_CONFIG ./$CUSTOM_FLASH_SC
    error_test $? $0 $LINENO
    ;;
*)
    ;;
esac

#after flash, we need to make sure that adb is job well
./check_adb.sh
error_test $? $0 $LINENO

#test
./test_loop.sh
error_test $? $0 $LINENO

