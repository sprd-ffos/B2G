#!/bin/bash

#usage, if exit with error then use "usage 1", or "usage 0"
usage()
{
    echo "Usage: $(basename $0) --[local|server <server config>] --type [now|last|all] --dev <dev> --ver <ver> --mode [release|custom*] --tester <tester> --date-from <yymmddHHMM> --date-to <yymmddHHMM> [--help|-h]"
    echo "  --local|--server <server config>, catch log from local(default) or server"
    echo "      <server config> is a config file in test-config/ which for test.config"
    echo "      !!! this option must be set as the first, if it is set"
    echo "  --type [now|last|all], filter log by type, the type was manual defined"
    echo "      now, logs catch in this reboot"
    echo "      last, logs for last reboot"
    echo "      all, logs for both above two"
    echo "  --dev <dev>, the string get from device by 'getprop ro.product.device'"
    echo "  --ver <ver>, the string get from device by 'getprop ro.build.version.incremental'"
    echo "  --mode [release|custom*], the config mode, such as release, daily, local and so on"
    echo "  --tester <tester>, the string get from tester machine by 'cat /etc/hostname'"
    echo "  --date-from <yymmddHHMM>"
    echo "  --date-to <yymmddHHMM>, filter the logs by date, the format must be full of yymmddHHMM"
    echo ""
    echo "  <dev>, <mode>, <tester>, can use wildcard as shell, for example: ? and *"
    exit $1
}

[ $# -eq 0 ] && usage 1

report=monkey-test-log-summary-$(date +%y%m%d%H%M)

if [ "$1" == "--local" ]
then
    shift
    ./log_summary.sh --log-dir log_backup $@ > $report
    [ $? -eq 0 ] || usage 1
elif [ "$1" == "--server" ]
then
    shift
    [ -f "$1" ] || usage 1
    server_config=$1
    shift
    options=$*

    . $server_config

    push_folder=$log_user@$log_server:$log_folder

    ./ssh_passwd.sh --passwd "$log_passwd" -c "scp log_summary.sh $push_folder/"
    ./ssh_passwd.sh --passwd "$log_passwd" -c "ssh $log_user@$log_server \"$log_folder/log_summary.sh --log-dir $log_folder $options > ${log_folder}/__monkey_test_log_summary_temp__\""
    ./ssh_passwd.sh --passwd "$log_passwd" -c "scp $push_folder/__monkey_test_log_summary_temp__ ./$report"

else
    usage 1
fi

cat $report

exit 0
