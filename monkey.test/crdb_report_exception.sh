#!/bin/bash

. ./system.config
. ./crdb.config

[ -d $DB_FOLDER ] || exit 1

#cd $DB_FOLDER
#tree -H $DB_FOLDER > ../$CRASH_REPORT 
#cd ..
#
#firefox $CRASH_REPORT

usage()
{
    echo "Usage: $(basename $0) --dev device --ver ver --usr user --time-from time --time-to time [--help|-h]"
    echo "    --dev, the test device, i.e. tara"
    echo "    --ver, the image is *release* version or *local* version"
    echo "    --usr, the tester flag, we use the tester's hostname, i.e. LianxiangZhouubt"
    echo "    --time-from, the begin of time-filter, format yymmddHHMM"
    echo "    --time-to, the end of time-filter, format yymmddHHMM"
    exit $1
}

options=$*

while [ $# -gt 0 ]
do
    case $1 in
    --dev)
        shift
        dev=$1
        ;;
    --ver)
        shift
        ver=$1
        ;;
    --usr)
        shift
        usr=$1
        ;;
    --time-from)
        shift
        from=$1
        ;;
    --time-to)
        shift
        to=$1
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

[[ "$from" == *[!0-9]* ]] && usage 1
[[ "$to" == *[!0-9]* ]] && usage 1

#clean EXCEPTION_REPORT
>$EXCEPTION_REPORT

echo '<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head><title>exception report</title></head>
<body>
<h3>'Exception report $options'</h3>
<p>' >> $EXCEPTION_REPORT

ls -1 $EXLOG_TAR_FOLDER | while read line
do
    cr=$(echo $line | grep -Po '\b'$EXLOGHEAD'-\w+-\w+-\w+-\d+\b')

    cdev=$(echo $cr | awk -F- '{print $2}')
    
    if [ -n "$dev" ]
    then
        [ "$cdev" = "$dev" ] || continue
    fi

    cver=$(echo $cr | awk -F- '{print $3}')
    
    if [ -n "$ver" ]
    then
        [ "$cver" = "$ver" ] || continue
    fi

    cusr=$(echo $cr | awk -F- '{print $4}')
    
    if [ -n "$usr" ]
    then
        foo=$(echo $cusr | grep -i "$usr") 
        [ $? -eq 0 ] || continue
    fi

    ctime=$(echo $cr | awk -F- '{print $5}')
    
    if [ -n "$from" ]
    then
        [ "$from" -le "$ctime" ] || continue
    fi

    if [ -n "$to" ]
    then
        [ "$ctime" -le "$to" ] || continue
    fi

    echo '<br>'$cr >> $EXCEPTION_REPORT
done

echo '</p>
</body>
</html>' >> $EXCEPTION_REPORT

perl -i -pe 's#('$EXLOGHEAD'-\w+-\w+-\w+-\d+)#<a href="'$EXLOG_TAR_FOLDER'/$1.tar.bz2">$1</a>#' $EXCEPTION_REPORT

firefox $EXCEPTION_REPORT

