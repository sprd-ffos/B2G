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
B2GDIR=$(dirname $SCDIR)
BRDIR=$SCDIR/$1
PLIST=$BRDIR/patch.list
CLIST=$BRDIR/copy.list

if [ ! -d $BRDIR ]
then
    echo No SPRD patch for $1.
    exit 0;
fi

if [ -f $PLIST ]
then
    cat $PLIST | grep -Po '^ *[^# ]+ *: *[^# ]+' | sed -e 's/ //g' | while read patch 
    do
        dir=${B2GDIR}/$(echo $patch | awk -F: '{print $1}')
        file=${BRDIR}/$(echo $patch | awk -F: '{print $2}')
        #echo dir: =$dir=
        #echo file: =$file=
        #continue
    
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
fi

if [ -f $CLIST ]
then
    cat $CLIST | grep -Po '^ *[^# ]+ *: *[^# ]+' | sed -e 's/ //g' | while read cpinfo 
    do
        dir=${B2GDIR}/$(echo $cpinfo | awk -F: '{print $1}')
        file=${BRDIR}/$(echo $cpinfo | awk -F: '{print $2}')
        #echo dir: =$dir=
        #echo file: =$file=
        #continue
    
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
        
        cp $file $dir
    
        if [ $? -ne 0 ]
        then
            echo [ERROR!] $file copy to $dir failed.

        else
            echo [DONE!] $file is copied to $dir now!
        fi
    done
fi

