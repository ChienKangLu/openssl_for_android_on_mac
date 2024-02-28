#!/bin/bash -e
# Build OpenSSL with NDK r25c
# 
# $1: Android target ABI [armeabi-v7a, arm64-v8a, x86, x86_64]

ANDROID_TARGET_ABI=$1

WORK_PATH="/home"
ANDROID_NDK_PATH=${WORK_PATH}/android-ndk-r25c
OPENSSL_FOLDER="openssl-3.1.1"
OPENSSL_SOURCES_PATH=${WORK_PATH}/${OPENSSL_FOLDER}
OUTPUT_PATH=${WORK_PATH}/${OPENSSL_FOLDER}_${ANDROID_TARGET_ABI}

OPENSSL_TMP_FOLDER=/tmp/openssl_${ANDROID_TARGET_ABI}
mkdir -p ${OPENSSL_TMP_FOLDER}
cp -r ${OPENSSL_SOURCES_PATH}/* ${OPENSSL_TMP_FOLDER}

function build_library {
    mkdir -p ${OUTPUT_PATH}
    make && make install
    rm -rf ${OPENSSL_TMP_FOLDER}
    rm -rf ${OUTPUT_PATH}/bin
    rm -rf ${OUTPUT_PATH}/share
    rm -rf ${OUTPUT_PATH}/ssl
    rm -rf ${OUTPUT_PATH}/lib/engines*
    rm -rf ${OUTPUT_PATH}/lib/pkgconfig
    rm -rf ${OUTPUT_PATH}/lib/ossl-modules
    echo "Build completed! Check output libraries in ${OUTPUT_PATH}"
}

export ANDROID_NDK_ROOT=${ANDROID_NDK_PATH}
PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin:$ANDROID_NDK_ROOT/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin:$PATH
cd ${OPENSSL_TMP_FOLDER}

if [ "$ANDROID_TARGET_ABI" = "armeabi-v7a" ]
then
    CONFIGURE_TARGET="android-arm"
elif [ "$ANDROID_TARGET_ABI" = "arm64-v8a" ]
then
    CONFIGURE_TARGET="android-arm64"
elif [ "$ANDROID_TARGET_ABI" = "x86" ]
then
    CONFIGURE_TARGET="android-x86"
elif [ "$ANDROID_TARGET_ABI" = "x86_64" ]
then
    CONFIGURE_TARGET="android-x86_64"
else
    echo "Unsupported target ABI: '$ANDROID_TARGET_ABI'"
    echo
    echo "Please specify the target ABI: armeabi-v7a, arm64-v8a, x86, x86_64"
    exit 1
fi

# solve the error "ld: error: relocation R_AARCH64_ADR_PREL_PG_HI21 cannot be used against symbol 'ssl_undefined_function'; recompile with -fPIC"
export CFLAGS=-fPIC

./Configure ${CONFIGURE_TARGET} -static no-asm no-shared no-tests --prefix=${OUTPUT_PATH}
build_library