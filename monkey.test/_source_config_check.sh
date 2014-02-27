#set -x
#If call the script by other script, use 'source <this-file>'
log() {
    echo $*
    echo "$*" >> $MONKEYLOGFILE
}

if [ "$MTCFG_SOURCE_TAG" != "YES" ]
then
    log "[ERROR]$0: Please source test config file by 'source <config-file>'"
    exit 1
fi

