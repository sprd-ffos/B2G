#!/bin/bash

REPO=`which repo`
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

#GITREPO=${GITREPO:-"git://github.com/mozilla-b2g/b2g-manifest"}
BRANCH=${BRANCH:-sprdroid4.0.3_vlx_3.0_b2g}
GITREPO="gitb2g@sprdroid.git.spreadtrum.com.cn:b2g/b2g-manifest"

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

"sp8810eabase_mozilla_update_512x256_hvga")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
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

"sp8810eabase_512x512_wvga")
	echo DEVICE=sp8810ea_512x512_wvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x512_wvga-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_512x256_wvga")
	echo DEVICE=sp8810ea_512x256_wvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_wvga-eng >> .tmp-config &&
	echo GONK_VERSION=4.0.3_VLX_3.0_W13.03.1_MP_W13.11.2 >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g_master
	;;

"sp8810eabase_512x256_hvga")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
	echo GONK_VERSION=4.0.3_VLX_3.0_W13.03.1_MP_W13.11.2 >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
	;;

"sp8810eabase_512x128_hvga")
	echo DEVICE=sp8810ea_512x128_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x128_hvga-eng >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g
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

"sp7710ga_512x256_fwvga")
       echo DEVICE=sp7710ga >> .tmp-config &&
       echo LUNCH=sp7710ga-eng >> .tmp-config &&
       echo GONK_VERSION=4.1_3.0_SP7710_dualsim_W13.19.1 >> .tmp-config &&
       repo_sync sprdroid4.1_vlx_3.0_b2g_master
       ;;

"sp7710ga_512x256_hvga")
	echo DEVICE=sp7710ga >> .tmp-config &&
	echo LUNCH=sp7710ga-eng >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=4.1_3.0_SP7710_dualsim_W13.19.1 >> .tmp-config &&
	repo_sync sprdroid4.1_vlx_3.0_b2g
	;;

"sp7710ga_gonk4.0")
	echo DEVICE=sp7710ga >> .tmp-config &&
	echo LUNCH=sp7710ga-eng >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=4.1_3.0_SP7710_dualsim_W13.19.1 >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_b2g_7710
	;;

"sp7710ga_gonk4.1")
	echo DEVICE=sp7710ga >> .tmp-config &&
	echo LUNCH=sp7710ga-eng >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=4.1_3.0_SP7710_dualsim_W13.19.1 >> .tmp-config &&
	repo_sync sprdroid4.1_vlx_3.0_b2g_master
	;;

"sp7710ga_gonk4.2")
	echo DEVICE=sp7710ga >> .tmp-config &&
	echo LUNCH=sp7710ga-eng >> .tmp-config &&
	echo TARGET_HVGA_ENABLE=true >> .tmp-config &&
	echo GONK_VERSION=4.1_3.0_SP7710_dualsim_W13.19.1 >> .tmp-config &&
	repo_sync sprdroid4.2.2_b2g
	;;

"sp8825ea_gonk4.0")
       echo DEVICE=sp8825ea >> .tmp-config &&
       echo LUNCH=sp8825eabase-eng >> .tmp-config &&
       repo_sync sprdroid4.0.3_vlx_3.0_b2g_8825
       ;;

"sp8835eb_gonk4.3")
       echo DEVICE=sp8830eb >> .tmp-config &&
       echo LUNCH=sp8835ebbase-eng >> .tmp-config &&
       repo_sync sprdroid4.3_3.4_b2g
       ;;

"sp6820gbplus_wvga")
	echo DEVICE=sp6820gb >> .tmp-config &&
	echo LUNCH=sp6820gbplus-eng >> .tmp-config &&
	echo GONK_VERSION=4.0.3_VLX_3.0_12B_W13.09.5_P07.5 >> .tmp-config &&
	repo_sync sprdroid4.0.3_vlx_3.0_12b_b2g_master
        ;;

"sp8810eabase_weekly_build")
	echo DEVICE=sp8810ea_512x256_hvga>> .tmp-config &&
	echo LUNCH=sp8810eabase_512x256_hvga-eng >> .tmp-config &&
	repo_sync $1
	;;

"sp8810eabase_android")
	echo DEVICE=sp8810ea >> .tmp-config &&
	echo LUNCH=sp8810eabase-userdebug >> .tmp-config &&
	repo_sync $1
	;;

"sp7710ga_android4.1"|"sp7710ga_android4.2"|"sp7710ga_android4.3")
       echo DEVICE=sp7710ga >> .tmp-config &&
       echo LUNCH=sp7710ga-userdebug >> .tmp-config &&
       repo_sync $1
       ;;

"sp8825eabase_android")
       echo DEVICE=sp8825ea >> .tmp-config &&
       echo LUNCH=sp8825eabase-userdebug >> .tmp-config &&
       repo_sync sp8825eabase_android
       ;;

"sp8835ebbase_android")
       echo DEVICE=sp8830eb >> .tmp-config &&
       echo LUNCH=sp8835ebbase-userdebug >> .tmp-config &&
       repo_sync sprdroid4.3_3.4
       ;;

