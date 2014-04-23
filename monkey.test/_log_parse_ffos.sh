#!/bin/bash

. _source_config_check.sh

[ $# -ne 1 ] && echo usage: "$0 <log-folder>" && exit 1

log=$1

if [ ! -d ${log}/mozilla ]
then
    log "no mozilla log in log folder: $log."
    exit 0
fi

if [ -z "$MTCFG_IMG_GECKOSYMBOLS" ] || [ ! -d $MTCFG_IMG_GECKOSYMBOLS ]
then
    log "no gecko symbols."
    exit 0
fi

[ -f bin/minidump_stackwalk ] || exit 1

mkdir -p ${log}/minidump

find $log/mozilla -name "*.dmp" | sed 's/\r//'| while read file
do
    filename="${file%.dmp}"
    extra_filename="${filename}.extra"
    filename=$(basename "$filename")
    parse_filename=${filename}.parse
    bin/minidump_stackwalk "$file" $MTCFG_IMG_GECKOSYMBOLS 2>/dev/null > ${log}/minidump/$parse_filename
    summary_filename=${filename}.sum
    echo ">>>> ${file#*/} <<<<" > ${log}/minidump/$summary_filename
    echo "---- extra ----" >> ${log}/minidump/$summary_filename
    if [ -f "$extra_filename" ]
    then
        cat "$extra_filename" >> ${log}/minidump/$summary_filename
        startup=$(grep  "StartupTime" "$extra_filename" | awk -F= '{print $2}')
        crash=$(grep "CrashTime" "$extra_filename" | awk -F= '{print $2}')
        echo '[MINIDUMP]' $(date --date="@$startup" +"%H:%M:%S" 2>/dev/null) - $(date --date="@$crash" +"%H:%M:%S" 2>/dev/null) : $filename >> monkey.log
    fi
    echo "---- stack ----" >> ${log}/minidump/$summary_filename
    sed -nE '/^Thread [0-9]+ \(crashed\)$/,/^Thread [0-9]+$/ {/^ *[0-9]+/p}' ${log}/minidump/$parse_filename |\
        sed 's/^ *//' >> ${log}/minidump/$summary_filename
    echo "${file#*/}" >> $log/minidump_summary
done

minidump_cnt=$(cat $log/minidump_summary | wc -l)

echo "--------------------" >> $log/minidump_summary
echo "Count: $minidump_cnt" >> $log/minidump_summary
echo "--------------------" >> $log/minidump_summary

[ $minidump_cnt -gt 0 ] && cat ${log}/minidump/*.sum >> $log/minidump_summary

