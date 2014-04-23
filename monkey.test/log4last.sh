#!/bin/bash

. ./system.config
. $TEST_CONFIG

log=${LASTLOGHEAD}-$(./log_filename.sh $TEST_VERSION)

echo "[LOGGING] last log to $log."
rm -rf $log
rm -rf ${log}.tar.bz2
mkdir $log

./log_ffos.sh $log $SYMBOL_FOLDER
./log_common.sh $log
./log_info_last.sh $log

./log_parse.sh $log

#tar files
tar -caf ${log}.tar.bz2 ${log}/*

log_file "log to ${log}.tar.bz2"
echo "[LOGGING] log file: ${log}.tar.bz2"

echo $passwd | sudo -S rm -rf $log

exit 0
