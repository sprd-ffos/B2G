#!/bin/bash

#generate the random operator for orangutan
#

#options
MAXW=320
MAXH=480
STEPS=100000

usage()
{
    echo "Usage: $(basename $0) [fwvga|wvga|hvga(default)|qvga] [--steps num] [--help]"
    exit $1
}

while [ $# -gt 0 ]
do
    case $1 in
    hvga)
        #default, do nothing
        ;;
    fwvga)
        MAXW=480
        MAXH=854
        ;;
    wvga)
        MAXW=480
        MAXH=800
        ;;
    qvga)
        MAXW=240
        MAXH=320
        ;;
    --steps)
        shift
        if [[ "$1" == *[!0-9]* ]]
        then
            echo "Steps must be a numeric."
            usage 1
        else
            [ $1 -lt $STEPS ] && STEPS=$1
        fi
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

#if you want to change the rate if each command
#you can simply set more the command in the array
#such as more tap and no sleep
#CMDS=(tap tap tap tap tap tap drag drag pinch)
CMDS=(tap drag pinch sleep)

for((i=0;i<$STEPS;i++))
do
    cmd=${CMDS[$(( $RANDOM % ${#CMDS[@]} ))]}
    case $cmd in
    tap)
        #tap x y step duration
        x=$(( $RANDOM % $MAXW ))
        y=$(( $RANDOM % $MAXH ))
        tap=$(( $RANDOM % 3 + 1 ))
        dur=$(( $RANDOM % 500 + 100 ))
        echo $cmd $x $y $tap $dur 
        ;;
    drag)
        #drag x1 y1 x2 y2 step duration
        x1=$(( $RANDOM % $MAXW ))
        y1=$(( $RANDOM % $MAXH ))
        x2=$(( $RANDOM % $MAXW ))
        y2=$(( $RANDOM % $MAXH ))
        step=$(( $RANDOM % 10 + 10 ))
        dur=$(( $RANDOM % 1000 + 50 ))
        echo $cmd $x1 $y1 $x2 $y2 $step $dur 
        ;;
    pinch)
        #drag x1 y1 x2 y2 a1 b1 a2 b2 step duration
        x1=$(( $RANDOM % $MAXW ))
        y1=$(( $RANDOM % $MAXH ))
        x2=$(( $RANDOM % $MAXW ))
        y2=$(( $RANDOM % $MAXH ))
        a1=$(( $RANDOM % $MAXW ))
        b1=$(( $RANDOM % $MAXH ))
        a2=$(( $RANDOM % $MAXW ))
        b2=$(( $RANDOM % $MAXH ))
        step=$(( $RANDOM % 10 + 10 ))
        dur=$(( $RANDOM % 1000 + 50 ))
        echo $cmd $x1 $y1 $x2 $y2 $a1 $b1 $a2 $b2 $step $dur 
        ;;
    sleep)
        #sleep duration
        dur=$(( $RANDOM % 1000 + 1000 ))
        echo $cmd $dur 
        ;;
    *)
        break
        ;;
    esac
done
