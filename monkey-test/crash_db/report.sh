#!/bin/bash

. ./crdb.config

[ -d $DB_FOLDER ] || exit 1

#cd $DB_FOLDER
#tree -H $DB_FOLDER > ../$CRASH_REPORT 
#cd ..
#
#firefox $CRASH_REPORT

usage()
{
    echo "Usage: $(basename $0) --dev device --usr user --time-from time --time-to time [--help|-h]"
    echo "    --dev, the test device, i.e. tara"
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

report=$CRASH_REPORT

last_is_sim=n
last_sim=

echo '<html>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<head><title>crash report</title></head>
<body>
<h3>'Crash report $options'</h3>
<p>' >> $report

tree $DB_FOLDER | grep "mtlog-" | while read line
do
    if [[ "$line" == *-sim ]]
    then
        last_is_sim=y
        last_sim=$line
        continue
    fi

    cr=$(echo $line | grep -Po '\bmtlog-\w+-\w+-\d+\b')

    cdev=$(echo $cr | awk -F- '{print $2}')
    
    if [ -n "$dev" ]
    then
        [ "$cdev" = "$dev" ] || continue
    fi

    cusr=$(echo $cr | awk -F- '{print $3}')
    
    if [ -n "$usr" ]
    then
        [ "$cusr" = "$usr" ] || continue
    fi

    ctime=$(echo $cr | awk -F- '{print $4}')
    
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
        [[ "$line" == "│"* ]] && echo '<br>'$last_sim >> $report
    fi

    echo '<br>'$line >> $report

    last_is_sim=n
done

echo '</p>
</body>
</html>' >> $report

perl -i -pe 's#(mtlog-\w+-\w+-\d+)#<a href="stack/$1">$1</a>#' $report

firefox $report

