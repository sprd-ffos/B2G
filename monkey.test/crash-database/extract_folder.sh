#!/bin/bash

#extract a folder's all mtlog-*.tar.bz2 files

#usage, if exit with error then use "usage 1", or "usage 0"
usage()
{
    echo "Usage: $(basename $0) --folder folder [--help]"
    exit $1
}

#options
folder=

#get options
while [ $# -gt 0 ]
do
    case $1 in
    --folder)
        shift
        folder=$1
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

[ -n "$folder" ] || usage 1
[ -d $folder ] || usage 1

. ./crdb.config

#public folder and file
[ -d $STACK_FOLDER ] || mkdir $STACK_FOLDER

FILE_PATTERN=mtlog-*.tar.bz2

> $NEW_FEATURE_FILE
> $NEW_WRONG_FILE
> $NEW_NO_DMP

find $folder -name "$FILE_PATTERN" | while read cr
do
    feature=$(./extract.sh --report $cr)
    case "$?" in
    "0")
        echo $feature >> $NEW_FEATURE_FILE
        ;;
    "2")
        echo ${cr##*/} >> $NEW_WRONG_FILE 
        ;;
    "3")
        echo ${cr##*/} >> $NEW_NO_DMP 
        ;;
    "4")
        echo ${cr##*/} >> $NEW_DMP_SIZE_0
        ;;
    "5")
        echo ${cr##*/} >> $NEW_DMP_INCOMPLETE 
        ;;
    *)
        ;;
    esac
done

