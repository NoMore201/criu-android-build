#!/bin/bash

export ROOT=`pwd`

function download {
    curl -L $1 > $1.tar
}

function untar_gz {
    tar --strip=1 -xzvf $1.tar -C $1 1>/dev/null
}

function untar_bz2 {
    tar --strip=1 -xjvf $1.tar -C $1 1>/dev/null
}

PROTOBUF_URL="https://github.com/google/protobuf/archive/v3.3.0.tar.gz"
PROTOBUFC_URL="https://github.com/protobuf-c/protobuf-c/archive/v1.2.1.tar.gz"
CRIU_URL="http://download.openvz.org/criu/criu-3.3.tar.bz2"
NDK_URL="https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip"
LIBNL_URL="https://github.com/thom311/libnl/releases/download/libnl3_3_0/libnl-3.3.0.tar.gz"
LIBNET_URL="https://github.com/sam-github/libnet/archive/libnet-1.2.tar.gz"

PBUF_DIR="protobuf"
PBUFC_DIR="protobuf-c"
CRIU_DIR="criu"
LIBNL_DIR="libnl"
LIBNET_DIR="libnet"
TARGET="arm"

# Preparing NDK build environment
[[ ! -e ndk.zip ]] && curl -L $NDK_URL > ndk.zip
[[ ! -d ndk ]] && unzip ndk.zip -d tmp && d=(tmp/*) && mv $d ./ndk && rm -rf tmp/
[[ ! -d cross ]] && ndk/build/tools/make-standalone-toolchain.sh \
    --arch=arm --install-dir=$ROOT/cross \
    --platform=android-24


export NDK_ROOT=$ROOT/cross
export BUILD_DIR=$ROOT/$TARGET
export SYSROOT=$NDK_ROOT/sysroot
export PATH=$NDK_ROOT/bin:$PATH
export CXX="arm-linux-androideabi-g++"
export CC="arm-linux-androideabi-gcc"

cp ifaddr.h $SYSROOT/usr/include

if [[ ! -d $LIBNL_DIR ]]; then
    download $LIBNL_URL
    mkdir $LIBNL_DIR
    untar_gz $LIBNL_DIR
    cd $ROOT/$LIBNL_DIR
    ./configure --prefix=$BUILD_DIR \
        --host=arm-linux-androideabi --disable-pthreads --enable-cli=no \
        --with-sysroot=$SYSROOT
    make -j$(nproc)
    make install
fi

cd $ROOT

if [[ ! -d $LIBNET_DIR ]]; then
    download $LIBNET_URL
    mkdir $LIBNET_DIR
    untar_gz $LIBNET_DIR
    cd $ROOT/$LIBNET_DIR/$LIBNET_DIR
    ./autogen.sh
    ./configure --prefix=$BUILD_DIR \
        --host=arm-linux-androideabi \
        --with-sysroot=$SYSROOT 1>/dev/null
    make -j$(nproc)
    make install
fi

cd $ROOT

if [[ ! -d $PBUF_DIR ]]; then
    download $PROTOBUF_URL
    mkdir $PBUF_DIR
    untar_gz $PBUF_DIR
    cd $ROOT/$PBUF_DIR
    ./autogen.sh
    ./configure --prefix=$BUILD_DIR \
        --host=arm-linux-androideabi \
        --with-sysroot=$SYSROOT \
        --with-protoc=/usr/local/bin/protoc \
        --enable-cross-compile \
        LDFLAGS="-L/usr/local/lib -llog"
    make -j$(nproc)
    make install
fi

export PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig
cd $ROOT

if [[ ! -d $PBUFC_DIR ]]; then
    download $PROTOBUFC_URL
    mkdir $PBUFC_DIR
    untar_gz $PBUFC_DIR
    cd $ROOT/$PBUFC_DIR
    ./autogen.sh
    CPPFLAGS=`pkg-config --cflags protobuf` \
    LDFLAGS=`pkg-config --libs protobuf` \
    ./configure --prefix=$BUILD_DIR \
        --host=arm-linux-androideabi
    make -j$(nproc) && make install
fi

cd $ROOT

if [[ ! -d $CRIU_DIR ]]; then
    download $CRIU_URL
    mkdir $CRIU_DIR
    untar_bz2 $CRIU_DIR
    cd $ROOT/$CRIU_DIR
    rm images/google/protobuf/descriptor.proto
    cp $ROOT/descriptor.proto images/google/protobuf
    make clean
    make -j$(nproc) \
        ARCH=arm \
        CROSS_COMPILE=$NDK_ROOT/bin/arm-linux-androideabi- \
        USERCFLAGS="-I${BUILD_DIR}/include -L${BUILD_DIR}/lib" \
        PATH=/usr/local/bin:$PATH \
        criu
fi
