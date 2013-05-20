#!/bin/bash

#1 regenerate the feature file

. ./crdb.config

if [ -f $FEATURE_FILE ]
then
    sort $FEATURE_FILE | uniq > $NEW_FEATURE_FILE
    cp $NEW_FEATURE_FILE $FEATURE_FILE
fi

if [ -f $NO_DMP ]
then
    sort $WRONG_FILE | uniq > $NEW_WRONG_FILE
    cp $NEW_WRONG_FILE $WRONG_FILE
fi

if [ -f $WRONG_FILE ]
then
    sort $NO_DMP | uniq > $NEW_NO_DMP
    cp $NEW_NO_DMP $NO_DMP
fi

rm -rf $DB_FOLDER

date
echo "Maybe take a while, please wait..."

./parse_new.sh

date
echo "Rebase end."

./report.sh
