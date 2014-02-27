#!/bin/bash

. _source_config_check.sh

[ $# -ne 1 ] && echo usage: "$0 <log-folder>" && exit 1

log=$1

if [ ! -d ${log}/slog_external ] && [ ! -d ${log}/slog_internal ]
then
    echo no any slog in log folder: $log.
    exit 0
fi

if [ -d ${log}/slog_external ]
then
    log_path=${log}/slog_external
else
    log_path=${log}/slog_internal
fi

log_curpath=$(find $log_path -maxdepth 1 | grep -P '/\d{14}$')

if grep -P "rebooted at \d+" ${log}/$MONKEYLOGFILE > /dev/null 2>&1
then
    log_type="last"
    log_folder=$(find ${log_path}/last_log -maxdepth 1 | grep -P '/\d{14}$')
    log_last_kmsg=${log_curpath}/misc/last_kmsg.log
else
    log_type="now"
    log_folder=$log_curpath
fi

#1 - Monkey stop reason and duration:
#MonkeyLastTime                            : $MonkeyRealLastTime
start_tag=$(grep -Po "begin at \d+" ${log}/$MONKEYLOGFILE 2>/dev/null)
end_tag=$(grep -Po "(rebooted|successful|detected) at \d+" ${log}/$MONKEYLOGFILE 2>/dev/null)
if [ -n "$start_tag" ] && [ -n "$end_tag" ]
then
    start_time=$(echo $start_tag | awk '{print $3}')
    end_time=$(echo $end_tag | awk '{print $3}')
    last_time=$((end_time-start_time))
    last_hour=$((last_time/3600))
    last_min=$(((last_time%3600)/60))
    MonkeyRealLastTime=$(printf "%d:%02d(%ds)" $last_hour $last_min $last_time)
else
    MonkeyRealLastTime=unknown
fi

#2 - Will Cause reboot or kernel panic:
#Kernel Panic Count                        : $KernelPanicCount
KernelPanicCount=$(grep "Kernel panic" ${log_folder}/misc/apanic_console.log 2>/dev/null | wc -l)
#Kernel Reboot Count                       : $KernelRebootCount
if [ "$log_type" == "last" ]
then
    KernelRebootCount=$(grep -P "(Rebooting in|Restarting system)" $log_last_kmsg 2>/dev/null | wc -l)
else
    KernelRebootCount=0
fi
#Kernel Power Down Count                   : $KernelPowerDownCount
if [ "$log_type" == "last" ]
then
    KernelPowerDownCount=$(grep "Power down" $log_last_kmsg 2>/dev/null | wc -l)
else
    KernelPowerDownCount=0
fi
#Watchdog Kill Count                       : $WatchdogKillCount
WatchdogKillCount=$(grep -r "WATCHDOG " ${log_folder}/android 2>/dev/null | wc -l)
#VM Global Ref Increase to 2001 Count      : $VMGlobalRefTo2001Count
VMGlobalRefTo2001Count=$(grep -r "GREF has increased to 2001" ${log_folder}/android 2>/dev/null | wc -l)
#System Server Native Crash Count          : $SystemServerNativeCrashCount
SystemServerNativeCrashCount=$(grep -r ">>> system_server <<<" ${log_folder}/android 2>/dev/null | wc -l)
#Fatal Exception In System Count           : $FatalExceptionInSystemCount
FatalExceptionInSystemCount=$(grep -r "FATAL EXCEPTION IN SYSTEM" ${log_folder}/android 2>/dev/null | wc -l)
#System Server Be Killed by signal Count   : $SystemServerBeKilledbySignalCount
SystemServerBeKilledbySignalCount=$(grep -r "Exit zygote because system server" ${log_folder}/android 2>/dev/null | wc -l)
#Shut Down Activity Start Count            : $ShutDownActivityCount
ShutDownActivityCount=$(grep -r "com.android.server.ShutdownActivity" ${log_folder}/android 2>/dev/null | wc -l)
#Shut Down Broadcast Count                 : $ShutDownBroadcastCount
ShutDownBroadcastCount=$(grep -r "Sending shutdown broadcast" ${log_folder}/android 2>/dev/null | wc -l)
#Binder Proxy Finalize Time Out Count      : $BinderProxyFinalizeTimeOutCount
BinderProxyFinalizeTimeOutCount=$(grep -r "android.os.BinderProxy.finalize() timed out" ${log_folder}/android 2>/dev/null | wc -l)
#HardWare Watchdog Reboot Count            : $HardWareWatchdogRebootCount
HardWareWatchdogRebootCount=$(grep "wdgreboot" ${log_folder}/misc/cmdline.log 2>/dev/null | wc -l)
#3 - May Cause reboot or kernel panic:
#Kernel BUG Count                          : $KernelBugCount
KernelBugCount=$(grep -r "BUG: " ${log_folder}/kernel 2>/dev/null | wc -l)
#Kernel ERR Count                          : $KernelERRCount
KernelERRCount=$(grep -r "ERR: " ${log_folder}/kernel 2>/dev/null | wc -l)
#Kernel FAT Count                          : $KernelFATCount
KernelFATCount=$(grep -r "FAT: " ${log_folder}/kernel 2>/dev/null | wc -l)
#Kernel Allocation Failure Count           : $KernelPageAllocationFailureCount
KernelPageAllocationFailureCount=$(grep -r "page allocation failure" ${log_folder}/kernel 2>/dev/null | wc -l)
#Kernel Binder Alloc No VMA Count          : $KernelBinderAllocBufnoVmaCount
KernelBinderAllocBufnoVmaCount=$(grep -r "binder_alloc_buf, no vma" ${log_folder}/kernel 2>/dev/null | wc -l)
#Frame Buffer WaitForCondition Count       : $WaitForConditionTimeOutCount
WaitForConditionTimeOutCount=$(grep -r "waitForCondition" ${log_folder}/android 2>/dev/null | wc -l)
#Modem Assert Count                        : $ModemAssertCount
ModemAssertCount=$(grep -r "Modem Assert" ${log_folder}/android 2>/dev/null | wc -l)
#4 - Android Bug Informations:
#5 - Android Mark Informations:
#OOM-Killer Kill Count                     : $OomKillerCount
OomKillerCount=$(grep -r "oom-killer" ${log_folder}/kernel 2>/dev/null | wc -l)
#Low Memory Killer Kill Count              : $LowMemoryKillerCount
LowMemoryKillerCount=$(grep -r "send sigkill to" ${log_folder}/kernel 2>/dev/null | wc -l)
#Print No More Background Process Count    : $LowMemoryCount
LowMemoryCount=$(grep -r "Low Memory" ${log_folder}/android 2>/dev/null | wc -l)
#Failed Binder Transaction Count           : $FailedBinderTransactionCount
FailedBinderTransactionCount=$(grep -r "FAILED BINDER TRANSACTION" ${log_folder}/android 2>/dev/null | wc -l)
#Unknown Permission Count                  : $UnknownPermissionCount
UnknownPermissionCount=$(grep -r "Unknown permission" ${log_folder}/android 2>/dev/null | wc -l)
#Set Screen State 1 Count                  : $SetScreenState1Count
#Set Screen State 0 Count                  : $SetScreenState0Count
SetScreenState1Count=$(grep -r "set_screen_state 1" ${log_folder}/android 2>/dev/null | wc -l)
SetScreenState0Count=$(grep -r "set_screen_state 0" ${log_folder}/android 2>/dev/null | wc -l)
#Kernel Warning Count                      : $KernelWarningCount
KernelWarningCount=$(grep -r "WARNING: " ${log_folder}/kernel 2>/dev/null | wc -l)

cat << EOF > ${log}/slog_report
All Summery As Follow:
--------------------------------------------------
1 - Monkey stop reason and duration:
MonkeyLastTime                            : $MonkeyRealLastTime
--------------------------------------------------
2 - Will Cause reboot or kernel panic:
Kernel Panic Count                        : $KernelPanicCount
Kernel Reboot Count                       : $KernelRebootCount
Kernel Power Down Count                   : $KernelPowerDownCount
Watchdog Kill Count                       : $WatchdogKillCount
VM Global Ref Increase to 2001 Count      : $VMGlobalRefTo2001Count
System Server Native Crash Count          : $SystemServerNativeCrashCount
Fatal Exception In System Count           : $FatalExceptionInSystemCount
System Server Be Killed by signal Count   : $SystemServerBeKilledbySignalCount
Shut Down Activity Start Count            : $ShutDownActivityCount
Shut Down Broadcast Count                 : $ShutDownBroadcastCount
Binder Proxy Finalize Time Out Count      : $BinderProxyFinalizeTimeOutCount
HardWare Watchdog Reboot Count            : $HardWareWatchdogRebootCount
--------------------------------------------------
3 - May Cause reboot or kernel panic:
Kernel BUG Count                          : $KernelBugCount
Kernel ERR Count                          : $KernelERRCount
Kernel FAT Count                          : $KernelFATCount
Kernel Allocation Failure Count           : $KernelPageAllocationFailureCount
Kernel Binder Alloc No VMA Count          : $KernelBinderAllocBufnoVmaCount
Frame Buffer WaitForCondition Count       : $WaitForConditionTimeOutCount
Modem Assert Count                        : $ModemAssertCount
--------------------------------------------------
4 - Android Bug Informations:
--------------------------------------------------
5 - Android Mark Informations:
OOM-Killer Kill Count                     : $OomKillerCount
Low Memory Killer Kill Count              : $LowMemoryKillerCount
Print No More Background Process Count    : $LowMemoryCount
Failed Binder Transaction Count           : $FailedBinderTransactionCount
Unknown Permission Count                  : $UnknownPermissionCount
Set Screen State 1 Count                  : $SetScreenState1Count
Set Screen State 0 Count                  : $SetScreenState0Count
Kernel Warning Count                      : $KernelWarningCount
EOF

exit 0
