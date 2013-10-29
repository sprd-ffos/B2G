#!/bin/bash
. ./system.config

if [ ! -d "$1" ]
then
    echo "Usage: log_parse.sh log_dir"
    log_file "Log parse error: No log"
fi

log=$1

log_file "[LOG PARSE] (please wait, we will finish it next version.)"

exit 0
