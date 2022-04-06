#!/bin/bash

MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0"
DT_PATH=device/samsung/j7xelte
DT_LINK="https://github.com/yespap/twrp.git -b android-9.0"

mkdir ~/twrp
cd ~/twrp
apt install openssh-server -y
apt update --fix-missing
apt install openssh-server -y
DEVICE=${DT_PATH##*\/}

echo " ===+++ Syncing Recovery Sources +++==="
mkdir -p ~/bin
PATH="${HOME}/bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -c -j$(nproc --all) --no-tag --no-clone-bundle --optimized-fetch --prune
git clone --depth=1 $DT_LINK $DT_PATH
ln -s /usr/bin/python2.7 /usr/bin/python

echo " ===+++ Building Recovery +++==="
source build/envsetup.sh
echo " source build/envsetup.sh done"
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL=C
lunch omni_${DEVICE}-eng
mka recoveryimage

echo " ===+++ Uploading Recovery +++==="
version=$(cat bootable/recovery/variables.h | grep "define TW_MAIN_VERSION_STR" | cut -d \" -f2)
OUTFILE=TWRP-${version}-${DEVICE}-$(date "+%Y%m%d-%I%M").zip
cd out/target/product/$DEVICE
mv recovery.img ${OUTFILE%.zip}.img
zip -r9 $OUTFILE ${OUTFILE%.zip}.img
curl -T $OUTFILE https://oshi.at
curl --upload-file $OUTFILE http://transfer.sh/
