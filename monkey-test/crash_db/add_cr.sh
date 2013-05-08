#!/bin/bash

usage()
{
    echo "Usage: $(basename $0) report"
    exit $1
}


[ $# -eq 1 ] || usage 1

report=$1

[ -n "$report" ] || usage 1
[ -f $report ] || usage 1

. ./crdb.config

> $NEW_FEATURE_FILE
> $NEW_WRONG_FILE
> $NEW_NO_DMP
> $NEW_DMP_SIZE_0
> $NEW_DMP_INCOMPLETE

feature=$(./extract.sh --report $report)

case "$?" in
"0")
    echo $feature > $NEW_FEATURE_FILE
    ;;
"2")
    echo $report > $NEW_WRONG_FILE 
    ;;
"3")
    echo $report > $NEW_NO_DMP 
    ;;
"4")
    echo $report > $NEW_DMP_SIZE_0
    ;;
"5")
    echo $report > $NEW_DMP_INCOMPLETE 
    ;;
*)
    exit 1
    ;;
esac

./parse_new.sh
[ $? -eq 0 ] || exit 1

cat report.new
