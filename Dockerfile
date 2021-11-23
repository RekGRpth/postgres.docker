FROM ghcr.io/rekgrpth/pdf.docker:ubuntu
ADD service /etc/service
ARG POSTGRES_VERSION=10
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
        libpcre2-dev \
        libpcre3-dev \
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
        python3-docutils \
        rtmpdump \
        systemtap-sdt-dev \
        texinfo \
        wget \
        zlib1g-dev \
    ; \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list; \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libpq-dev \
        postgresql-${POSTGRES_VERSION} \
        postgresql-client-${POSTGRES_VERSION} \
        postgresql-client-common \
        postgresql-common \
        postgresql-contrib \
        postgresql-server-dev-${POSTGRES_VERSION} \
    ; \
    export PATH="/usr/lib/postgresql/${POSTGRES_VERSION}/bin:${PATH}"; \
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
#    git clone -b master https://github.com/RekGRpth/pg_save.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pgtap.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/plpgsql_check.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
    git clone -b master https://github.com/RekGRpth/postgis.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
#    git clone -b master https://github.com/RekGRpth/repack_bgw.git; \
    git clone -b master https://github.com/RekGRpth/session_variable.git; \
    git clone -b master --recursive https://github.com/RekGRpth/pgqd.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    cd "${HOME}/src/pgqd"; \
    ./autogen.sh; \
    ./configure; \
    cd "${HOME}/src/postgis"; \
    ./autogen.sh; \
    ./configure; \
    cd "${HOME}"; \
    find "${HOME}/src" -maxdepth 1 -mindepth 1 -type d | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    install -d -m 1775 -o postgres -g postgres /run/postgresql /var/log/postgresql /var/lib/postgresql; \
    su postgres -c "/usr/lib/postgresql/${POSTGRES_VERSION}/bin/pg_ctl initdb"; \
    echo "log_min_messages = 'debug1'" >>"${PGDATA}/postgresql.auto.conf"; \
    echo "max_worker_processes = '128'" >>"${PGDATA}/postgresql.auto.conf"; \
    echo "pg_task.json = '[{\"partman\":\"\"}]'" >>"${PGDATA}/postgresql.auto.conf"; \
    echo "shared_preload_libraries = 'pg_task'" >>"${PGDATA}/postgresql.auto.conf"; \
    su postgres -c "/usr/lib/postgresql/${POSTGRES_VERSION}/bin/pg_ctl start"; \
    sleep 10; \
    export PGUSER=postgres; \
    export PGDATABASE=postgres; \
    cd "${HOME}/src/pg_task"; \
    make -j"$(nproc)" USE_PGXS=1 installcheck CONTRIB_TESTDB="${PGDATABASE}" || (cat "${HOME}/src/pg_task/regression.diffs"; exit 1); \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | sort -u  | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get install -y --no-install-recommends \
        cron \
        jq \
        openssh-client \
        postgresql-${POSTGRES_VERSION} \
        postgresql-client-${POSTGRES_VERSION} \
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
