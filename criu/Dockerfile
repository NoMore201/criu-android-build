FROM debian:stable

RUN apt-get update && \
    apt-get install -y build-essential \
    python-minimal \
    python-dev \
    flex \
    bison \
    lib32ncurses5-dev \
    libncurses5-dev \
    unzip \
    git \
    vim \
    tar \
    m4 \
    pkg-config \
    libtool \
    wget \
    curl \
    autoconf \
    automake

RUN mkdir -p /build/intel
COPY build-* env_setup setup-ndk /build/

WORKDIR /build
RUN ./setup-ndk

WORKDIR /proto

RUN wget "https://github.com/google/protobuf/archive/v3.1.0.tar.gz" && \
    tar --strip=1 -xzvf "v3.1.0.tar.gz" && \
    ./autogen.sh && \
    ./configure --prefix=/build/intel \
        --disable-shared \
        --enable-static && \
    make -j$(nproc) && make install

WORKDIR /protoc

RUN wget "https://github.com/protobuf-c/protobuf-c/releases/download/v1.3.0/protobuf-c-1.3.0.tar.gz" && \
    tar --strip=1 -xzvf "protobuf-c-1.3.0.tar.gz" && \
    ldconfig && \
    export PATH=/build/intel/bin:$PATH && \
    export PKG_CONFIG_PATH=/build/intel/lib/pkgconfig && \
    CPPFLAGS=`pkg-config --cflags protobuf` LDFLAGS=`pkg-config --libs protobuf` ./configure \
        --prefix=/build/intel --disable-shared --enable-static && \
    make -j$(nproc) && make install

WORKDIR /build


# ensure setup-ndk step is cached
RUN echo "Done!"
