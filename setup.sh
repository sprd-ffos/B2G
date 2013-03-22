#!/bin/bash

. load-config.sh

VARIANT=${VARIANT:-eng}
if [ ! $LUNCH ];then
LUNCH=${LUNCH:-full_${DEVICE}-${VARIANT}}
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
. build/envsetup.sh &&
lunch $LUNCH
echo rm -rf gaia/profile
echo rm -rf gaia/profile.tar.gz
rm -rf gaia/profile
rm -rf gaia/profile.tar.gz
kheader
