#!/bin/bash
#run monkey test

. load-config.sh

#ADB=./out/host/linux-x86/bin/adb
ADB=adb
PCDIR=./orangutan
DVCDIR=/data
MTFILE=(orng script)
DMPDIR=/data/b2g/mozilla/*.default/minidumps
DMPPRE=cr
ORNG_BIN=/data/orng
SCRIPT_SRC=/data/script
ORNG_BIN_NATIVE=./monkey-tool/orng
SYMBOL_FILE=objdir-gecko/dist/crashreporter-symbols/
DUMPTOOL=$PWD/monkey-tool/minidump_stackwalk

echo $DUMPTOOL

. setup.sh && make buildsymbols

#push monkey test file
#for file in $MTFILE ; do
    #maybe need some check...
#    [ -f ${PCDIR}/${file} ] || { echo $file does not exist; exit 1; }
        
#    $ADB push ${PCDIR}/${file} ${DVCDIR}
#    $ADB shell chmod 777 ${DVCDIR}/${file}
#done
EXIST_ORNG_BIN=`$ADB shell toolbox ls $ORNG_BIN | awk '{ print \$2; }'`

if [ -n "$EXIST_ORNG_BIN" ]; then
    if [ ! -f "$ORNG_BIN_NATIVE" ]; then
        echo "The orng is not exist in your computer, please download it from sprd b2g wiki"
        exit 1;
    fi
    echo "The orng is not exist, push it in the phone..."
    $ADB push ./monkey-tool/orng /data
    $ADB shell chmod 777 $ORNG_BIN
    $ADB push ./monkey-tool/script /data
    $ADB shell chmod 777 $SCRIPT_SRC
fi


while true
do
    #need log?
    $ADB shell /data/orng /dev/input/event2 /data/script > /dev/zero &

    #check - is creashed
    while sleep 1
    do
        files=($($ADB shell find $DMPDIR -name "*.dmp" -o -name "*.extra" | sed 's/\r//'))
        
        #if has dmp file, it means... crashed...
        if [ ${#files[@]} -gt 0 ]
        then
            #gen time tag
            tag=${DMPPRE}$(date +%y%m%d%H%M$S)
            
            mkdir $tag

            for file in ${files[@]}
            do
                #pull file
                $ADB pull $file $tag
                #delete dmp file
                $ADB shell rm $file
            done

            cd $tag
            $DUMPTOOL *.dmp ../objdir-gecko/dist/crashreporter-symbols > result.txt
            cd ..

            #tar files
            tar -caf ${tag}.tar.bz2 ${tag}/*

            rm -rf $tag

            #delete monkey test files... need?
            #reboot
            $ADB shell reboot
            sleep 35
            #goto next monkey test
            continue 2
        fi

    done
done
