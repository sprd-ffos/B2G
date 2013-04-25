#!/bin/bash

REPO=`which repo`
#REPO=./repo

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml &&
	$REPO sync
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
	CORE_COUNT=`system_profiler SPHardwareDataType | grep "Cores:" | sed -e 's/[ a-zA-Z:]*\([0-9]*\)/\1/'`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

#GITREPO=${GITREPO:-"git://github.com/mozilla-b2g/b2g-manifest"}
BRANCH=${BRANCH:-sprdroid4.0.3_vlx_3.0_b2g}
GITREPO="gitb2g@sprdroid.git.spreadtrum.com.cn:b2g/b2g-manifest"

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
"tara")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync tara4.0.3_vlx_3.0_b2g
	;;

"tara_512x256_hvga")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
	repo_sync tara4.0.3_vlx_3.0_b2g
	;;

"tara_512x128_hvga")
	echo DEVICE=sp8810ea_512x128_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x128_hvga-eng >> .tmp-config &&
	repo_sync tara4.0.3_vlx_3.0_b2g
	;;

"mozilla_weekly_build")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync mozilla_weekly_build
	;;

"mozilla_weekly_build_512x256_hvga")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
	repo_sync mozilla_weekly_build
	;;

"sp8825eabase_sprdroid4.1")
       echo DEVICE=sp8825ea >> .tmp-config &&
       echo LUNCH=sp8825eanativebase-userdebug >> .tmp-config &&
       repo_sync sprdroid4.1_3.4_b2g
       ;;

"sp8825eabase")
       echo DEVICE=sp8825ea >> .tmp-config &&
       echo LUNCH=sp8825eabase-eng >> .tmp-config &&
       repo_sync sprdroid4.0.3_vlx_3.0_b2g
       ;;

"sp8825eaplus")
       echo DEVICE=sp8825ea >> .tmp-config &&
       echo LUNCH=sp8825eaplus-eng >> .tmp-config &&
       repo_sync sprdroid4.0.3_vlx_3.0_b2g
       ;;

"sp8810eabase_4.0.3_vlx_3.0_track")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_track
	;;

"sp8810eabase_gonk_update")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_gonkupdate_temp
	;;

"sp8810eabase_mozilla_update")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync mozilla_update_temp
	;;

"sp8810eabase")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eaplus")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eaplus-eng >> .tmp-config &&
	repo_sync mozilla_mutisim4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_android")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-eng >> .tmp-config &&
	repo_sync manifest.W13.11.2-010325
	;;

"sp8810eabase_512x512_wvga")
	echo DEVICE=sp8810ea_512x512_wvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x512_wvga-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_512x256_wvga")
	echo DEVICE=sp8810ea_512x256_wvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_wvga-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_512x256_hvga")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_512x128_hvga")
	echo DEVICE=sp8810ea_512x128_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x128_hvga-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_weekly_build")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
	repo_sync sp8810eabase_weekly_build
	;;

"sp8810ebbase")
	echo DEVICE=sp8810eb >> .tmp-config &&
	echo LUNCH=sp8810ebbase-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810ebplus")
	echo DEVICE=sp8810eb >> .tmp-config &&
	echo LUNCH=sp8810ebplus-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"galaxy-s2")
	echo DEVICE=galaxys2 >> .tmp-config &&
	repo_sync $1
	;;

"galaxy-nexus")
	echo DEVICE=maguro >> .tmp-config &&
	repo_sync $1
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

"otoro"|"unagi"|"keon"|"inari"|"leo"|"hamachi")
	echo DEVICE=$1 >> .tmp-config &&
	repo_sync $1
	;;

"pandaboard")
	echo DEVICE=panda >> .tmp-config &&
	repo_sync $1
	;;

"emulator")
	echo DEVICE=generic >> .tmp-config &&
	echo LUNCH=full-eng >> .tmp-config &&
	repo_sync $1
	;;

"emulator-x86")
	echo DEVICE=generic_x86 >> .tmp-config &&
	echo LUNCH=full_x86-eng >> .tmp-config &&
	repo_sync emulator
	;;

*)
	echo Usage: $0 \(device name\)
	echo
	echo Valid devices to configure are:
	echo - tara =================================== Mozilla main branch, gecko/gaia@master, gonk@sprdroid4.0.3_vlx_3.0_b2g, use WVAG and 512 RAM
	echo - tara_512x256_hvga ====================== The same as tara, use HVAG and 256 RAM
       echo - tara_512x128_hvga ====================== The same as tara, use HVAG and 128 RAM
	echo - mozilla_weekly_build =================== Mozilla weekly build, gecko/gaia@mozilla weekly stable revision, gonk@sprdroid4.0.3_vlx_3.0_b2g
	echo - mozilla_weekly_build_512x256_hvga ====== The same as mozilla_weekly_build, use HVGA
	echo - sp8825eabase_sprdroid4.1 =============== Sprdroid4.1_3.4, gecko/gaia@sprdroid4.0.3_vlx_3.0_b2g, gonk@sprdroid4.1 and sprdlinux3.4
	echo - sp8810eabase_4.0.3_vlx_3.0_track ======= Debug gonk bugs, gecko/gaia@sprdroid4.0.3_vlx_3.0_b2g, gonk@sprdroid4.0.3 ANY revision
	echo - sp8810eabase_gonk_update =============== Upgrade only, gecko/gaia@sprdroid4.0.3_vlx_3.0_b2g, gonk@sprdroid4.0.3 LATEST revision
	echo - sp8810eabase_mozilla_update ============ Upgrade only, gecko/gaia@mozilla weekly stable revision, gonk@sprdroid4.0.3 LATEST revision
	echo - sp8810eabase =========================== MAIN BRANCH, gecko/gaia/gonk@sprdroid4.0.3_vlx_3.0_b2g, use WVAG and 512 RAM
	echo - sp8810eaplus =========================== Debug multi-sim
       echo - sp8810eabase_512x256_wvga ============== *MAIN BRANCH*, gecko/gaia/gonk@sprdroid4.0.3_vlx_3.0_b2g, use WVAG and 256 RAM
	echo - sp8810eabase_512x256_hvga ============== *MAIN BRANCH*, gecko/gaia/gonk@sprdroid4.0.3_vlx_3.0_b2g, use HVAG and 256 RAM
	echo - sp8810eabase_512x128_hvga ============== *MAIN BRANCH*, gecko/gaia/gonk@sprdroid4.0.3_vlx_3.0_b2g, use HVAG and 128 RAM
       echo - sp8810eabase_weekly_build ============== Sprd weekly build, gecko/gaia/gonk@sprd weekly revision
       echo - sp8810eabase_android =================== Gonk refernce verison, MocorDroid4.0.3_VLX_3.0_W13.03.1_MP_W13.11.2
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - nexus-s
	echo - nexus-s-4g
	echo - otoro
	echo - unagi ================================== Qcom refernce phone, gecko/gaia@mozilla weekly stable revision, gonk@qcom
	echo - inari
	echo - keon
	echo - leo
	echo - pandaboard
	echo - emulator
	echo - emulator-x86
	exit -1
	;;
esac

if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
