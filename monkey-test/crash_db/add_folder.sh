#!/bin/bash

usage()
{
    echo "Usage: $(basename $0) folder"
    exit $1
}


[ $# -eq 1 ] || usage 1

folder=$1

[ -n "$folder" ] || usage 1
[ -d $folder ] || usage 1

date
echo "Maybe take a while, please wait..."

./extract_folder.sh --folder $folder
[ $? -eq 0 ] || exit 1

date
echo "Extract end."

./parse_new.sh
[ $? -eq 0 ] || exit 1

date
echo "Parse end."

cat report.new
