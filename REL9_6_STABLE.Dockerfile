FROM ghcr.io/rekgrpth/lib.docker:latest
ADD bin /usr/local/bin
CMD [ "postgres" ]
ENV HOME=/var/lib/postgresql
STOPSIGNAL SIGINT
WORKDIR "$HOME"
ENV ARC=../arc \
    GROUP=postgres \
    LOG=../log \
    PGDATA="$HOME/96/data" \
    PGDUMP="$HOME/96/dump" \
    USER=postgres
RUN set -eux; \
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
        cjson-dev \
        clang \
        clang-dev \
        curl-dev \
        file \
        flex \
        g++ \
        gcc \
        gdal-dev \
        geos-dev \
        gettext-dev \
        git \
        groff \
        icu-dev \
        jansson-dev \
        json-c-dev \
        krb5-dev \
        libedit-dev \
        libevent-dev \
        libgss-dev \
        libidn2-dev \
        libidn-dev \
        libpsl-dev \
        libssh-dev \
        libtool \
        libxml2-dev \
        libxslt-dev \
        linux-headers \
        linux-pam-dev \
        llvm \
        llvm-dev \
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
        proj-dev \
        protobuf-c-dev \
        py3-docutils \
        python3-dev \
        readline-dev \
        rtmpdump-dev \
        talloc-dev \
        tcl-dev \
        texinfo \
        udns-dev \
        util-linux-dev \
        zlib-dev \
        zstd-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pgtap.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b master https://github.com/RekGRpth/session_variable.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    git clone -b REL9_6_STABLE https://github.com/RekGRpth/pg_rman.git; \
    git clone -b REL9_6_STABLE https://github.com/RekGRpth/postgres.git; \
    cd "$HOME/src/postgres"; \
    ./configure \
        --disable-rpath \
        --enable-integer-datetimes \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gnu-ld \
        --with-gssapi \
        --with-icu \
        --with-includes=/usr/local/include \
        --with-krb5 \
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
    ; \
    make -j"$(nproc)" -C src install; \
    make -j"$(nproc)" -C contrib install; \
    make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install; \
    cd "$HOME"; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/postgres | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apk add --no-cache --virtual .postgres \
        openssh-client \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e libcrypto -e gdal -e geos -e perl -e proj -e python -e tcl | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
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
