FROM ghcr.io/rekgrpth/postgres.docker:debian
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get full-upgrade -y --no-install-recommends; \
    export savedAptMark="$(apt-mark showmanual)"; \
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
        libpcre3-dev \
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
        pcregrep \
        perl \
        pkg-config \
        protobuf-c-compiler \
        python3 \
        python3-dev \
        python3-docutils \
        python3-gevent \
        python3-httpbin \
        rtmpdump \
        systemtap-sdt-dev \
        tcl-dev \
        texinfo \
        uuid-dev \
        zlib1g-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b development https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
#    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b "REL_${PG_MAJOR}_STABLE" https://github.com/RekGRpth/postgres.git; \
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
    cd "$HOME"; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/postgres -e /src/htmldoc -e /src/mustach | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    gunicorn -b 0.0.0.0:80 httpbin:app -k gevent -D; \
    gosu postgres initdb --auth=trust; \
    echo "max_worker_processes = '128'" >>"$PGDATA/postgresql.auto.conf"; \
    echo "shared_preload_libraries = 'auto_explain,pg_stat_statements,pg_stat_kcache,pg_qualstats,pg_wait_sampling,plugin_debugger,pg_partman_bgw,pg_task'" >>"$PGDATA/postgresql.auto.conf"; \
    gosu postgres pg_ctl -w start; \
    sleep 10; \
    export PGUSER=postgres; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/pg_task -e src/postgres | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 installcheck || (cat regression.diffs; exit 1); done; \
    cd "$HOME/src/pg_task"; \
    export PGDATABASE=postgres; \
    echo "log_min_messages = 'debug1'" >>"$PGDATA/postgresql.auto.conf"; \
    gosu postgres pg_ctl -w reload; \
    make -j"$(nproc)" USE_PGXS=1 installcheck CONTRIB_TESTDB="$PGDATABASE" || (cat "$HOME/src/pg_task/regression.diffs"; exit 1); \
    gosu postgres pg_ctl -m fast -w stop; \
    cd /; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/cache/ldconfig; \
    echo done
