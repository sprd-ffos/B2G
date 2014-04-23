#!/bin/bash
#run monkey test

#ADB=./out/host/linux-x86/bin/adb
ADB=adb
FIND="$ADB shell busybox find"
PCDIR=./monkey-tool
DVCDIR=/data
MTFILE=(orng script)
SYMBDIR=./objdir-gecko/dist/crashreporter-symbols
DMPDIR=/data/b2g/mozilla
DMPPRE=cr
DUMPTOOL=./monkey-tool/minidump_stackwalk

#options
no_symb=no

usage()
{
    echo "Usage: $(basename $0) [--no-symbols] [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --no-symbols | --no-symb | -s)
        no_symb=yes
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

#build symbols
[ $no_symb = "no" ] && (. load-config.sh && . setup.sh && make buildsymbols)

#push monkey test file
for file in ${MTFILE[@]} ; do
    #maybe need some check...
    [ -z $($FIND ${DVCDIR} -name ${file}) ] || continue
    [ -f ${PCDIR}/${file} ] || { echo ${PCDIR}/${file} does not exist; exit 1; }
        
    $ADB push ${PCDIR}/${file} ${DVCDIR}
    $ADB shell chmod 777 ${DVCDIR}/${file}
done

#run test
while true
do
    #reboot
    $ADB shell reboot
    sleep 35

    #need log?
    $ADB logcat > adb_log &
    $ADB shell /data/orng /dev/input/event2 /data/script > /dev/zero &

    #check - is creashed
    while sleep 10
    do
        file_cnt=$($FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | wc -l)
        
        #if has dmp file, it means... crashed...
        if [ $file_cnt -gt 0 ]
        then
            #gen time tag
            tag=${DMPPRE}$(date +%y%m%d%H%M$S)
            
            mkdir $tag

            #dump files
            $FIND $DMPDIR -name "*.dmp" -o -name "*.extra" | sed 's/\r//'| while read file
            do
                #pull file
                $ADB pull "$file" $tag
                #delete dmp file
                $ADB shell rm "$file"
            done

            $DUMPTOOL ${tag}/*.dmp $SYMBDIR > ${tag}/dump_parse

            #more info
            cp adb_log ${tag}/
            $ADB shell b2g-ps > ${tag}/b2g-ps
            $ADB shell b2g-procrank > ${tag}/b2g-procrank
            repo manifest -o ${tag}/manifest.xml -r

            #tar files
            tar -caf ${tag}.tar.bz2 ${tag}/*

            rm -rf $tag

            #goto next monkey test
            continue 2
        fi

    done
done
