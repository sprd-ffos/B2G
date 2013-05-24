#!/bin/bash

#extract.sh - extract the feature of a crash report
#we follow the monkey test's report, so input file is *.tar.bz2
#1 we find the dump_parse file from the tar file, if it hasn't, we mark the
# report to no-dmp, and drop the report. Maybe mv the useless report to a
# folder is a good idea.
#2 extract the dump_parse file from the tar file
#3 get the below informations:
#  1 crash reason
#  2 crash address
#  3 crash thread id
#4 abstract the simplest stact of crashed thread to a file which named 
# follow the report. We will take all the stack in a folder

#exit code
#1 - common error
#2 - error tar file
#3 - no dmp file
#4 - size of dmp file is 0
#5 - dmp file is incomplete

. ./crdb.config

trap 'rm -rf $report_name' EXIT

#usage, if exit with error then use "usage 1", or "usage 0"
usage()
{
    echo "Usage: $(basename $0) --report report [--help]"
    exit $1
}

#options
report=

#get options
while [ $# -gt 0 ]
do
    case $1 in
    --report)
        shift
        report=$1
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

[ -n "$report" ] || usage 1
[ -f $report ] || usage 1

tar -tf $report > /dev/null 2>&1
if [ $? -ne 0 ]
then
    echo $report not  a \"*.tar.bz2\" file
    exit 2 
fi

[ -d $STACK_FOLDER ] || mkdir -p $STACK_FOLDER

pf_name=$(tar -tf $report | grep dump_parse)

if [ -z "$pf_name" ]
then
    echo no dmp file.
    exit 3
fi

report_name=$(echo $pf_name | awk -F/ '{print $1}')

tar -xaf $report $pf_name
[ $? -eq 0 ] || exit 1

[ -s $pf_name ] || exit 4

reason=$(grep -P '^Crash reason:' $pf_name | awk -F: '{print $2}' | sed 's/ //g')
[ -n "$reason" ] || exit 5
address=$(grep -P '^Crash address:' $pf_name | awk -F: '{print $2}' | sed 's/ //g')
[ -n "$address" ] || exit 5
thread=$(grep -P '^Thread \d+ \(crashed\)' $pf_name | grep -Po '\d+')
[ -n "$thread" ] || exit 5

#abstract the stack to stack folder
sed -nE '/^Thread [0-9]+ \(crashed\)$/,/^Thread [0-9]+$/ {/^ *[0-9]+/p}' $pf_name |\
    sed 's/^ *//' | awk '{print $2}' > ${STACK_FOLDER}/${report_name}

#output the feature
echo "$report_name:$reason:$address:$thread"

