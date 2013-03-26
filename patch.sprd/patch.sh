#!/bin/bash

#patching
#Usage: patch.sh branch

if [ $# -ne 1 ]
then
    echo Usage: $0 branch
    echo Example: $0 nightly4.0.3_vlx_3.0_b2g
    exit 1
fi

SCDIR=$(pwd)/$0 
SCDIR=$(echo ${SCDIR%/*} | sed -e 's/\/\.$//')
BRDIR=$SCDIR/$1
PLIST=$BRDIR/patch.list

if [ ! -d $BRDIR ]
then
    echo No SPRD patch for $1.
    exit 0;
fi

if [ ! -f $PLIST ]
then
    echo No SPRD patch list file for $1.
    exit 0;
fi

cat $PLIST | grep -Po '\S+\s*:\s*\S+' | sed -e 's/ //g' | while read patch 
do
    dir=${SCDIR}/../$(echo $patch | awk -F: '{print $1}')
    file=${BRDIR}/$(echo $patch | awk -F: '{print $2}')
    #echo dir: =$dir=
    #echo file: =$file=

    if [ ! -d $dir ]
    then
        echo [ERROR!] $dir is not exist.
        continue
    fi

    if [ ! -f $file ]
    then
        echo [ERROR!] $file is not exist.
        continue
    fi

    #fork new sub shell patching...
    {
        cd $dir
        git apply $file

        if [ $? -ne 0 ]
        then
            echo [ERROR!] $file patch failed, maybe it is already patched.
        else
            echo [DONE!] $file is patched now!
        fi
    }
 done

