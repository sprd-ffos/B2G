#!/bin/bash

#ensure that all need files are exist

[ -f local_file.config ] || exit 1

cat local_file.config | while read file
do
    [ -f "$file" ] && continue

    echo [ABORT] $file does not exist, test abort!
    exit 1
done

. ./test.config
. $DEVICE_CONFIG

trap 'exit 1' ERR
[ -f $IMAGE_SERVER_CONFIG ]
[ -f $DEVICE_CONFIG ]

