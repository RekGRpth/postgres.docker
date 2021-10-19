FROM ghcr.io/rekgrpth/pdf.docker:ubuntu
ADD service /etc/service
ARG POSTGRES_VERSION=13
CMD [ "/etc/service/postgres/run" ]
ENV HOME=/var/lib/postgresql
WORKDIR "${HOME}"
ENV ARCLOG=../arc \
    GROUP=postgres \
    PATH="${PATH}:/usr/lib/postgresql/${POSTGRES_VERSION}/bin" \
    PGDATA="${HOME}/data" \
    USER=postgres
RUN set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get full-upgrade -y --no-install-recommends; \
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
        libcurl4-openssl-dev \
        libedit-dev \
        libevent-dev \
        libfltk1.3-dev \
        libgcrypt20-dev \
        libgdal-dev \
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
        libnghttp2-dev \
        libpam0g-dev \
        libpcre2-dev \
        libpcre3-dev \
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
        postgresql \
        postgresql-client \
        postgresql-client-common \
        postgresql-common \
        postgresql-contrib \
        postgresql-server-dev-all \
        protobuf-c-compiler \
        python3 \
        rtmpdump \
        systemtap-sdt-dev \
        texinfo \
        zlib1g-dev \
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
    git clone -b master https://github.com/RekGRpth/pgq.git; \
    git clone -b master https://github.com/RekGRpth/pgq-node.git; \
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
    git clone -b master --recursive https://github.com/RekGRpth/pgqd.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    cd "${HOME}"; \
    find "${HOME}/src" -maxdepth 1 -mindepth 1 -type d | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | sort -u  | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get install -y --no-install-recommends \
        cron \
        jq \
        openssh-client \
        postgresql \
        postgresql-client \
        postgresql-client-common \
        postgresql-common \
        postgresql-contrib \
        procps \
        runit \
        sed \
    ; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/cache/ldconfig; \
    chmod -R 0755 /etc/service; \
    rm -f /var/spool/cron/crontabs/root; \
    echo done
