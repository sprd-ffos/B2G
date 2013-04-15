#!/bin/bash

#push report

#options
DEV=

usage()
{
    echo "Usage: $(basename $0) --dev dev [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --dev)
        shift
        DEV=$1
        ;;
    --help | -h)
        usage 0
        ;;
    -*)
        echo "Unrecognized option $1"
        usage 1
        ;;
    *)
        break
        ;;
    esac

    shift
done

if [ -z "$DEV" ]
then
    usage 1
fi

#push to server
push_files=mtlog-*.tar.bz2
#用户名;mocorhtml5_log   密码:PSD#sciuser    服务器：10.0.0.217
#log目录weeklybuild_monkeylog
srv_folder=mocorhtml5_log@10.0.0.217:/mocorhtml5_log/weeklybuild_monkeylog
#get the folder on server
dev_folder=
config_file=report.config
if [ -f $config_file ]
then
    dev_folder=$( grep -Po "^ *$DEV *: *[^# ]+" $config_file | sed -e 's/ //g' | awk -F: '{print $2}' )
fi

if [ -z "$dev_folder" ]
then
    push_folder=${srv_folder}/
else
    push_folder=${srv_folder}/${dev_folder}/
fi

#there is something wrong with wildcard characters in expect, so use find
for file in $push_files
do
    ./pscp.sh --passwd 'PSD#sciuser' -c "$file $push_folder"
done

#mv to backup folder
BACKUP=backup
[ ! -d $BACKUP ] && mkdir $BACKUP
mv $push_files $BACKUP


