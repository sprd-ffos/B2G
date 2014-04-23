#!/bin/bash

CONFIG=./config.sh
BUILD=./build.sh
FLASH=./flash.sh

case "$1" in
"sp8810eabase")
    $CONFIG $1 &&
    $BUILD  &&
    $FLASH 
    ;;

"sp8810eaplus")
    $CONFIG $1 &&
    $BUILD  &&
    $FLASH 
    ;;

"sp8810ebbase")
    $CONFIG $1 &&
    $BUILD &&
    $FLASH 
    ;;

"sp8810ebplus")
    $CONFIG $1 &&
    $BUILD  &&
    $FLASH 
    ;;
*)
    
echo Usage: $0 \(device name\)
echo
echo Valid devicees to configure are:
echo - sp8810eabase
echo - sp8810eaplus
echo - sp8810ebbase
echo - sp8810ebplus
#echo - galaxy-s2
#echo - galaxy-nexus
#echo - nexus-s
#echo - otoro
#echo - pandaboard
#echo - emulator
#echoho - emulator-x86
exit -1
;;
esac

if [ $? -ne 0 ]; then
    echo failed
    exit -1
    fi
                    
