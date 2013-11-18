#!/bin/bash

#usage, if exit with error then use "usage 1", or "usage 0"
usage()
{
    echo "Usage: $(basename $0) --log-dir <log dir> --type [now|last|all] --dev <dev> --ver <ver> --mode [release|custom*] --tester <tester> --date-from <yymmddHHMM> --date-to <yymmddHHMM> --output-dir <out-dir> [--help|-h]"
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

#options
log_dir=
log_type=
dev=
ver=
mode=
tester=
date_from=
date_to=
output_dir=

#get options
while [ $# -gt 0 ]
do
    case $1 in
    --log-dir)
        shift
        [ -d "$1" ] || usage 1
        log_dir=$1
        ;;
    --type)
        shift
        log_type=$1
        [ "$log_type" == "now" ] || [ "$log_type" == "last" ] || [ "$log_type" == "all" ] || usage 1
        ;;
    --dev)
        shift
        dev=$1
        ;;
    --ver)
        shift
        ver=$1
        ;;
    --mode)
        shift
        mode=$1
        ;;
    --tester)
        shift
        tester=$1
        ;;
    --date-from)
        shift
        [[ "$1" == *[!0-9]* ]] && usage 1
        date_from=$1
        ;;
    --date-to)
        shift
        [[ "$1" == *[!0-9]* ]] && usage 1
        date_to=$1
        ;;
    --output-dir)
        shift
        output_dir=$1
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

[ -n "$log_dir" ] || log_dir="."
log_dir=$(cd $log_dir;pwd)
[ -n "$log_type" ] || log_type="*"
if [ -n "$dev" ]
then
    dev=$(echo $dev | sed 's/-/_/g')
else
    dev="*"
fi
if [ -n "$ver" ]
then
    ver=$(echo $ver | sed 's/-/_/g')
else
    ver="*"
fi
if [ -n "$mode" ]
then
    mode=$(echo $mode | sed 's/-/_/g')
else
    mode="*"
fi
if [ -n "$tester" ]
then
    tester=$(echo $tester | sed 's/-/_/g')
else
    tester="*"
fi
[ -n "$output_dir" ] || output_dir="."
mkdir -p $output_dir
output_dir=$(cd $output_dir;pwd)

files=mtlog-$log_type-$dev-$ver-$mode-$tester-*.tar.bz2

crdb_dir="${log_dir}/crdb"
bad_log_file=$(tempfile)
nul_log_file=$(tempfile)
now_log_file=$(tempfile)
last_log_file=$(tempfile)
all_log_file=$(tempfile)
minidmp_log_file=$(tempfile)
coredmp_log_file=$(tempfile)
exception_log_file=$(tempfile)

cd $log_dir && ls $files | while read file
do
    file_name=${file##*/}
    file_raw=${file_name%%.tar.bz2}
    cur_date=${file_raw##*-}

    if [ -n "$date_from" ]
    then
        [ "$date_from" -lt "$cur_date" ] || continue
    fi

    if [ -n "$date_to" ]
    then
        [ "$cur_date" -le "$date_to" ] || continue
    fi

    cur_type=$(echo $file_raw | cut -d- -f2)

    case "$cur_type" in
    "now")
        echo $cur_date $file_raw >> $now_log_file
        ;;
    "last")
        echo $cur_date $file_raw >> $last_log_file
        ;;
    "all")
        echo $cur_date $file_raw >> $all_log_file
        ;;
        *)
        echo $cur_date $file_raw >> $bad_log_file
        continue
        ;;
    esac

    not_null=false
    tar -xavf $file -C $crdb_dir ${file_raw}/log_parse > /dev/null 2>&1
    [ $? -eq 0 ] && [ -f ${crdb_dir}/${file_raw}/log_parse ] \
        && [ $( cat ${crdb_dir}/${file_raw}/log_parse | grep -Pv '^$' | grep -Pv '^\[' | wc -l ) -gt 0 ] \
        && not_null=true

    if [ $not_null == "false" ]
    then
        echo $cur_date $file_raw >> $nul_log_file
        continue
    fi

    has_minidump=false
    tar -xavf $file -C $crdb_dir ${file_raw}/dump_parse > /dev/null 2>&1
    [ $? -eq 0 ] && [ -f ${crdb_dir}/${file_raw}/dump_parse ] \
        && [ $( cat ${crdb_dir}/${file_raw}/dump_parse | wc -l ) -gt 0 ] \
        && has_minidump=true

    if [ $has_minidump == "true" ]
    then
        echo $cur_date $file_raw >> $minidmp_log_file
        continue
    fi

    #has_coredump
    if tar -tvvf $file | grep -P '/coredump/.+' > /dev/null 2>&1
    then
        echo $cur_date $file_raw >> $coredmp_log_file
        continue
    fi

    echo $cur_date $file_raw >> $exception_log_file
