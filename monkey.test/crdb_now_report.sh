#!/bin/bash

#1 get report from server, ../server.config
#2 parse cr, base on the database in current folder, then give all report

. ./crdb.config
. ./log_server.config

SERVER_LOG_LIST="_log_list_all"
TEMP_LOG_LIST=$(tempfile)

#generate log list and get it from server
expect -c "

spawn ssh $log_user@$log_server \"find $log_folder -name '*log-*.tar.bz2' > ${log_folder}/${SERVER_LOG_LIST}\"
set timeout -1 
expect {
    \"*@*'s password:\" {send \"$log_passwd\r\"; exp_continue}
    \"Are you sure you want to continue connecting *?\" {send \"yes\r\"; exp_continue}
}"

./pscp.sh --passwd "$log_passwd" -c "$log_user@$log_server:$log_folder/$SERVER_LOG_LIST $TEMP_LOG_LIST"


#get exlog
#do not know how to deal with them, wait for a discuss

#get new mtlog
ALL_MTLOG_LIST=$(tempfile)

[ -f $FEATURE_FILE ] &&  awk -F: '{print $1}' $FEATURE_FILE >> $ALL_MTLOG_LIST

for crfile in $WRONG_FILE $NO_DMP $DMP_SIZE_0 $DMP_INCOMPLETE
do
    [ -f $crfile ] && cat $crfile >> $ALL_MTLOG_LIST
done

[ -d $TAR_FOLDER ] || mkdir -p $TAR_FOLDER

grep "mtlog" $TEMP_LOG_LIST | grep -f $ALL_MTLOG_LIST -v | while read cr
do
    NEW_CR=$TAR_FOLDER/$(basename $cr)

    ./pscp.sh --passwd "$log_passwd" -c "$log_user@$log_server:$cr $NEW_CR"

    ./crdb_parse_new.sh $NEW_CR
done

