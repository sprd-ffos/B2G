#!/bin/bash

#common + info + ffos + slog
. ./system.config

log=${NOWLOGHEAD}-$(./log_filename.sh)

echo "[LOGGING] now log to $log."
rm -rf $log
rm -rf ${log}.tar.bz2
mkdir $log

./log_ffos.sh $log
./log_common.sh $log
./log_info.sh $log

#tar files
tar -caf ${log}.tar.bz2 ${log}/*

echo "[LOGGING] log file: ${log}.tar.bz2"

exit 0
