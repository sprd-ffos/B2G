#!/bin/bash

#crash report
#just get report, if there are...
#find the file from device
#if there are, get it and tar it, and exit 0
#or exit 1

#set $BUSYBOX
. ./set_gsnap.sh
. ./set_busybox.sh
ADB=adb
FIND="$ADB shell $BUSYBOX find"
DMPDIR=/data/b2g/mozilla
DUMPTOOL=./bin/minidump_stackwalk
SYMBDIR=../objdir-gecko/dist/crashreporter-symbols
LOGHEAD=mtlog
TOMBSTONES=/data/tombstones

#options
DEV=dev
USR=usr

usage()
{
    echo "Usage: $(basename $0) [--dev dev] [--usr usr] [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --dev)
        shift
        DEV=$1
        ;;
    --usr)
        shift
        USR=$1
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

file_cnt=$($FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | wc -l)

#if no dmp file, do nothing...
if [ $file_cnt -eq 0 ]
then
    exit 1
fi
#gen time tag
tag=${LOGHEAD}-${DEV}-${USR}-$(date +%y%m%d%H%M$S)

mkdir $tag

#ganap
$ADB shell $GSNAP /data/3.jpg /dev/graphics/fb0
$ADB pull /data/3.jpg $tag
$ADB pull /data/1.jpg $tag
$ADB pull /data/2.jpg $tag

#adb log and ps
$ADB logcat > adb_log &
sleep 60
cp adb_log ${tag}/
$ADB shell b2g-ps > ${tag}/b2g-ps
$ADB shell b2g-procrank > ${tag}/b2g-procrank
$ADB shell bugreport > ${tag}/bugreport

#dump files
$FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | sed 's/\r//'| while read file
do
    #pull file
    $ADB pull "$file" $tag
    #delete dmp file
    $ADB shell rm "$file"
done

#parse files, may wait for 5 minute
if [ -f $DUMPTOOL ] && [ -d $SYMBDIR ]
then
    $DUMPTOOL ${tag}/*.dmp $SYMBDIR > ${tag}/dump_parse
fi

#generate manifest
repo manifest -o ${tag}/manifest.xml -r

#cp .config and .userconfig
cp ../.config ${tag}/config
cp ../.userconfig ${tag}/userconfig

#tombstones
$ADB pull $TOMBSTONES $tag
$ADB shell rm -r $TOMBSTONES

#tar files
tar -caf ${tag}.tar.bz2 ${tag}/*

rm -rf $tag
$ADB shell rm -rf $DMPDIR/Crash Reports/pending/*.dmp
$ADB shell rm -rf $DMPDIR/Crash Reports/pending/*.extra

