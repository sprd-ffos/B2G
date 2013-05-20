#!/bin/bash

#give passwd to scp
#need install expect
#sudo apt-get install expect

#options
passwd=
scp=

usage()
{
    echo "Usage: $(basename $0) --passwd passwd -c 'parameters of scp command' [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    --passwd)
        shift
        passwd=$1
        ;;
    -c)
        shift
        scp=$1
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

if [ -z "$scp" ]
then
    usage 1
fi

expect -c "

spawn scp $scp 
set timeout -1 
expect {
    \"*@*'s password:\" {send \"$passwd\r\"; exp_continue}
    \"Are you sure you want to continue connecting *?\" {send \"yes\r\"; exp_continue}
}
expect eof"

