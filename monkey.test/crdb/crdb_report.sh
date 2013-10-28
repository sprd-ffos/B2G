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

[ -f $STACK_FILTER_CONFIG ] || > $STACK_FILTER_CONFIG

last_is_sim=n
last_sim=

#clean report
>$CRASH_REPORT

echo '<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head><title>crash report</title></head>
<body>
<h3>'Crash report $options'</h3>
<p>' >> $CRASH_REPORT

tree $DB_FOLDER | grep "${LOGHEAD}-" | while read line
do
    if [[ "$line" == *-sim ]]
    then
        last_is_sim=y
        last_sim=$line
        continue
    fi

    cr=$(echo $line | grep -Po '\b'$LOGHEAD'-\w+-\w+-\w+-\d+\b')

    if [ -n "$cr" ]
    then
        cdev=$(echo $cr | awk -F- '{print $2}')
        cver=$(echo $cr | awk -F- '{print $3}')
        cusr=$(echo $cr | awk -F- '{print $4}')
        ctime=$(echo $cr | awk -F- '{print $5}')
    else
        cr=$(echo $line | grep -Po '\b'$LOGHEAD'-\w+-\w+-\d+\b')
        [ -n "$cr" ] || continue
        cdev=$(echo $cr | awk -F- '{print $2}')
        cver=
        cusr=$(echo $cr | awk -F- '{print $3}')
        ctime=$(echo $cr | awk -F- '{print $4}')
    fi
    
    if [ -n "$dev" ]
    then
        [ "$cdev" = "$dev" ] || continue
    fi

    if [ -n "$ver" ]
    then
        [ -n "$cver" ] || continue
        [ "$cver" = "$ver" ] || continue
    fi
    
    if [ -n "$usr" ]
    then
        foo=$(echo $cusr | grep -i "$usr") 
        [ $? -eq 0 ] || continue
    fi
    
    if [ -n "$from" ]
    then
        [ "$from" -le "$ctime" ] || continue
    fi

    if [ -n "$to" ]
    then
        [ "$ctime" -le "$to" ] || continue
    fi

    if [ "$last_is_sim" = "y" ]
    then
        [[ "$line" == "│"* ]] && echo '<br>'$last_sim >> $CRASH_REPORT
    fi

    #get cr tips
    for stack in $(cat $(find $DB_FOLDER -name "$cr"))
    do
        foo=$(grep -F $stack $STACK_FILTER_CONFIG)
        [ $? -eq 0 ] && continue
        tip=$stack
        break
    done

    #get rid of special characters
    tip=$(echo $tip | sed 's/</_/g')
    tip=$(echo $tip | sed 's/>/_/g')

    echo '<br>'$line "["$tip"]" >> $CRASH_REPORT

    last_is_sim=n
done

echo '</p>
</body>
</html>' >> $CRASH_REPORT

perl -i -pe 's#('$LOGHEAD'-\w+(-\w+)?-\w+-\d+)#<a href="'$STACK_FOLDER'/$1">$1</a>[<a href="'$TAR_FOLDER'/$1.tar.bz2">Detail</a>]#' $CRASH_REPORT

firefox $CRASH_REPORT

