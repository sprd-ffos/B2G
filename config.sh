#!/bin/bash

REPO=${REPO:-./repo}
sync_flags=""

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml &&
	$REPO sync $sync_flags
	ret=$?
	if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
		rm -rf $GIT_TEMP_REPO
	fi
	if [ $ret -ne 0 ]; then
		echo Repo sync failed
		exit -1
	fi
}

case `uname` in
"Darwin")
	# Should also work on other BSDs
	CORE_COUNT=`sysctl -n hw.ncpu`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

GITREPO=${GITREPO:-"https://github.com/sprd-ffos/b2g-manifest"}
BRANCH=${BRANCH:-sprd}

while [ $# -ge 1 ]; do
	case $1 in
	-d|-l|-f|-n|-c|-q)
		sync_flags="$sync_flags $1"
		shift
		;;
	--help|-h)
		# The main case statement will give a usage message.
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

GIT_TEMP_REPO="tmp_manifest_repo"
if [ -n "$2" ]; then
	GITREPO=$GIT_TEMP_REPO
	rm -rf $GITREPO &&
	git init $GITREPO &&
	cp $2 $GITREPO/$1.xml &&
	cd $GITREPO &&
	git add $1.xml &&
	git commit -m "manifest" &&
	git branch -m $BRANCH &&
	cd ..
fi

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo GECKO_OBJDIR=$PWD/objdir-gecko >> .tmp-config
echo DEVICE_NAME=$1 >> .tmp-config

case "$1" in
"galaxy-s2")
	echo DEVICE=galaxys2 >> .tmp-config &&
	repo_sync $1
	;;

"galaxy-nexus")
	echo DEVICE=maguro >> .tmp-config &&
	repo_sync $1
	;;

"nexus-4")
	echo DEVICE=mako >> .tmp-config &&
	repo_sync nexus-4
	;;

"optimus-l5")
	echo DEVICE=m4 >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s")
	echo DEVICE=crespo >> .tmp-config &&
	repo_sync $1
	;;

"nexus-s-4g")
	echo DEVICE=crespo4g >> .tmp-config &&
	repo_sync $1
	;;

"otoro"|"unagi"|"keon"|"inari"|"leo"|"hamachi"|"peak"|"helix"|"wasabi")
	echo DEVICE=$1 >> .tmp-config &&
	repo_sync $1
	;;

"fugu")
	echo LUNCH=sp7710ga_gonk-eng >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=SP7710_13A_W13.39.7 >> .tmp-config &&
	repo_sync $1
	;;

"sp7710ga_gonk4.0"|"sp7710ga_gonk4.0_v1.3")
	echo DEVICE=sp7710ga_gonk >> .tmp-config &&
	echo LUNCH=sp7710ga_gonk-userdebug >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=SP7710_13A_W13.39.7 >> .tmp-config &&
	repo_sync $1
	;;

"sp7710ga_gonk4.0_fwvga")
	echo DEVICE=sp7710ga_gonk >> .tmp-config &&
	echo LUNCH=sp7710ga_gonk-userdebug >> .tmp-config &&
	echo GONK_VERSION=SP7710_13A_W13.39.7 >> .tmp-config &&
	repo_sync sp7710ga_gonk4.0
	;;

"sp7710lc_gonk4.0")
	echo DEVICE=sp7710lc_gonk >> .tmp-config &&
	echo LUNCH=sp7710lc_gonk-userdebug >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=SP7710_13A_W13.39.7 >> .tmp-config &&
	repo_sync sp7710ga_gonk4.0
	;;

"sp7710gaplus_gonk4.0")
	echo DEVICE=sp7710gaplus_gonk >> .tmp-config &&
	echo LUNCH=sp7710gaplus_gonk-userdebug >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=SP7710_13A_W13.39.7 >> .tmp-config &&
	repo_sync sp7710ga_gonk4.0_v1.3
;;

"tara")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync $1
	;;

"pandaboard")
	echo DEVICE=panda >> .tmp-config &&
	repo_sync $1
	;;

"emulator"|"emulator-jb")
	echo DEVICE=generic >> .tmp-config &&
	echo LUNCH=full-eng >> .tmp-config &&
	repo_sync $1
	;;

"emulator-x86"|"emulator-x86-jb")
	echo DEVICE=generic_x86 >> .tmp-config &&
	echo LUNCH=full_x86-eng >> .tmp-config &&
	repo_sync $1
	;;

"flo")
	echo DEVICE=flo >> .tmp-config &&
	repo_sync $1
	;;

*)
	echo "Usage: $0 [-cdflnq] (device name)"
	echo "Flags are passed through to |./repo sync|."
	echo
	echo Valid devices to configure are:
	echo - sp7710ga_gonk4.0 ======================= Sprdroid4.0, gecko/gaia@FFOS v1.2, gonk@sprdroid4.0 and sprdlinux3.0
	echo - sp7710ga_gonk4.0_fwvga ================= Sprdroid4.0, gecko/gaia@FFOS v1.2, gonk@sprdroid4.0 , sprdlinux3.0 and fwvga resolution
	echo - sp7710lc_gonk4.0 ======================= Sprdroid4.0, gecko/gaia@FFOS v1.2, gonk@sprdroid4.0 and sprdlinux3.0, 256M ROM, 128M RAM	
	echo - sp7710ga_gonk4.0_v1.3 ================== Sprdroid4.0, gecko/gaia@FFOS v1.3, gonk@sprdroid4.0 and sprdlinux3.0
	echo - sp7710gaplus_gonk4.0 =================== Sprdroid4.0, gecko/gaia@FFOS v1.3, gonk@sprdroid4.0 and sprdlinux3.0 and dual SIM cards
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - nexus-4
	echo - nexus-s
	echo - nexus-s-4g
	echo - flo "(Nexus 7 2013)"
	echo - otoro
	echo - unagi
	echo - inari
	echo - keon
	echo - peak
	echo - leo
	echo - hamachi
	echo - helix
	echo - wasabi
	echo - fugu
	echo - tara
	echo - pandaboard
	echo - emulator
	echo - emulator-jb
	echo - emulator-x86
	echo - emulator-x86-jb
	exit -1
	;;
esac

if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