done

[ $(stat $now_log_file -c %s) -gt 0 ] && cat $now_log_file | sort > ${output_dir}/mtlog-now
[ $(stat $last_log_file -c %s) -gt 0 ] && cat $last_log_file | sort > ${output_dir}/mtlog-last
[ $(stat $all_log_file -c %s) -gt 0 ] && cat $all_log_file | sort > ${output_dir}/mtlog-all
[ $(stat $bad_log_file -c %s) -gt 0 ] && cat $bad_log_file | sort > ${output_dir}/bad-log
[ $(stat $nul_log_file -c %s) -gt 0 ] && cat $nul_log_file | sort > ${output_dir}/nul-log

if [ $(stat $minidmp_log_file -c %s) -gt 0 ]
then
    cat $minidmp_log_file | sort > ${output_dir}/minidump-log

    > ${output_dir}/minidump-summary
    awk '{print $2}' ${output_dir}/minidump-log | while read file
    do
        echo $file >> ${output_dir}/minidump-summary
        echo ----------------------------------------- >> ${output_dir}/minidump-summary
        cat ${crdb_dir}/${file}/log_parse >> ${output_dir}/minidump-summary
        echo >> ${output_dir}/minidump-summary
    done
fi

if [ $(stat $coredmp_log_file -c %s) -gt 0 ]
then
    cat $coredmp_log_file | sort > ${output_dir}/coredump-log

    > ${output_dir}/coredump-summary
    awk '{print $2}' ${output_dir}/coredump-log | while read file
    do
        echo $file >> ${output_dir}/coredump-summary
        echo ----------------------------------------- >> ${output_dir}/coredump-summary
        cat ${crdb_dir}/${file}/log_parse >> ${output_dir}/coredump-summary
        echo >> ${output_dir}/coredump-summary
    done
fi

if [ $(stat $exception_log_file -c %s) -gt 0 ]
then
    cat $exception_log_file | sort > ${output_dir}/exception-log

    > ${output_dir}/exception-summary
    awk '{print $2}' ${output_dir}/exception-log | while read file
    do
        echo $file >> ${output_dir}/exception-summary
        echo ----------------------------------------- >> ${output_dir}/exception-summary
        cat ${crdb_dir}/${file}/log_parse >> ${output_dir}/exception-summary
        echo >> ${output_dir}/exception-summary
    done
fi

cnt_now=$(cat $now_log_file | wc -l)
cnt_last=$(cat $last_log_file | wc -l)
cnt_all=$(cat $all_log_file | wc -l)
cnt_nul=$(cat $nul_log_file | wc -l)
cnt_mini=$(cat $minidmp_log_file | wc -l)
cnt_core=$(cat $coredmp_log_file | wc -l)
cnt_exc=$(cat $exception_log_file | wc -l)
when_total=$((cnt_now + cnt_last + cnt_all))
what_total=$((cnt_mini + cnt_core + cnt_exc + cnt_nul))
minidump_lc=$(cat ${output_dir}/minidump-summary 2>/dev/null | wc -l)
coredump_lc=$(cat ${output_dir}/coredump-summary 2>/dev/null | wc -l)
exception_lc=$(cat ${output_dir}/exception-summary 2>/dev/null | wc -l)

# data report, give a simple summary of all cr
cat > ${output_dir}/summary << SUMMARY
          when? | count
-----------------------------
      mtlog-now | $cnt_now
     mtlog-last | $cnt_last
      mtlog-all | $cnt_all
-----------------------------
          Total | $when_total

          what? | count
-----------------------------
   minidump-log | $cnt_mini
   coredump-log | $cnt_core
  exception-log | $cnt_exc
        nul-log | $cnt_nul
-----------------------------
          Total | $what_total

        summary | line count
-----------------------------
       minidump | $minidump_lc
       coredump | $coredump_lc
      exception | $exception_lc
SUMMARY

printf "$cnt_now\t$cnt_last\t$cnt_all\t$when_total\t$cnt_mini\t/$minidump_lc\t$cnt_core\t/$coredump_lc\t$cnt_exc\t/$exception_lc\t$cnt_nul\t$what_total\n"

exit 0
