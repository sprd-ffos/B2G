#!/bin/bash

#a cr is new or same with someone
#0 is new
#2 is same with the result
#3 is the cr already in the database
#1 common error

[ $# -eq 1 ] || exit 1

cr=$1

. ./crdb.config

cr_exist=$(find $DB_FOLDER -name "$cr" | wc -l)
[ $cr_exist -eq 0 ] || exit 3

find $DB_FOLDER -maxdepth 1 -type f | while read contrast
do
    same=$(./same.sh $contrast $STACK_FOLDER/$cr)

    if [ $same -ge $CAMPARE_THRESHOLD ]
    then
        echo ${contrast##*/}
        exit 2
    fi
done