"android-4.1.2_r1"|"android-4.0.3_r1")
	echo DEVICE=$1 >> .tmp-config &&
	repo_sync $1
	;;

"android-4.2.2_r1")
	echo DEVICE=mako >> .tmp-config &&
	repo_sync $1
	;;

"android-4.3_r2.1")
        echo DEVICE=mako >> .tmp-config &&
        repo_sync $1
        ;;

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

"otoro"|"unagi"|"keon"|"inari"|"leo"|"hamachi"|"peak"|"helix")
	echo DEVICE=$1 >> .tmp-config &&
	repo_sync $1
	;;

"unagi_sprd_version")
        echo DEVICE=unagi >> .tmp-config &&
        repo_sync unagi_sprd_version
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
	repo_sync emulator
	;;

*)
	echo "Usage: $0 [-cdflnq] (device name)"
	echo "Flags are passed through to |./repo sync|."
	echo
	echo Valid devices to configure are:
	echo - tara =================================== Mozilla main branch, gecko/gaia@master, gonk@sprdroid4.0.3_vlx_3.0_b2g, use WVAG and 512 RAM
	echo - tara_512x256_hvga ====================== The same as tara, use HVAG and 256 RAM
	echo - tara_512x128_hvga ====================== The same as tara, use HVAG and 128 RAM
	echo - mozilla_weekly_build =================== Mozilla weekly build, gecko/gaia@mozilla weekly stable revision, gonk@sprdroid4.0.3_vlx_3.0_b2g
	echo - mozilla_weekly_build_512x256_hvga ====== The same as mozilla_weekly_build, use HVGA
	echo - sp8810eabase_mozilla_update ============ Upgrade only, gecko/gaia@mozilla weekly stable revision, gonk@sprdroid4.0.3 LATEST revision
	echo - sp8810eabase_512x256_wvga ============== *MAIN BRANCH*, gecko/gonk@sprdroid4.0.3_vlx_3.0_b2g, gaia@master, use WVAG and 256 RAM
	echo - sp8810eabase_512x256_hvga ============== *MAIN BRANCH*, gecko/gaia/gonk@sprdroid4.0.3_vlx_3.0_b2g, use HVAG and 256 RAM
	echo - sp8810eabase_512x128_hvga ============== *MAIN BRANCH*, gecko/gaia/gonk@sprdroid4.0.3_vlx_3.0_b2g, use HVAG and 128 RAM
	echo - sp7710ga_512x256_fwvga ================= Sprdroid4.1, gecko@sprdroid4.0.3_vlx_3.0_b2g, gaia@master, gonk@sprdroid4.1 and sprdlinux3.0
	echo - sp7710ga_512x256_hvga ================== Sprdroid4.1, gecko/gaia@sprdroid4.0.3_vlx_3.0_b2g, gonk@sprdroid4.1 and sprdlinux3.0
	echo - sp7710ga_gonk4.0 ======================= Sprdroid4.0, gecko/gaia@sprdroid4.0.3_vlx_3.0_b2g, gonk@sprdroid4.0 and sprdlinux3.0
	echo - sp7710ga_gonk4.1 ======================= Sprdroid4.1, gecko/gaia@master, gonk@sprdroid4.1 and sprdlinux3.0
	echo - sp7710ga_gonk4.2 ======================= Sprdroid4.2.2_r1, gecko/gaia@master, gonk@sprdroid4.2.2_r1 and sprdlinux3.0
	echo - sp8835eb_gonk4.3 ======================= Sprdroid4.3, gecko/gaia@master, gonk@sprdroid4.3 and sprdlinux3.4
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - nexus-4
	echo - nexus-s
	echo - nexus-s-4g
	echo - otoro
	echo - unagi ================================== Qcom refernce phone, gecko/gaia@mozilla weekly stable revision, gonk@qcom
	echo - unagi_sprd_version ===================== Qcom 0502 stable refernce phone, gecko/gaia@mozilla weekly stable revision, gonk@qcom
	echo - inari
	echo - keon
	echo - peak
	echo - leo
	echo - hamachi
	echo - helix
	echo - pandaboard
	echo - emulator
	echo - emulator-jb
	echo - emulator-x86-jb
	echo - emulator-x86
	echo - sprdroid refernce code as below
	echo - sp8810eabase_android =================== Gonk refernce verison, MocorDroid4.0.3_VLX_3.0_W13.03.1_MP_W13.11.2
	echo - sp7710ga_android4.1 ==================== Gonk refernce verison, MOCORDROID4.1_3.0_SP7710_dualsim_W13.19.1
	echo - sp7710ga_android4.2 ==================== Gonk refernce verison, MOCORDROID4.1_3.0_SP7710_dualsim_W13.19.1
	echo - sp7710ga_android4.3 ==================== Gonk refernce verison, MOCORDROID4.1_3.0_SP7710_dualsim_W13.19.1
	echo - sp8825eabase_android =================== Gonk refernce verison
	echo - sp8835ebbase_android =================== Gonk refernce verison
	echo - android-4.0.3_r1
	echo - android-4.1.2_r1
	echo - android-4.2.2_r1
	echo - android-4.3_r2.1
	exit -1
	;;
esac

if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
