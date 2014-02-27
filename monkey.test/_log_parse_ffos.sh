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
    filename=$(basename "$file")
    filename=${filename%%.dmp}
    echo "$file" >> $log/minidump/summary
    bin/minidump_stackwalk "$file" $MTCFG_IMG_GECKOSYMBOLS > ${log}/minidump/$filename
done

