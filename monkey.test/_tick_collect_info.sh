#!/bin/bash

. _source_config_check.sh

if [ "$MTCFG_TICK_COLLECT_INFO_B2G" == "YES" ]
then
    folder=tick_collect_info/$(date +'%d%H%M%S')
    mkdir -p $folder

    $ADB shell b2g-info -t > $folder/b2g-info
    $ADB shell b2g-ps --oom > $folder/b2g-ps
    $ADB shell b2g-procrank --oom > $folder/b2g-procrank
    $ADB shell cat /proc/meminfo > $folder/meminfo
    $ADB shell procrank > $folder/pronrank
fi
