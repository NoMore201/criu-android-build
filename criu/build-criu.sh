#!/bin/bash

export ROOT=`pwd`
export NDK_ROOT=$ROOT/cross

export SYSROOT=$NDK_ROOT/sysroot
export PATH=$NDK_ROOT/bin:$PATH
export CXX="arm-linux-androideabi-g++"
export CC="arm-linux-androideabi-gcc"

rm -rf protobuf
mkdir protobuf
tar --strip=1 -xzvf v3.3.0.tar.gz -C protobuf
cd $ROOT/protobuf

./autogen.sh
./configure --prefix=$ROOT/arm \
 --host=arm-linux-androideabi \
 --with-sysroot=$SYSROOT \
 --with-protoc=/usr/local/bin/protoc \
 --enable-cross-compile \
 LDFLAGS="-L/usr/local/lib -llog"

make -j$(nproc) && make install

cd $ROOT
rm -rf protobuf-c
mkdir protobuf-c
tar --strip=1 -xzvf protobuf-c-1.2.1.tar.gz -C protobuf-c
cd $ROOT/protobuf-c
./configure --prefix=$ROOT/arm \
  --host=arm-linux-androideabi \
  --disable-protoc \
  --with-sysroot=$SYSROOT \
  LDFLAGS="-L/usr/local/lib -llog" \
  CXXFLAGS="-I/usr/local/include"

make -j$(nproc) && make install

cd $ROOT
rm -rf criu
mkdir criu
tar --strip=1 -xzvf v2.12.1.tar.gz -C criu
cd $ROOT/criu
rm images/google/protobuf/descriptor.proto
cp $ROOT/arm/include/google/protobuf/descriptor.proto images/google/protobuf/
make -j$(nproc) \
  ARCH=arm \
  CROSS_COMPILE=$NDK_ROOT/bin/arm-linux-androideabi- \
  USERCFLAGS="-I${ROOT}/arm/include -I${NDK_ROOT}/sysroot/usr/include -L${ROOT}/arm/lib"
