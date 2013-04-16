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

#get server config from file
srv_cfg=server.config
if [ ! -f $srv_cfg ]
then
    echo no server config file, please config the server in server.config file
    exit 1
fi

ssrv=$( grep -Po "^ *server *: *[^ ]+" $srv_cfg | sed -e 's/ //g' | awk -F: '{print $2}' )
susr=$( grep -Po "^ *user *: *[^ ]+" $srv_cfg | sed -e 's/ //g' | awk -F: '{print $2}' )
spasswd=$( grep -Po "^ *passwd *: *[^ ]+" $srv_cfg | sed -e 's/ //g' | awk -F: '{print $2}' )
sfolder=$( grep -Po "^ *folder *: *[^ ]+" $srv_cfg | sed -e 's/ //g' | awk -F: '{print $2}' )

srv_folder=$susr@$ssrv:$sfolder

#use device name as the folder name on server
push_folder=${srv_folder}/${DEV}/

#if no folder, create it
expect -c "

spawn ssh $susr@$ssrv \"\[ -d ${sfolder}/${DEV} \] || mkdir ${sfolder}/${DEV}\"
set timeout -1
expect {
    \"*@*'s password:\" {send \"$spasswd\r\"; exp_continue}
    \"Are you sure you want to continue connecting *?\" {send \"yes\r\"; exp_continue}
}
expect eof"

#there is something wrong with wildcard characters in expect, so use find
for file in $push_files
do
    ./pscp.sh --passwd "$spasswd" -c "$file $push_folder"
done

#mv to backup folder
BACKUP=crash_report_backup
[ ! -d $BACKUP ] && mkdir $BACKUP
mv $push_files $BACKUP


