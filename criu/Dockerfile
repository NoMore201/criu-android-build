FROM debian:stable

RUN mkdir -p /build && \
    apt-get update && \
    apt-get install -y build-essential \
    python-minimal \
    python-dev \
    flex \
    bison \
    lib32ncurses5-dev \
    libncurses5-dev \
    unzip \
    tar \
    m4 \
    pkg-config \
    libtool \
    wget \
    curl \
    autoconf \
    automake

WORKDIR /build

COPY build-criu descriptor.proto ifaddr.h setup-ndk /build/
RUN ./setup-ndk

VOLUME /build/dist

ENTRYPOINT bash /build/build-criu
