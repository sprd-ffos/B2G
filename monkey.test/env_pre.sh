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

trap 'exit 1' ERR

#clean, get, build and flash
cd ..
git clean -df
git reset --hard HEAD
git fetch origin
git checkout origin/sprdroid4.0.3_vlx_3.0_b2g

#./config.sh $DEV_PROJECT
expect -c "

spawn ./config.sh $DEV_PROJECT
set timeout -1 
expect {
    \"Your Name *:\" {send \"\r\"; exp_continue}
    \"Your Email *:\" {send \"\r\"; exp_continue}
    \"is this correct *?\" {send \"y\r\"; exp_continue}
}"

repo forall -c 'git clean -df && git reset --hard HEAD'

#save manifest.xml 
[ -d $IMAGE_FOLDER ] && rm -rf $IMAGE_FOLDER
mkdir $IMAGE_FOLDER
repo manifest -o ${IMAGE_FOLDER}/manifest.xml -r

#auto patch
auto_patch=./patch.sprd/auto_patch.sh
if [ -f $auto_patch ]
then
    $auto_patch $DEV_PROJECT
fi

rm -rf ./out
rm -rf ./objdir-gecko
./build.sh

#sudo ./flash.sh
echo $passwd | sudo -S ./flash.sh 
sudo -K
