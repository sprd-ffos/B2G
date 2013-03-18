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
SCDIR=${SCDIR%/*}
BRDIR=$SCDIR/$1

if [ ! -d $BRDIR ]
then
    echo No SPRD patch for $1.
    exit 0;
fi

for patch in ${BRDIR}/*.patch
do
    mod=${patch##*/}
    mod=${mod%.*}

    if [ ! -d ${SCDIR}/../$mod ]
    then
        echo [ERROR!] $mod is not a valid module name.
        exit 1
    fi

    echo ----
    echo patching $mod...

    cd ${SCDIR}/../$mod

    git apply $patch

    if [ $? -ne 0 ]
    then
        echo [ERROR!] $mod.patch patch failed, maybe it is already patched.
        exit 1
    fi
    
    cd -

    echo $mod patch done!
done

