#!/bin/bash

#prepare the clean run environment for test

. ./system.config
. ./test.config
. $DEVICE_CONFIG

usage()
{
    echo "Usage: $(basename $0) --passwd passwd [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --passwd)
        shift
        passwd=$1
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

TESTDIR=$(cd "$(dirname "$0")"; pwd)

#clean, get, build and flash
cd ..
git clean -df
git reset --hard HEAD
git fetch origin
git checkout origin/sprdroid4.0.3_vlx_3.0_b2g

repo forall -c 'git clean -df && git reset --hard HEAD'

#./config.sh $DEV_PROJECT
expect -c "

spawn ./config.sh $DEV_PROJECT
set timeout -1 
expect {
    \"Your Name *:\" {send \"\r\"; exp_continue}
    \"Your Email *:\" {send \"\r\"; exp_continue}
    \"is this correct *?\" {send \"y\r\"; exp_continue}
}"

#auto patch
auto_patch=./sprd_patch/auto_patch.sh
if [ -f $auto_patch ]
then
    $auto_patch $DEV_PROJECT
fi

#monkey_patch
monkey_patch=./sprd_patch/patch.sh
if [ -f $monkey_patch ]
then
    $monkey_patch monkey_test
fi

rm -rf ./out
rm -rf ./objdir-gecko
./build.sh
error_test $? $0 $LINENO

#sudo ./flash.sh
echo $passwd | sudo -S ./flash.sh 
error_test $? $0 $LINENO
sudo -K

#save manifest.xml 
[ -d ${TESTDIR}/$IMAGE_FOLDER ] && rm -rf ${TESTDIR}/$IMAGE_FOLDER
mkdir ${TESTDIR}/$IMAGE_FOLDER
repo manifest -o ${TESTDIR}/${IMAGE_FOLDER}/manifest.xml -r

