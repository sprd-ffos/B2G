#!/bin/bash

#usage, if exit with error then use "usage 1", or "usage 0"
usage()
{
    echo "Usage: $(basename $0) --log-dir <log dir> --type [now|last|all] --dev <dev> --ver <ver> --mode [release|custom*] --tester <tester> --date-from <yymmddHHMM> --date-to <yymmddHHMM> [--help|-h]"
    echo "  --type [now|last|all], filter log by type, the type was manual defined"
    echo "      now, logs catch in this reboot"
    echo "      last, logs for last reboot"
    echo "      all, logs for both above two"
    echo "  --dev <dev>, the string get from device by 'getprop ro.product.device'"
    echo "  --ver <ver>, the string get from device by 'getprop ro.build.version.incremental'"
    echo "  --mode [release|custom*], the config mode, such as release, daily, local and so on"
    echo "  --tester <tester>, the string get from tester machine by 'cat /etc/hostname'"
    echo "  --date-from <yymmddHHMM>"
    echo "  --date-to <yymmddHHMM>, filter the logs by date, the format must be full of yymmddHHMM"
    echo ""
    echo "  <dev>, <mode>, <tester>, can use wildcard as shell, for example: ? and *"
    exit $1
}

#options
log_dir=
log_type=
dev=
ver=
mode=
tester=
date_from=
date_to=

#get options
while [ $# -gt 0 ]
do
    case $1 in
    --log-dir)
        shift
        [ -d "$1" ] || usage 1
        log_dir=$1
        ;;
    --type)
        shift
        log_type=$1
        [ "$log_type" == "now" ] || [ "$log_type" == "last" ] || [ "$log_type" == "all" ] || usage 1
        ;;
    --dev)
        shift
        dev=$1
        ;;
    --ver)
        shift
        ver=$1
        ;;
    --mode)
        shift
        mode=$1
        ;;
    --tester)
        shift
        tester=$1
        ;;
    --date-from)
        shift
        [[ "$1" == *[!0-9]* ]] && usage 1
        date_from=$1
        ;;
    --date-to)
        shift
        [[ "$1" == *[!0-9]* ]] && usage 1
        date_to=$1
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

[ -n "$log_dir" ] || log_type="."
[ -n "$log_type" ] || log_type="*"
if [ -n "$dev" ]
then
    dev=$(echo $dev | sed 's/-/_/g')
else
    dev="*"
fi
if [ -n "$ver" ]
then
    ver=$(echo $ver | sed 's/-/_/g')
else
    ver="*"
fi
if [ -n "$mode" ]
then
    mode=$(echo $mode | sed 's/-/_/g')
else
    mode="*"
fi
if [ -n "$tester" ]
then
    tester=$(echo $tester | sed 's/-/_/g')
else
    tester="*"
fi

files=mtlog-$log_type-$dev-$ver-$mode-$tester-*

find $log_dir -iname "${files}.tar.bz2" | while read file
do
    file_name=${file##*/}
    file_raw=${file_name%%.*}
    log_date=${file_raw##*-}

    if [ -n "$date_from" ]
    then
        [ "$date_from" -lt "$log_date" ] || continue
    fi

    if [ -n "$date_to" ]
    then
        [ "$log_date" -gt "$date_to" ] || continue
    fi

    tar -xavf $file ${file_raw}/log_parse > /dev/null 2>&1
    [ $? -eq 0 ] || continue
    [ -f ${file_raw}/log_parse ] || continue

    echo "----> $file_name"
    cat ${file_raw}/log_parse
    rm -rf ${file_raw}

done

exit 0
