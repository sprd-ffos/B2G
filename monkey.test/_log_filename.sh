#!/bin/bash

. _source_config_check.sh

trap 'exit 1' ERR

device=$($ADB shell getprop ro.product.device | tr -d '\r' | sed 's/-/_/g')
[ -n "$device" ] || device=unknown_device
version=$($ADB shell getprop ro.build.version.incremental | tr -d '\r' | sed 's/-/_/g')
[ -n "$version" ] || version=unknown_version
tester=$(cat /etc/hostname | sed 's/-/_/g')
[ -n "$tester" ] || tester=unknown_tester
mode=$(echo $MTCFG_TEST_TAG | sed 's/-/_/g')
[ -n "$mode" ] || mode=unknown_mode
timestamp=$(date +%y%m%d%H%M)

echo ${device}-${mode}-${version}-${tester}-${timestamp}
 
