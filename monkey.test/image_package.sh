#!/bin/bash

#package the files for release test

. ./system.config
. ../.config

usage()
{
    echo "Usage: $(basename $0) --server server_config_file [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --server)
        shift
        server=$1
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

[ -d $IMAGE_FOLDER ] && rm -rf $IMAGE_FOLDER
mkdir $IMAGE_FOLDER
repo manifest -o ${IMAGE_FOLDER}/manifest.xml -r

image_list=("boot.img" "system.img" "u-boot.bin" "vmjaluna.img" "userdata.img")

for partition in ${image_list[*]}
do
    cp ../out/target/product/$DEVICE/$partition $IMAGE_FOLDER
done

cp -r ../objdir-gecko/dist/crashreporter-symbols $IMAGE_FOLDER

tar -caf $IMAGE_FOLDER.tar.bz2 $IMAGE_FOLDER

rm -rf $IMAGE_FOLDER

if [ -n "$server" ] && [ -f "$server" ]
then
    . $server

    ./ssh_passwd.sh --passwd $image_passwd -c "scp $IMAGE_FOLDER.tar.bz2 $image_user@$image_server:${image_folder}/$image_package"
    rm $IMAGE_FOLDER.tar.bz2
fi

