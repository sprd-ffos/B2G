#!/bin/bash

trap "exit 1" ERR

SCRIPT_DIR=$(cd $(dirname $0); pwd)
ADB=$(which adb) || ADB=${SCRIPT_DIR}/../bin/adb

if ! type $ADB > /dev/null 2>&1; then
  echo "$ADB required to run reference-workloads"
  exit
fi

echo "Waiting for device to be connected..."
$ADB wait-for-device
echo "Device connected"

IMAGE_COUNT=20
MUSIC_COUNT=20
VIDEO_COUNT=5
CONTACT_COUNT=tarako
SMS_COUNT=tarako
DIALER_COUNT=tarako
CAL_COUNT=tarako

echo "Populate Databases - tarako Workload"

$ADB shell stop b2g
APPS=${APPS:-${APP}}

IDB_BASE=
for dir in /data/local/storage/persistent /data/local/indexedDB; do
  if [ -n "$($ADB shell "test -d $dir/chrome && echo found")" ]; then
    IDB_BASE=$dir
    break
  fi
done
if [ -z "$IDB_BASE" ]; then
  echo "Can't find indexedDB base dir" >&2
  exit 1
fi
echo "IndexedDB base dir: $IDB_BASE"
IDB_PRESENT=$($ADB shell "ls -l $IDB_BASE/chrome/" | grep '^d.*idb')
if [ -z "$IDB_PRESENT" ]; then
  echo "idb directory not present"
  IDB_PATH=""
else
  echo "idb directory present"
  IDB_PATH="/idb"
fi

if [ -z "$APPS" ]; then
  APPS="gallery music video communications/contacts sms communications/dialer calendar"
fi

SUMMARY="Summary:\n"

for app in $APPS; do

  LINE=
  case $app in
    communications/dialer)
      echo "Starting dialer"
      $ADB pull /data/local/webapps/webapps.json $SCRIPT_DIR/webapps.json
      DIALER_INFO=$(python $SCRIPT_DIR/readJSON.py $SCRIPT_DIR/webapps.json "communications.*/localId")
      IFS='/' read -a DIALER_PARTS <<< "$DIALER_INFO"
      DIALER_DOMAIN=${DIALER_PARTS[0]}
      DIALER_ID=${DIALER_PARTS[1]}
      DIALER_DIR="$DIALER_ID+f+app+++$DIALER_DOMAIN"
      rm -f $SCRIPT_DIR/webapps.json
      if [ -z "$DIALER_ID" ]; then
        echo "Unable to determine communications application ID - skipping dialer history..."
        LINE=" Dialer History: skipped"
      else
        $ADB push  $SCRIPT_DIR/dialerDb-$DIALER_COUNT.sqlite $IDB_BASE/$DIALER_DIR$IDB_PATH/2584670174dsitanleecreR.sqlite
        LINE=" Dialer History: $(printf "%s" $DIALER_COUNT)"
      fi
      ;;

    gallery)
      echo "Starting gallery"
      $SCRIPT_DIR/generateImages.sh $IMAGE_COUNT
      LINE=" Gallery:        $(printf "%4d" $IMAGE_COUNT)"
      ;;

    music)
      echo "Starting music"
      $SCRIPT_DIR/generateMusicFiles.sh $MUSIC_COUNT
      LINE=" Music:          $(printf "%4d" $MUSIC_COUNT)"
      ;;

    video)
      echo "Starting video"
      $SCRIPT_DIR/generateVideos.sh $VIDEO_COUNT
      LINE=" Videos:         $(printf "%4d" $VIDEO_COUNT)"
      ;;

    communications/contacts)
      echo "Starting contacts"
      $ADB push  $SCRIPT_DIR/contactsDb-$CONTACT_COUNT.sqlite $IDB_BASE/chrome$IDB_PATH/3406066227csotncta.sqlite
      ATTACHMENT_DIR=$SCRIPT_DIR/contactsDb-$CONTACT_COUNT
      tar -xvzf $SCRIPT_DIR/ContactPictures-$CONTACT_COUNT.tar.gz -C $SCRIPT_DIR
      $ADB shell "rm $IDB_BASE/chrome$IDB_PATH/3406066227csotncta/*"
      $ADB push  $SCRIPT_DIR/contactsDb-$CONTACT_COUNT/ $IDB_BASE/chrome$IDB_PATH/3406066227csotncta/
      rm -rf $ATTACHMENT_DIR/
      LINE=" Contacts:       $(printf "%s" $CONTACT_COUNT)"
      ;;

    sms)
      echo "Starting sms"
      $ADB push  $SCRIPT_DIR/smsDb-$SMS_COUNT.sqlite $IDB_BASE/chrome$IDB_PATH/226660312ssm.sqlite
      ATTACHMENT_DIR=$SCRIPT_DIR/smsDb-$SMS_COUNT
      tar -xvzf $SCRIPT_DIR/Attachments-$SMS_COUNT.tar.gz -C $SCRIPT_DIR
      $ADB shell "rm $IDB_BASE/chrome$IDB_PATH/226660312ssm/*"
      $ADB push  $SCRIPT_DIR/smsDb-$SMS_COUNT/ $IDB_BASE/chrome$IDB_PATH/226660312ssm/
      rm -rf $ATTACHMENT_DIR/
      LINE=" Sms Messages:   $(printf "%s" $SMS_COUNT)"
      ;;

    calendar)
	  echo "Starting calendar"
      if [ -z "$IDB_PRESENT" ]; then
        echo "Can't push calendar to b2g18 phone..."
        LINE=" Calendar: skipped"
      else
        $ADB pull /data/local/webapps/webapps.json $SCRIPT_DIR/webapps.json
        CAL_INFO=$(python $SCRIPT_DIR/readJSON.py $SCRIPT_DIR/webapps.json "calendar.*/localId")
        IFS='/' read -a CAL_PARTS <<< "$CAL_INFO"
        CAL_DOMAIN=${CAL_PARTS[0]}
        CAL_ID=${CAL_PARTS[1]}
        CAL_DIR="$CAL_ID+f+app+++$CAL_DOMAIN"
        rm -f $SCRIPT_DIR/webapps.json
        if [ -z "$CAL_ID" ]; then
          echo "Unable to determine calendar application ID - skipping calendar..."
          LINE=" Calendar: skipped"
        else
          $ADB push  $SCRIPT_DIR/calendarDb-$CAL_COUNT.sqlite $IDB_BASE/$CAL_DIR$IDB_PATH/125582036br2agd-nceal.sqlite
          LINE=" Calendar:   $(printf "%s" $CAL_COUNT)"
        fi
      fi
      ;;

    *)
      echo "APPS includes unknown application name ($app) - ignoring..."
      LINE=" $app: unknown application name"
  esac

  if [ -n "$LINE" ]; then
    SUMMARY="$SUMMARY$LINE\n"
  fi

done

echo ""
echo -e "$SUMMARY"

$ADB shell start b2g

echo "Done"
