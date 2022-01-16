#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive
savedAptMark="$(apt-mark showmanual)"
apt-get update
apt-get full-upgrade -y --no-install-recommends
apt-get install -y --no-install-recommends \
    apt-utils \
    autoconf \
    automake \
    autopoint \
    binutils \
    bison \
    check \
    clang \
    file \
    flex \
    g++ \
    gcc \
    gettext \
    git \
    gnupg \
    gnutls-dev \
    groff \
    libbrotli-dev \
    libc-ares-dev \
    libc-dev \
    libcjson-dev \
    libclang-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libevent-dev \
    libfltk1.3-dev \
    libgcrypt20-dev \
    libgdal-dev \
    libgdal-dev \
    libgeos-dev \
    libgeos-dev \
    libgss-dev \
    libicu-dev \
    libidn11-dev \
    libidn2-dev \
    libjansson-dev \
    libjpeg-dev \
    libjson-c-dev \
    libkrb5-dev \
    libldap2-dev \
    liblmdb-dev \
    liblz4-dev \
    libnghttp2-dev \
    libpam0g-dev \
    libpcre2-dev \
    libpcre3-dev \
    libperl-dev \
    libpng-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-c-dev \
    libpsl-dev \
    libreadline-dev \
    libselinux1-dev \
    libssh-dev \
    libssl-dev \
    libsubunit-dev \
    libtalloc-dev \
    libtool \
    libtool \
    libudns-dev \
    libunwind-dev \
    libxml2-dev \
    libxslt-dev \
    libyaml-dev \
    libzstd-dev \
    linux-headers-generic \
    linux-libc-dev \
    llvm \
    llvm-dev \
    lsb-release \
    make \
    mt-st \
    patch \
    pkg-config \
    protobuf-c-compiler \
    python3 \
    python3-dev \
    python3-docutils \
    rtmpdump \
    systemtap-sdt-dev \
    tcl-dev \
    texinfo \
    zlib1g-dev \
;
