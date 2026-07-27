FROM ghcr.io/rekgrpth/postgres.docker:ubuntu-test
SHELL [ "/bin/bash", "-c" ]
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get full-upgrade -y --no-install-recommends; \
    apt-get install -y --no-install-recommends \
        apt-utils \
        autoconf \
        automake \
        autopoint \
        binutils \
        bison \
        ca-certificates \
        check \
        clang \
        cmake \
        curl \
        file \
        flex \
        g++ \
        gcc \
        gettext \
        git \
        gnupg \
#        gnutls-dev \
        groff \
        gunicorn \
        htop \
        libbrotli-dev \
        libc-ares-dev \
        libc-dev \
        libcjson-dev \
        libclang-dev \
        libcunit1-dev \
        libcups2-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libevent-dev \
        libfltk1.3-dev \
        libgc-dev \
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
        libperl-dev \
        libpng-dev \
        libpq-dev \
        libproj-dev \
        libprotobuf-c-dev \
        libpsl-dev \
        libreadline-dev \
        libselinux1-dev \
        libsfcgal-dev \
        libssh-dev \
        libssl-dev \
        libsubunit-dev \
#        libtalloc-dev \
        libtool \
        libtool \
        libudns-dev \
        libunwind-dev \
        liburing-dev \
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
        pcre2-utils \
        perl \
        pkg-config \
        protobuf-c-compiler \
        python3 \
        python3-dev \
        python3-docutils \
        python3-gevent \
        python3-httpbin \
        rtmpdump \
        sudo \
        systemtap-sdt-dev \
        tcl-dev \
        texinfo \
        uuid-dev \
        zlib1g-dev \
    ; \
    echo done
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" >>/etc/sudoers; \
    echo '"\e[A": history-search-backward' >>/etc/inputrc; \
    echo '"\e[B": history-search-forward' >>/etc/inputrc; \
    chown -R "$USER":"$GROUP" /usr/local; \
    echo done

USER "$USER"
