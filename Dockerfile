FROM ghcr.io/rekgrpth/pdf.docker
ADD service /etc/service
ARG POSTGRES_BRANCH=REL9_3_STABLE
CMD [ "/etc/service/postgres/run" ]
ENV HOME=/var/lib/postgresql
STOPSIGNAL SIGINT
WORKDIR "${HOME}"
ENV ARC=../arc \
    GROUP=postgres \
    LOG=../log \
    PGDATA="${HOME}/data" \
    USER=postgres
RUN set -eux; \
    addgroup -S "${GROUP}"; \
    adduser -D -S -h "${HOME}" -s /bin/ash -G "${GROUP}" "${USER}"; \
    ln -s libldap.a /usr/lib/libldap_r.a; \
    ln -s libldap.so /usr/lib/libldap_r.so; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build-deps \
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
        python2-dev \
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
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
#    git clone -b master https://github.com/RekGRpth/pg_async.git; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
#    git clone -b master https://github.com/RekGRpth/pg_graphql.git; \
    git clone -b master https://github.com/RekGRpth/pg_handlebars.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
#    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_profile.git; \
#    git clone -b master https://github.com/RekGRpth/pgq.git; \
#    git clone -b master https://github.com/RekGRpth/pgq-node.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
#    git clone -b master https://github.com/RekGRpth/pg_repack.git; \
    git clone -b master https://github.com/RekGRpth/pg_restrict.git; \
#    git clone -b master https://github.com/RekGRpth/pg_save.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
#    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pgtap.git; \
#    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
#    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
#    git clone -b master https://github.com/RekGRpth/plpgsql_check.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
#    git clone -b master https://github.com/RekGRpth/postgis.git; \
#    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
#    git clone -b master https://github.com/RekGRpth/repack_bgw.git; \
    git clone -b master https://github.com/RekGRpth/session_variable.git; \
#    git clone -b master --recursive https://github.com/RekGRpth/pgqd.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    git clone -b "${POSTGRES_BRANCH}" https://github.com/RekGRpth/postgres.git; \
    cd "${HOME}/src/postgres"; \
    ./configure \
        --disable-rpath \
#        --enable-debug \
        --enable-integer-datetimes \
#        --enable-nls \
#        --enable-tap-tests \
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
    make -j"$(nproc)" submake-libpq submake-libpgport install; \
#    cd "${HOME}/src/pgqd"; \
#    ./autogen.sh; \
#    ./configure; \
#    cd "${HOME}/src/postgis"; \
#    ./autogen.sh; \
#    ./configure; \
    cd "${HOME}"; \
    find "${HOME}/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/libgraphqlparser -e src/postgres | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apk add --no-cache --virtual .postgresql-rundeps \
        jq \
        openssh-client \
        procps \
        runit \
        sed \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v -e perl -e python -e tcl | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
#    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    chmod -R 0755 /etc/service; \
    rm -f /var/spool/cron/crontabs/root; \
    mkdir -p /var/run/postgresql; \
    mkdir -p "${HOME}"; \
    chown -R "${USER}":"${GROUP}" "${HOME}"; \
    chmod 2777 /var/run/postgresql; \
    mkdir -p "${PGDATA}"; \
    chown -R "${USER}":"${GROUP}" "${PGDATA}"; \
    chmod 777 "${PGDATA}"; \
    mkdir /docker-entrypoint-initdb.d; \
    echo done
