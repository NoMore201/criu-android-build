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

WORKDIR /proto

RUN wget "https://github.com/google/protobuf/archive/v3.4.1.tar.gz" && \
    tar --strip=1 -xzvf "v3.4.1.tar.gz" && \
    ./autogen.sh && \
    ./configure && \
    make -j$(nproc) && make install && \
    rm -rf /proto

WORKDIR /protoc

RUN wget "https://github.com/protobuf-c/protobuf-c/releases/download/v1.3.0/protobuf-c-1.3.0.tar.gz" && \
    tar --strip=1 -xzvf "protobuf-c-1.3.0.tar.gz" && \
    ldconfig && \
    ./configure && \
    make -j$(nproc) && make install && \
    rm -rf /protoc

WORKDIR /build

COPY build-criu build-deps descriptor.proto ifaddr.h setup-ndk /build/
RUN ./setup-ndk
RUN ./build-deps

# ensure setup-ndk step is cached
RUN echo "Done!"

#ENTRYPOINT bash /build/build-criu
