#!/bin/bash

usage ()
{
    echo "Usage: $(basename $0) yymmdd"
    exit $1
}

log_date=

if [ $# -eq 0 ]
then
    log_date=$(date +%y%m%d)
elif [ $# -eq 1 ]
then
    [[ "$1" == [0-9][0-9][0-9][0-9][0-9][0-9] ]] || usage 1
    log_date=$1
else
    usage 1
fi

yesterday=$(date --date="20$log_date yesterday" +%y%m%d)
[ $? -eq 0 ] || usage 1

output=/home/mtlog/mtlog/report-daily/r${log_date}
mkdir -p $output
echo log daily report: ${yesterday}0800 ${log_date}0800 > ${output}/summary

echo "please waiting..."

summary=$($(dirname $0)/log_distribute.sh --log-dir /home/mtlog/mtlog --output-dir $output --date-from ${yesterday}0800 --date-to ${log_date}0800)

dsummary=/home/mtlog/mtlog/report-daily/daily-summary
[ -f $dsummary ] || >$dsummary

[ $(( $(cat $dsummary | wc -l) % 11 )) -eq 0 ] && printf "Date\tNow\tLast\tAll\tTotal\tMinidump\tCoredump\tException\tNul\tTotal\n" >> $dsummary
printf "$log_date\t$summary\n" >> $dsummary
