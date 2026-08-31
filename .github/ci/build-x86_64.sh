#!/bin/bash
# Build all native modules for the x86_64 ABI.
# The project's `build` script only handles arm64-v8a and armeabi-v7a,
# so this replicates the same steps for x86_64 (GOARCH=amd64).

set -euo pipefail

export ABI="x86_64"
export LIBS_ROOT="$(pwd)"

export ANDROID_NDK_HOME="/opt/android-sdk/ndk/23.1.7779620"
export PATH="$PATH:$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin"

export CC="x86_64-linux-android21-clang"
export CCX="x86_64-linux-android21-clang++"
export GOARCH="amd64"
export GOOS="android"
export CGO_ENABLED=1

mkdir -p "$LIBS_ROOT/$ABI"

#################
# libobfs4proxy #
#################
pushd lyrebird/cmd/lyrebird/
go build -ldflags="-s -w -checklinkname=0" -o libobfs4proxy.so
mv libobfs4proxy.so "$LIBS_ROOT/$ABI/libobfs4proxy.so" || exit 1
popd

#####################
# libdnscrypt-proxy #
#####################
pushd dnscrypt-proxy/dnscrypt-proxy/
go build -ldflags="-s -w" -o libdnscrypt-proxy.so
mv libdnscrypt-proxy.so "$LIBS_ROOT/$ABI/libdnscrypt-proxy.so" || exit 1
popd

################
# libsnowflake #
################
pushd snowflake/client/
go build -ldflags="-s -w -checklinkname=0" -o libsnowflake.so
mv libsnowflake.so "$LIBS_ROOT/$ABI/libsnowflake.so" || exit 1
popd

################
# libconjure #
################
pushd libzmq/builds/android/
export NDK_VERSION="android-ndk-r23b"
export ANDROID_NDK_ROOT=$ANDROID_NDK_HOME
export MIN_SDK_VERSION=21
./build.sh x86_64
popd

pushd conjure/client/
export CGO_LDFLAGS="-L${LIBS_ROOT}/libzmq/builds/android/prefix/x86_64/lib -l:libzmq.a"
export PKG_CONFIG_PATH="${LIBS_ROOT}/libzmq/builds/android/prefix/x86_64/lib/pkgconfig"
go build -ldflags="-s -w -checklinkname=0 -linkmode=external -extldflags '$CGO_LDFLAGS'" -o libconjure.so
mv libconjure.so "$LIBS_ROOT/$ABI/libconjure.so" || exit 1
popd

################
# libdnstt #
################
pushd dnstt/dnstt-client/
go build -ldflags="-s -w -checklinkname=0" -o libdnstt.so
mv libdnstt.so "$LIBS_ROOT/$ABI/libdnstt.so" || exit 1
popd

################
# libnflog #
################
pushd Nflog-android/nflog/
go build -ldflags="-s -w" -o libnflog.so
mv libnflog.so "$LIBS_ROOT/$ABI/libnflog.so" || exit 1
popd

##########
# libtor #
##########
pushd ../../TorBuildScript/external/
export EXTERNAL_ROOT=`pwd`
export APP_ABI=x86_64
NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
mv ../tor-android-binary/src/main/libs/x86_64/libtor.so "$LIBS_ROOT/$ABI/libtor.so" || exit 1
popd

###########
# libi2pd #
###########
pushd ../../PurpleI2PBuildScript/external/
export EXTERNAL_ROOT=`pwd`
export TARGET_I2P_ABI=$ABI
export APP_ABI=$ABI
export TARGET_I2P_PLATFORM=21
NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make clean
NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make
NDK_PLATFORM_LEVEL=21 NDK_BIT=64 make showsetup
mv ../i2pd-android-binary/src/main/libs/${APP_ABI}/libi2pd.so "$LIBS_ROOT/$ABI/libi2pd.so" || exit 1
popd

echo "=== x86_64 build complete ==="
ls -la "$LIBS_ROOT/$ABI"/*.so
