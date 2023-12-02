FROM alpine:latest
ADD bin /usr/local/bin
ENTRYPOINT [ "docker_entrypoint.sh" ]
ENV HOME=/home
MAINTAINER RekGRpth
CMD [ "postgres" ]
ENV HOME=/var/lib/postgresql \
    PG_BUILD_FROM_SOURCE=yes \
    PG_MAJOR=16
STOPSIGNAL SIGINT
WORKDIR "$HOME"
ENV ARC=../arc \
    GROUP=postgres \
    LOG=../log \
    PGDATA="$HOME/$PG_MAJOR/data" \
    PGDUMP="$HOME/$PG_MAJOR/dump" \
    USER=postgres
RUN set -eux; \
    ln -fs su-exec /sbin/gosu; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    addgroup -g 70 -S "$GROUP"; \
    adduser -u 70 -S -D -G "$GROUP" -H -h "$HOME" -s /bin/sh "$USER"; \
    apk add --no-cache --virtual .build \
        autoconf \
        automake \
        binutils \
        bison \
        brotli-dev \
        c-ares-dev \
        check-dev \
        cjson-dev \
        clang15 \
        clang15-dev \
        cmake \
        cunit-dev \
        cups-dev \
        curl-dev \
        file \
        flex \
        fltk-dev \
        g++ \
        gcc \
        gdal-dev \
        geos-dev \
        gettext-dev \
        git \
#        gnutls-dev \
        groff \
        icu-dev \
        jansson-dev \
        jpeg-dev \
        json-c-dev \
        krb5-dev \
        libedit-dev \
        libevent-dev \
        libgcrypt-dev \
        libgss-dev \
        libidn2-dev \
        libidn-dev \
        libpng-dev \
        libpsl-dev \
        libssh-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        linux-pam-dev \
        llvm15 \
        llvm15-dev \
        lmdb-dev \
        lz4-dev \
        make \
        mt-st \
        musl-dev \
        nghttp2-dev \
        openldap-dev \
        patch \
        pcre2-dev \
        pcre-dev \
        perl-dev \
        pkgconf \
        proj-dev \
        protobuf-c-dev \
        py3-docutils \
        python3-dev \
        readline-dev \
        rtmpdump-dev \
        subunit-dev \
#        talloc-dev \
        tcl-dev \
        texinfo \
        udns-dev \
        util-linux-dev \
        yaml-dev \
        zlib-dev \
        zstd-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone -b main https://github.com/RekGRpth/pgcopydb.git; \
    git clone -b main https://github.com/RekGRpth/pgtap.git; \
    git clone -b master https://github.com/RekGRpth/htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
    git clone -b master https://github.com/RekGRpth/postgis.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b master https://github.com/RekGRpth/session_variable.git; \
    git clone -b "REL_${PG_MAJOR}_STABLE" https://github.com/RekGRpth/pg_rman.git; \
    git clone -b "REL_${PG_MAJOR}_STABLE" https://github.com/RekGRpth/postgres.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    ln -fs libldap.a /usr/lib/libldap_r.a; \
    ln -fs libldap.so /usr/lib/libldap_r.so; \
    cd "$HOME/src/htmldoc"; \
    ./configure --without-gui; \
    cd "$HOME/src/htmldoc/data"; \
    make -j"$(nproc)" install; \
    cd "$HOME/src/htmldoc/fonts"; \
    make -j"$(nproc)" install; \
    cd "$HOME/src/htmldoc/htmldoc"; \
    make -j"$(nproc)" install; \
    cd "$HOME/src/mustach"; \
    make -j"$(nproc)" libs=single install; \
    cd "$HOME/src/postgres"; \
    ./configure \
        CFLAGS="-fno-omit-frame-pointer -Werror=implicit-function-declaration -Werror=incompatible-pointer-types" \
        CLANG=clang-15 \
        CXXFLAGS="-fno-omit-frame-pointer" \
        LLVM_CONFIG=/usr/lib/llvm15/bin/llvm-config \
        --disable-rpath \
        --enable-integer-datetimes \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gssapi \
        --with-icu \
        --with-includes=/usr/local/include \
        --with-ldap \
        --with-libedit-preferred \
        --with-libraries=/usr/local/lib \
        --with-libxml \
        --with-libxslt \
        --with-llvm \
        --with-lz4 \
        --with-openssl \
        --with-pam \
        --with-perl \
        --with-pgport=5432 \
        --with-python \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-tcl \
        --with-uuid=e2fs \
        --with-zstd \
    ; \
    make -j"$(nproc)" -C src install; \
    make -j"$(nproc)" -C contrib install; \
    make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install; \
    cd "$HOME/src/postgis"; \
    ./autogen.sh; \
    ./configure; \
    ln -fs build-aux config; \
    make -j"$(nproc)" USE_PGXS=1; \
    cd "$HOME"; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/postgres -e /src/htmldoc -e /src/mustach | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apk add --no-cache --virtual .postgres \
        busybox-extras \
        busybox-suid \
        ca-certificates \
        musl-locales \
        openssh-client \
        shadow \
        su-exec \
        tzdata \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e gdal -e libcrypto -e geos -e perl -e proj -e python -e tcl | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 1775 -o "$USER" -g "$GROUP" /run/postgresql /run/postgresql/pg_stat_tmp /var/log/postgresql; \
    install -d -m 0700 -o "$USER" -g "$GROUP" "$PGDATA"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo done
