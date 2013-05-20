#!/bin/bash

#compare two files line by line, output the count of same lines

error()
{
    echo 0
    exit 1
}

[ $# -eq 2 ] || error
[ -f $1 ] || error
[ -f $2 ] || error

file1=($(cat $1))
file2=($(cat $2))

cnt=0

while [ "${file1[$cnt]}" = "${file2[$cnt]}" ]
do 
    cnt=$(( $cnt + 1 ))
    [ $cnt -ge ${#file1[@]} ] && break
done

echo $cnt

