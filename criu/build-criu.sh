#!/bin/bash

export ROOT=`pwd`

PROTOBUF_URL="https://github.com/google/protobuf/archive/v3.3.0.tar.gz"
PROTOBUFC_URL="https://github.com/protobuf-c/protobuf-c/archive/v1.2.1.tar.gz"
CRIU_URL="http://download.openvz.org/criu/criu-2.6.tar.bz2"
NDK_URL="https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip"

PBUF_DIR="protobuf"
PBUFC_DIR="protobuf-c"
CRIU_DIR="criu"
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

if [[ ! -d $PBUF_DIR ]]; then
	curl -L $PROTOBUF_URL > $PBUF_DIR.tar.gz
	mkdir $PBUF_DIR
	tar --strip=1 -xzvf $PBUF_DIR.tar.gz -C $PBUF_DIR
	cd $ROOT/$PBUF_DIR
	./autogen.sh
	./configure --prefix=$BUILD_DIR \
 		--host=arm-linux-androideabi \
 		--with-sysroot=$SYSROOT \
		--disable-shared --enable-static \
 		--with-protoc=/usr/local/bin/protoc \
 		--enable-cross-compile \
 		LDFLAGS="-L/usr/local/lib -llog"
	make -j$(nproc) && make install
fi

export PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig
cd $ROOT
if [[ ! -d $PBUFC_DIR ]]; then
	curl -L $PROTOBUFC_URL > $PBUFC_DIR.tar.gz
	mkdir $PBUFC_DIR
	tar --strip=1 -xzvf $PBUFC_DIR.tar.gz -C $PBUFC_DIR
	cd $ROOT/$PBUFC_DIR
	./autogen.sh
	CPPFLAGS=`pkg-config --cflags protobuf` \
	LDFLAGS=`pkg-config --libs protobuf` \
	./configure --prefix=$BUILD_DIR \
		--host=arm-linux-androideabi \
		--disable-shared --enable-static --disable-protoc
	make -j$(nproc) && make install
fi

cd $ROOT
if [[ ! -d $CRIU_DIR ]]; then
	curl -L $CRIU_URL > $CRIU_DIR.tar.bz2
	mkdir $CRIU_DIR
	tar --strip=1 -xjvf $CRIU_DIR.tar.bz2 -C $CRIU_DIR
	cd $ROOT/$CRIU_DIR
	rm images/google/protobuf/descriptor.proto
	cp $ROOT/descriptor.proto images/google/protobuf
	make -j$(nproc) \
		ARCH=arm \
		CROSS_COMPILE=$NDK_ROOT/bin/arm-linux-androideabi- \
		USERCFLAGS="-I${BUILD_DIR}/include -L${BUILD_DIR}/lib" \
		PATH=/usr/local/bin:$PATH \
		criu
fi

