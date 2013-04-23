#!/bin/bash

#auto patch, get branch from patch.config by device name

if [ $# -ne 1 ]
then
    echo Usage: $0 device
    echo Example: $0 tara
    exit 1
fi

SCDIR=$(cd "$(dirname "$0")"; pwd) 
config_file=${SCDIR}/patch.config

if [ ! -f $config_file ]
then
    exit 0
fi

branch=$( grep -Po "^ *$1 *: *[^# ]+" $config_file | sed -e 's/ //g' | awk -F: '{print $2}' )

if [ -n "$branch" ]
then
    ${SCDIR}/patch.sh $branch
fi

${SCDIR}/patch.sh monkey_test


