#!/bin/bash

#crash report
#just get report, if there are...
#find the file from device
#if there are, get it and tar it, and exit 0
#or exit 1

#set $BUSYBOX
. ./set_busybox.sh
ADB=adb
FIND="$ADB shell $BUSYBOX find"
DMPDIR=/data/b2g/mozilla
DUMPTOOL=./bin/minidump_stackwalk
SYMBDIR=../objdir-gecko/dist/crashreporter-symbols

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
tag=${DEV}-${USR}-$(date +%y%m%d%H%M$S)

mkdir $tag

#dump files
$FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | sed 's/\r//'| while read file
do
    #pull file
    $ADB pull "$file" $tag
    #delete dmp file
    $ADB shell rm "$file"
done

if [ -f $DUMPTOOL ] && [ -d $SYMBDIR ]
then
    $DUMPTOOL ${tag}/*.dmp $SYMBDIR > ${tag}/dump_parse
fi

#more info
cp adb_log ${tag}/
$ADB shell b2g-ps > ${tag}/b2g-ps
$ADB shell b2g-procrank > ${tag}/b2g-procrank
repo manifest -o ${tag}/manifest.xml -r

#tar files
tar -caf ${tag}.tar.bz2 ${tag}/*

rm -rf $tag

