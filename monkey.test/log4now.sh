#!/bin/bash

#common + info + ffos + slog
. ./system.config
. $TEST_CONFIG

log=${NOWLOGHEAD}-$(./log_filename.sh $TEST_VERSION)

echo "[LOGGING] now log to $log."
rm -rf $log
rm -rf ${log}.tar.bz2
mkdir $log

./log_ffos.sh $log $SYMBOL_FOLDER
./log_common.sh $log
./log_info.sh $log

#tar files
tar -caf ${log}.tar.bz2 ${log}/*

log_file "log to ${log}.tar.bz2"
echo "[LOGGING] log file: ${log}.tar.bz2"

./log_parse.sh $log

echo $passwd | sudo -S rm -rf $log

exit 0
