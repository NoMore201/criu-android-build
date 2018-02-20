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
    automake \
    libprotobuf-dev \
    libprotobuf-c0-dev \
    protobuf-c-compiler \
    protobuf-compiler \
    python-protobuf \
    libnet1-dev

RUN mkdir -p /build/intel
COPY build-* setup-ndk /build/

WORKDIR /build

# Setup android NDK toolchain inside the /build/cross dir
RUN ./setup-ndk

WORKDIR /build

# ensure setup-ndk step is cached
RUN echo "Done!"
