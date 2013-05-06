#!/bin/bash

. load-config.sh

KHEADER=1
VARIANT=${VARIANT:-eng}
if [ ! $LUNCH ];then
LUNCH=${LUNCH:-full_${DEVICE}-${VARIANT}}
KHEADER=0
fi

export USE_CCACHE=yes &&
export GECKO_PATH &&
export GAIA_PATH &&
export GAIA_DOMAIN &&
export GAIA_PORT &&
export GAIA_DEBUG &&
export GECKO_OBJDIR &&
export B2G_NOOPT &&
export B2G_DEBUG &&
export MOZ_CHROME_MULTILOCALE &&
export L10NBASEDIR &&
export TARGET_HVGA_ENABLE &&
. build/envsetup.sh &&
lunch $LUNCH
echo rm -rf gaia/profile
echo rm -rf gaia/profile.tar.gz
rm -rf gaia/profile
rm -rf gaia/profile.tar.gz
if [ $KHEADER = "1" ];then
kheader
fi
