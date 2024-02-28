# Build OpenSSL for Android on Mac

For getting rid of the issues while building OpenSSL for Android on Mac, build OpenSSL with Ubuntu Docker image - Inspired by [openssl_for_android](https://github.com/217heidai/openssl_for_android.git), which builds OpenSSL on Github action.

## Setup environment

Start ubuntu container, then execute proceeding commands Inside docker container. [it's important to emulated x86_64 platform on an M1 macbook](https://stackoverflow.com/a/69075554):

```bash
docker run -ti --platform linux/x86_64 ubuntu /bin/bash
```

Install `sudo`, `aria2`, `unzip`, `make` and `git`:

```bash
apt-get update && apt-get install -y sudo

sudo apt-get install -yqq aria2

sudo apt-get install unzip

sudo apt-get install make

# Trick to fix "Can't locate FindBin.pm in @INC (you may need to install the FindBin module)"
sudo apt-get install git
```

Navigate to `home` directory:

```
cd /home
```

Download and unzip Android NDK (r25c) for linux:

```bash
aria2c https://dl.google.com/android/repository/android-ndk-r25c-linux.zip
```

```bash
unzip android-ndk-r25c-linux.zip
```

Download and unzip OpenSSL 3.1.1:

```bash
aria2c https://www.openssl.org/source/openssl-3.1.1.tar.gz
```

```bash
tar -zxvf openssl-3.1.1.tar.gz
```

## Build

Copy `openssl_build.ssh` to `/home` in container, then build different ABIs as following:

```bash
./openssl_build.sh armeabi-v7a
./openssl_build.sh arm64-v8a
./openssl_build.sh x86
./openssl_build.sh x86_64
```

The output library will be located in the folder `/home/openssl-3.1.1_[ABI]`.

## TroubleShooting

### warning: '__ANDROID_API__' macro redefined [-Wmacro-redefined]

The root cause is that Clang defines __ANDROID_API__ automatically as following:

```C++
#define __ANDROID_API__ __ANDROID_MIN_SDK_VERSION__
```

Thus I think we should modify the min SDK in Gradle rather than recompile OpenSSL for different API level!

see https://github.com/android/ndk/issues/1538 and  https://github.com/openssl/openssl/issues/18561#issuecomment-1155298077

### ld: error: relocation R_AARCH64_ADR_PREL_PG_HI21 cannot be used against symbol 'ssl_undefined_function'; recompile with -fPIC

This error message typically occurs when compiling OpenSSL for AArch64 (ARM 64-bit) architecture without position-independent code (PIC) support. To fix this error, you need to recompile OpenSSL with the `-fPIC` flag to generate position-independent code.

```bash
export CFLAGS=-fPIC

// then recompile OpenSSL again
```




