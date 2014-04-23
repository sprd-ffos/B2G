#!/bin/bash

. _source_config_check.sh

[ "$MTCFG_LOG" == "YES" ] || exit 0

log_tag=$1
if [ "$1" == "reboot" ] || [ "$1" == "end" ] || [ "$1" == "manual" ]
then
    log_tag=$1
else
    log_tag=unknown
fi

log=${MTCFG_LOG_HEAD}-${log_tag}-$(./_log_filename.sh)

log "[$(date +'%m-%d.%H:%M')]Log to $log now."
rm -rf $log
rm -f ${log}.tar.bz2
mkdir $log

cp monkey.log ${log}/

if [ "$MTCFG_TICK_COLLECT_INFO_B2G" == "YES" ]
then
    mv tick_collect_info ${log}/
fi

#bugreport, genarate bugreport to slog folder
$ADB shell slogctl snap bugreport 

#slog
internal=$($ADB shell slogctl query | grep "^internal" | cut -d',' -f2)
external=$($ADB shell slogctl query | grep "^external" | cut -d',' -f2)

mkdir -p ${log}/slog_internal
mkdir -p ${log}/slog_external

$ADB pull ${internal} ${log}/slog_internal/
$ADB pull ${external} ${log}/slog_external/

echo -n '[Tombstones timestamps] ' >> monkey.log
if [ "$log_tag" == "reboot" ]
then
    echo "-- last log ---->" >> monkey.log
    $ADB shell "ls -l ${external}/last_log/*/misc/tombstones/tombstone* 2>/dev/null" >> monkey.log
else
    echo "-- current log ---->" >> monkey.log
    $ADB shell "ls -l ${external}/*/misc/tombstones/tombstone* 2>/dev/null" >> monkey.log
fi
echo '<---- [Tombstones timestamps]' >> monkey.log

#minidump
mkdir -p ${log}/mozilla
$ADB pull ${MTCFG_DEV_MINIDUMP_FOLDER} ${log}/mozilla

#log.parse
if [ "$MTCFG_LOG_PARSE" == "YES" ]
then
    ./_log_parse_slog.sh $log
    ./_log_parse_ffos.sh $log
fi

#log.tar
[ "$MTCFG_LOG_TAR" == "YES" ] || exit 0
tar_file=${log}.tar.bz2
tar -caf $tar_file ${log}
[ "$MTCFG_LOG_RM_ORIGIN" == "YES" ] && echo $passwd | sudo -S rm -rf $log
log "[$(date +'%m-%d.%H:%M')]Tar log to ${log}.tar.bz2."

#log.push
[ "$MTCFG_LOG_PUSH" == "YES" ] || exit 0

push_folder=$MTCFG_LOG_PUSH_USER@$MTCFG_LOG_PUSH_SERVER:$MTCFG_LOG_PUSH_FOLDER/
#use device name as the folder name on server. if no folder, create it
./ssh_passwd.sh --passwd "$MTCFG_LOG_PUSH_PASSWD" -c "ssh $MTCFG_LOG_PUSH_USER@$MTCFG_LOG_PUSH_SERVER \"\[ -d $MTCFG_LOG_PUSH_FOLDER \] || mkdir $MTCFG_LOG_PUSH_FOLDER\""
./ssh_passwd.sh --passwd "$MTCFG_LOG_PUSH_PASSWD" -c "scp $tar_file $push_folder"
log "[$(date +'%m-%d.%H:%M')]push log ${log}.tar.bz2 to $push_folder."

#log.backup
if [ "$MTCFG_LOG_BACKUP" == "YES" ]
then
    [ ! -d $MTCFG_LOG_BACKUP_FOLDER ] && mkdir $MTCFG_LOG_BACKUP_FOLDER
    mv $tar_file $MTCFG_LOG_BACKUP_FOLDER
    log "[$(date +'%m-%d.%H:%M')]back log ${log}.tar.bz2 to $MTCFG_LOG_BACKUP_FOLDER."
else
    rm $tar_file
fi
