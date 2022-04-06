#!/bin/bash

# variables
MANIFEST="https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni.git -b twrp-9.0"
DT_PATH=device/samsung/j7xelte
DT_LINK="https://github.com/yespap/twrp.git -b android-9.0"
DEVICE=${DT_PATH##*\/}

# install needed tools
apt update
apt upgrade -y
apt install libncurses5 bc
mkdir -p ~/bin
PATH="${HOME}/bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
# since we are building old tree, it thinks python2 is default
rm /usr/bin/python
ln -s /usr/bin/python2.7 /usr/bin/python

# get the source
mkdir ~/twrp
cd ~/twrp
repo init --depth=1 -u $MANIFEST -g default,-device,-mips,-darwin,-notdefault 
repo sync -c -j$(nproc --all) --no-tag --no-clone-bundle --optimized-fetch --prune
git clone --depth=1 $DT_LINK $DT_PATH
rm -rf .repo
find . -name ".git" | xargs rm

# build
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
export LC_ALL=C
lunch omni_${DEVICE}-eng
mka recoveryimage

# upload
curl bashupload.com -T out/target/product/j7xelte/recovery.tar
