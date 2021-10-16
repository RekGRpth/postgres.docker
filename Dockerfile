FROM ghcr.io/rekgrpth/pdf.docker
ADD service /etc/service
ARG POSTGRES_VERSION=13
CMD [ "/etc/service/postgres/run" ]
ENV HOME=/var/lib/postgresql
WORKDIR "${HOME}"
ENV ARCLOG=../arc \
    GROUP=postgres \
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
        curl-dev \
        file \
        flex \
        g++ \
        gcc \
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
        openssl-dev \
        patch \
        postgresql \
        postgresql-dev \
        proj-dev \
        protobuf-c-dev \
        readline-dev \
        rtmpdump-dev \
        talloc-dev \
        texinfo \
        udns-dev \
        util-linux-dev \
        zlib-dev \
        zstd-dev \
    ; \
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
    git clone -b master https://github.com/RekGRpth/pg_async.git; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_handlebars.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_pathman.git; \
    git clone -b master https://github.com/RekGRpth/pg_profile.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_repack.git; \
    git clone -b master https://github.com/RekGRpth/pg_restrict.git; \
    git clone -b master https://github.com/RekGRpth/pg_save.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/plpgsql_check.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b master https://github.com/RekGRpth/repack_bgw.git; \
    git clone -b master https://github.com/RekGRpth/session_variable.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    cd "${HOME}"; \
    find "${HOME}/src" -maxdepth 1 -mindepth 1 -type d | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apk add --no-cache --virtual .postgresql-rundeps \
        jq \
        openssh-client \
        postgresql \
        postgresql-contrib \
        procps \
        runit \
        sed \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/lib/postgresql | tr ',' '\n' | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build-deps; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    chmod -R 0755 /etc/service; \
    rm -f /var/spool/cron/crontabs/root; \
    echo done
