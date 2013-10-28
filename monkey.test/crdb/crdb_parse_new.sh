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

#public folder and file
[ -d $DB_FOLDER ] || mkdir -p $DB_FOLDER
[[ "$CAMPARE_THRESHOLD" == *[!0-9]* ]] && exit 1

cr=$(basename $report)
cr=${cr%%.*}

feature=$(./crdb_extract.sh --report $report)

case "$?" in
"0")
    similar=$(./crdb_parse_cr.sh $cr)
    case "$?" in
    "0")
        echo $feature >> $FEATURE_FILE
        cp ${STACK_FOLDER}/${cr} $DB_FOLDER
        echo $cr: NEW
        ;;
    "2")
        echo $feature >> $FEATURE_FILE
        sim_folder=${DB_FOLDER}/${similar}-$SIMILAR_FIX
        mkdir -p $sim_folder
        cp ${STACK_FOLDER}/${cr} $sim_folder
        echo $cr: $similar
        ;;
    "3")
        echo $cr: ALREADY IN DATABASE
        ;;
    "*")
        ;;
    esac
    ;;
"2")
    echo $cr >> $WRONG_FILE 
    echo $cr: WRONG FILE
    ;;
"3")
    echo $cr >> $NO_DMP 
    echo $cr: NO DMP FILE
    ;;
"4")
    echo $cr >> $DMP_SIZE_0
    echo $cr: SIZE OF DMP FILE is 0
    ;;
"5")
    echo $cr >> $DMP_INCOMPLETE 
    echo $cr: DMP FILE INCOMPLETE
    ;;
*)
    exit 1
    ;;
esac

