#!/bin/bash

#usage, if exit with error then use "usage 1", or "usage 0"
usage()
{
    echo "Usage: $(basename $0) --server <server config> -s <log string>[--help|-h]"
    echo "  --server <server config>, set the server to put log"
    echo "      <server config> is a config file in test-config/ which for test.config"
    exit $1
}

#options
server_config=
log=

#get options
while [ $# -gt 0 ]
do
    case $1 in
    --server)
        shift
        [ -f "$1" ] || usage 1
        server_config=$1
        ;;
    -s)
        shift
        [ -n "$1" ] || usage 1
        log=$1
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

[ -n "$server_config" ] || usage 1
[ -n "$log" ] || usage 1

. $server_config

./ssh_passwd.sh --passwd "$log_passwd" -c "ssh $log_user@$log_server \"echo \'$log\' >> $log_folder/monkey_test_log\""
