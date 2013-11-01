#!/bin/bash
. ./system.config

if [ ! -d "$1" ]
then
    echo "Usage: log_parse.sh log_dir"
    log_file "Log parse error: No log"
fi

log=$1

log_file "[LOG PARSE] BEGIN ---->"

parse_file=${log}/log_parse

kmsg_file=(dmesg last_kmsg)
for file in ${kmsg_file[@]}
do
    if [ -f ${log}/$file ]
    then
        echo "[kmsg: $file]" >> $parse_file
        grep -f filter.kmsg ${log}/$file >> $parse_file
        echo >> $parse_file
    fi
done

main_file=$(find ${log} -name "main.log" | sed "s#^${log}/##")
main_file=(${main_file[@]} logcat.main)
for file in ${main_file[@]}
do
    if [ -f ${log}/$file ]
    then
        echo "[logcat main: $file]" >> $parse_file
        grep -f filter.kmsg ${log}/$file >> $parse_file
        echo >> $parse_file
    fi
done

if [ -f ${log}/dump_parse ]
then
    echo "[FFOS minidump: ${log}/dump_parse (the top 10 stack info)]" >> $parse_file
    sed -nE '/^Thread [0-9]+ \(crashed\)$/,/^Thread [0-9]+$/ {/^ *[0-9]+/p}' ${log}/dump_parse |\
        sed 's/^ *//' | head -n 10 >> $parse_file
    echo >> $parse_file
fi

cat $parse_file >> $LOGFILE

log_file "[LOG PARSE] <---- END"

exit 0
