#!/bin/bash

ADB=$(which adb)
[ $? -eq 0 ] || ADB=bin/adb

device=$($ADB shell getprop ro.product.device | tr -d '\r' | sed 's/-/_/g')
[ -n "$device" ] || device=unknown_device
version=$($ADB shell getprop ro.build.version.incremental | tr -d '\r' | sed 's/-/_/g')
[ -n "$version" ] || version=unknown_version
tester=$(cat /etc/hostname | sed 's/-/_/g')
[ -n "$tester" ] || tester=unknown_tester
mode=$(echo $1 | sed 's/-/_/g')
[ -n "$mode" ] || mode=unknown_mode
timestamp=$(date +%y%m%d%H%M)

echo ${device}-${version}-${mode}-${tester}-${timestamp}
 
