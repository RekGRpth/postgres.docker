FROM ghcr.io/rekgrpth/pdf.docker
ADD service /etc/service
ARG POSTGRES_VERSION=13
CMD [ "/etc/service/postgres/run" ]
ENV HOME=/var/lib/postgresql
WORKDIR "${HOME}"
ENV ARC=../arc \
    GROUP=postgres \
    LOG=../log \
    PGDATA="${HOME}/data" \
    USER=postgres
RUN set -eux; \
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
        "postgresql${POSTGRES_VERSION}" \
        "postgresql${POSTGRES_VERSION}-dev" \
        proj-dev \
        protobuf-c-dev \
        py3-docutils \
        readline-dev \
        rtmpdump-dev \
        su-exec \
        talloc-dev \
        texinfo \
        udns-dev \
        util-linux-dev \
        zlib-dev \
        zstd-dev \
    ; \
    export PATH="/usr/libexec/postgresql${POSTGRES_VERSION}:${PATH}"; \
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
#    git clone -b master https://github.com/RekGRpth/pg_async.git; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_handlebars.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_profile.git; \
    git clone -b master https://github.com/RekGRpth/pgq.git; \
    git clone -b master https://github.com/RekGRpth/pgq-node.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_repack.git; \
    git clone -b master https://github.com/RekGRpth/pg_restrict.git; \
    git clone -b master https://github.com/RekGRpth/pg_save.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pgtap.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/plpgsql_check.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
#    git clone -b master https://github.com/RekGRpth/postgis.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b master https://github.com/RekGRpth/repack_bgw.git; \
    git clone -b master https://github.com/RekGRpth/session_variable.git; \
    git clone -b master --recursive https://github.com/RekGRpth/pgqd.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    cd "${HOME}/src/pgqd"; \
    ./autogen.sh; \
    ./configure; \
#    cd "${HOME}/src/postgis"; \
#    ./autogen.sh; \
#    ./configure; \
    cd "${HOME}"; \
    find "${HOME}/src" -maxdepth 1 -mindepth 1 -type d | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apk add --no-cache --virtual .postgresql-rundeps \
        jq \
        openssh-client \
        "postgresql${POSTGRES_VERSION}" \
        "postgresql${POSTGRES_VERSION}-client" \
        "postgresql${POSTGRES_VERSION}-contrib" \
        "postgresql${POSTGRES_VERSION}-contrib-jit" \
        "postgresql${POSTGRES_VERSION}-jit" \
        procps \
        runit \
        sed \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
        $(scanelf --needed --nobanner --format '%n#p' --recursive "/usr/lib/postgresql${POSTGRES_VERSION}" | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    install -d -m 1775 -o postgres -g postgres /run/postgresql /var/log/postgresql /var/lib/postgresql; \
    su-exec postgres pg_ctl initdb; \
    echo "log_min_messages = 'debug1'" >>"${PGDATA}/postgresql.auto.conf"; \
    echo "max_worker_processes = '128'" >>"${PGDATA}/postgresql.auto.conf"; \
    echo "shared_preload_libraries = 'pg_task'" >>"${PGDATA}/postgresql.auto.conf"; \
    su-exec postgres pg_ctl start; \
    sleep 10; \
    export PGUSER=postgres; \
    export PGDATABASE=postgres; \
    cd "${HOME}/src/pg_task"; \
    make -j"$(nproc)" USE_PGXS=1 installcheck CONTRIB_TESTDB="${PGDATABASE}" || (cat "${HOME}/src/pg_task/regression.diffs"; exit 1); \
    apk del --no-cache .build-deps; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    chmod -R 0755 /etc/service; \
    rm -f /var/spool/cron/crontabs/root; \
    echo done
