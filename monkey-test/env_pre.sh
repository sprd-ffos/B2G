#!/bin/bash

#prepare the clean run environment for test

#options
passwd=
dev=sp8810eabase_512x256_hvga

usage()
{
    echo "Usage: $(basename $0) --passwd passwd --dev dev_name [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --passwd)
        shift
        passwd=$1
        ;;
    --dev)
        shift
        dev=$1
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

#clean, get, build and flash
cd ..
git clean -df
git reset --hard HEAD
git fetch origin
git checkout origin/sprdroid4.0.3_vlx_3.0_b2g

#./config.sh $dev
expect -c "

spawn ./config.sh $dev
set timeout -1 
expect {
    \"Your Name *:\" {send \"\r\"; exp_continue}
    \"Your Email *:\" {send \"\r\"; exp_continue}
    \"is this correct *?\" {send \"y\r\"; exp_continue}
}
expect eof"

repo forall -c 'git clean -df && git reset --hard HEAD'

#./config.sh $dev twice, avoid first config abort
expect -c "

spawn ./config.sh $dev
set timeout -1 
expect {
    \"Your Name *:\" {send \"\r\"; exp_continue}
    \"Your Email *:\" {send \"\r\"; exp_continue}
    \"is this correct *?\" {send \"y\r\"; exp_continue}
}
expect eof"

#auto patch
auto_patch=./patch.sprd/auto_patch.sh
if [ -f $auto_patch ]
then
    $auto_patch $dev
fi

rm -rf ./out
rm -rf ./objdir-gecko
./build.sh

#sudo ./flash.sh
expect -c "

spawn sudo ./flash.sh
set timeout -1 
expect {
    \"*sudo* password for *:\" {send \"$passwd\r\"; exp_continue}
}
expect eof"

#adb check
./adb_check.sh $passwd
[ $? -ne 0 ] && exit 1

