#!/bin/bash

# This script replicates some minimal Cordova's functionality for the purpose
# of building GreenAddress on F-Droid servers. They don't provide nodejs,
# so running Cordova's toolset is not possible there.

ln -s $PWD/CordovaLib/bin CordovaLib/ant-build
ln -s $PWD/../../facebook-android-sdk-3.7/facebook/bin $PWD/../../facebook-android-sdk-3.7/facebook/ant-build
cp -r ../../www/* assets/www
cp -r platform_www/* assets/www
mkdir -p it.greenaddress.cordova
cp -r ../../plugins/it.greenaddress.cordova/facebook-android-sdk-3.7/facebook it.greenaddress.cordova/cordova-facebook
mkdir -p it.greenaddress.cordova/cordova-facebook/bin
ln -s `pwd`/it.greenaddress.cordova/cordova-facebook/bin `pwd`/it.greenaddress.cordova/cordova-facebook/ant-build

cd scrypt
patch -p1 < ../scrypt_Makefile.patch
if [ `uname -m` = "x86_64" ]; then
    export SYSTEM="linux-x86_64"
else
    export SYSTEM="linux-x86"
fi
for ARCH in arm-linux-androideabi mipsel-linux-android x86; do
    export ARCH_SHORT=`echo $ARCH | cut -d'-' -f 1 | sed s/mipsel/mips/` # arm|mips|x86
    export PATH=$ANDROID_NDK/toolchains/$ARCH-4.8/prebuilt/$SYSTEM/bin:$PATH
    make clean TARGET=android
    make NDK_ROOT=$ANDROID_NDK TARGET=android ARCH_SHORT=$ARCH_SHORT ARCH=`echo $ARCH | sed s/x86/i686-linux-android/`
    ARCHDIR=../libs/`echo $ARCH_SHORT | sed s/arm/armeabi/` # armeabi|mips|x86
    mkdir -p $ARCHDIR
    cp target/libscrypt.so $ARCHDIR
done
cd ..
