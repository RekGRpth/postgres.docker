FROM ghcr.io/rekgrpth/postgres.docker:REL_13_STABLE
RUN set -eux; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build \
        autoconf \
        automake \
        binutils \
        bison \
        brotli-dev \
        c-ares-dev \
        check-dev \
        cjson-dev \
        clang \
        clang-dev \
        cmake \
        cunit-dev \
        cups-dev \
        curl \
        curl-dev \
        diffutils \
        file \
        flex \
        fltk-dev \
        g++ \
        gcc \
        gc-dev \
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
        llvm \
        llvm-dev \
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
        pcre-tools \
        perl-dev \
        perl \
        pkgconf \
        proj-dev \
        protobuf-c-dev \
        py3-docutils \
        python3-dev \
        readline-dev \
        rtmpdump-dev \
        sfcgal-dev \
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
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    cd "$HOME/src/postgres"; \
    ./configure \
        CFLAGS="-O0 -g3 -fno-omit-frame-pointer -Werror=implicit-function-declaration -Werror=incompatible-pointer-types" \
        CXXFLAGS="-O0 -g3 -fno-omit-frame-pointer" \
        --disable-rpath \
        --enable-cassert \
        --enable-debug \
        --enable-depend \
        --enable-integer-datetimes \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gnu-ld \
        --with-gssapi \
        --with-icu \
        --with-includes=/usr/local/include \
        --with-ldap \
        --with-libedit-preferred \
        --with-libraries=/usr/local/lib \
        --with-libxml \
        --with-libxslt \
        --with-llvm \
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
    cd "$HOME/src/postgis"; \
    ./autogen.sh; \
    ./configure; \
    ln -fs build-aux config; \
    make -j"$(nproc)" USE_PGXS=1; \
    cd "$HOME"; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/postgres -e /src/htmldoc -e /src/mustach | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    gosu postgres initdb --auth=trust; \
    echo "max_worker_processes = '128'" >>"$PGDATA/postgresql.auto.conf"; \
    echo "shared_preload_libraries = 'auto_explain,pg_stat_statements,pg_stat_kcache,pg_qualstats,pg_wait_sampling,plugin_debugger,pg_task'" >>"$PGDATA/postgresql.auto.conf"; \
    gosu postgres pg_ctl -w start; \
    sleep 10; \
    export PGUSER=postgres; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/pg_task -e src/postgres | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 installcheck || (cat regression.diffs; exit 1); done; \
    cd "$HOME/src/pg_task"; \
    export PGDATABASE=postgres; \
    make -j"$(nproc)" USE_PGXS=1 installcheck CONTRIB_TESTDB="$PGDATABASE" || (cat "$HOME/src/pg_task/regression.diffs"; exit 1); \
    gosu postgres pg_ctl -m fast -w stop; \
    cd /; \
    apk del --no-cache .build; \
    echo done
