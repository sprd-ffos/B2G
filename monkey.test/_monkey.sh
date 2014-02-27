#!/bin/bash

usage() {
    echo "usage: $0 <config-file> [image] [flash] [test] [log]"
    exit $1
}

([ $# -eq 0 ] || [ ! -f "$1" ]) && usage 1

config_file=$1
shift

if [ $# -eq 0 ]
then
    do_image=YES
    do_flash=YES
    do_test=YES
else
    while [ $# -gt 0 ]
    do
        case "$1" in
        "image")
            do_image=YES
            shift
            ;;
        "flash")
            do_flash=YES
            shift
            ;;
        "test")
            do_test=YES
            shift
            ;;
        "log")
            do_log=YES
            shift
            ;;
        *)
            usage 1
            ;;
        esac
    done
fi

export MONKEYLOGFILE="monkey.log"
> $MONKEYLOGFILE

. $config_file
. _source_config_check.sh

#get passwd
echo -n "Enter your password:"
read -s passwd
echo
#check passwd
echo $passwd | sudo -S echo -n
[ $? -ne 0 ] && log "[ERROR]$0($LINENO) passwd" && exit 1
#export passwd
export passwd

./_dev_check.sh
[ $? -ne 0 ] && log "[ERROR]$0($LINENO) dev check" && exit 1

if [ "$do_image" == "YES" ]
then
    ./_image.sh
    [ $? -ne 0 ] && log "[ERROR]$0($LINENO) image" && exit 1
fi

if [ "$do_flash" == "YES" ]
then
    ./_flash.sh
    [ $? -ne 0 ] && log "[ERROR]$0($LINENO) flash" && exit 1
fi

if [ "$do_test" == "YES" ]
then
    ./_test_prepare.sh
    [ $? -ne 0 ] && log "[ERROR]$0($LINENO) test prepare" && exit 1
    ./_test.sh
    [ $? -ne 0 ] && log "[ERROR]$0($LINENO) test" && exit 1
fi

if [ "$do_test" != "YES" ] && [ "$do_log" == "YES" ]
then
    export MTCFG_LOG_TAR=NO
    ./_log.sh "manual"
    [ $? -ne 0 ] && log "[ERROR]$0($LINENO) log" && exit 1
fi
