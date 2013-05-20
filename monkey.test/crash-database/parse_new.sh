#!/bin/bash

#parse all reports those were extracted in the database - in feature & stack

. ./crdb.config

[[ "$CAMPARE_THRESHOLD" == *[!0-9]* ]] && exit 1

#public folder and file
[ -d $DB_FOLDER ] || mkdir $DB_FOLDER

> $NEW_REPORT

if [ -f $NEW_FEATURE_FILE ]
then
    sort $NEW_FEATURE_FILE | uniq | awk -F: '{print $1}' | while read cr
    do
        similar=$(./parse_cr.sh $cr)
        case "$?" in
        "0")
            echo $cr : NEW >> $NEW_REPORT
            cp ${STACK_FOLDER}/${cr} $DB_FOLDER
            ;;
        "2")
            echo $cr : $similar >> $NEW_REPORT
            sim_folder=${DB_FOLDER}/${similar}-$SIMILAR_FIX
            mkdir -p $sim_folder
            cp ${STACK_FOLDER}/${cr} $sim_folder
            ;;
        "3")
            echo $cr : ALREADY IN DATABASE >> $NEW_REPORT
            ;;
        "*")
            ;;
        esac
    done

    cat $NEW_FEATURE_FILE >> $FEATURE_FILE
fi

if [ -f $NEW_NO_DMP ]
then
    echo -- no dmp -- >> $NEW_REPORT
    cat $NEW_NO_DMP >> $NEW_REPORT
    cat $NEW_NO_DMP >> $NO_DMP
fi

if [ -f $NEW_DMP_SIZE_0 ]
then
    echo -- size of dmp file is 0 -- >> $NEW_REPORT
    cat $NEW_DMP_SIZE_0 >> $NEW_REPORT
    cat $NEW_DMP_SIZE_0 >> $DMP_SIZE_0
fi

if [ -f $NEW_DMP_INCOMPLETE ]
then
    echo -- dmp file incomplete -- >> $NEW_REPORT
    cat $NEW_DMP_INCOMPLETE >> $NEW_REPORT
    cat $NEW_DMP_INCOMPLETE >> $DMP_INCOMPLETE
fi

if [ -f $NEW_WRONG_FILE ]
then
    echo -- tar file wrong -- >> $NEW_REPORT
    cat $NEW_WRONG_FILE >> $NEW_REPORT
    cat $NEW_WRONG_FILE >> $WRONG_FILE
fi

