FROM ghcr.io/rekgrpth/pdf.docker:ubuntu
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
    export DEBIAN_FRONTEND=noninteractive; \
    savedAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
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
        gawk \
        gcc \
        gettext \
        git \
        gnupg \
        gnutls-dev \
        groff \
        libbrotli-dev \
        libc-ares-dev \
        libc-dev \
#        libcjson-dev \
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
        libjson-c-dev \
        libkrb5-dev \
        libldap2-dev \
        liblmdb-dev \
        libnghttp2-dev \
        libpam0g-dev \
        libpcre2-dev \
        libpcre3-dev \
        libpng-dev \
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
        libzfslinux-dev \
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
#        postgresql-${POSTGRES_VERSION}-partman \
#        postgresql-${POSTGRES_VERSION}-pldebugger \
#        postgresql-${POSTGRES_VERSION}-plsh \
        postgresql-client-${POSTGRES_VERSION} \
        postgresql-client-common \
        postgresql-common \
        postgresql-contrib \
        postgresql-server-dev-${POSTGRES_VERSION} \
    ; \
    mkdir -p "${HOME}/src"; \
    cd "${HOME}/src"; \
    wget http://ftp.debian.org/debian/pool/main/c/cjson/libcjson1_1.7.14-1_amd64.deb; \
    wget http://ftp.debian.org/debian/pool/main/c/cjson/libcjson-dev_1.7.14-1_amd64.deb; \
    wget http://ftp.debian.org/debian/pool/main/o/opensmtpd/opensmtpd_6.8.0p2-3_amd64.deb; \
    dpkg -i libcjson1_1.7.14-1_amd64.deb libcjson-dev_1.7.14-1_amd64.deb; \
    git clone -b master https://github.com/RekGRpth/gawkextlib.git; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pgdbf.git; \
    git clone -b master https://github.com/RekGRpth/pg_handlebars.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_profile.git; \
    git clone -b master https://github.com/RekGRpth/pg_repack.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/plsh.git; \
    git clone -b "REL_${POSTGRES_VERSION}_STABLE" https://github.com/RekGRpth/pg_async.git; \
    git clone -b "REL_${POSTGRES_VERSION}_STABLE" https://github.com/RekGRpth/pg_save.git; \
    git clone -b "REL_${POSTGRES_VERSION}_STABLE" https://github.com/RekGRpth/pg_task.git; \
    cd "${HOME}/src/gawkextlib/lib"; \
    autoreconf -vif; \
    ./configure; \
    make -j"$(nproc)" install; \
    cd "${HOME}/src/gawkextlib/pgsql"; \
    autoreconf -vif; \
    ./configure --with-libpq="$(pg_config --includedir)"; \
    make -j"$(nproc)" install; \
    cd "${HOME}/src/pgdbf"; \
    autoreconf -fi; \
    ./configure; \
    make -j"$(nproc)" install; \
    cd "${HOME}"; \
    find "${HOME}/src" -maxdepth 1 -mindepth 1 -type d ! -name "gawkextlib" ! -name "pgdbf" | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    cd /; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual; \
    find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | sort -u  | xargs -r apt-mark manual; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    apt-get install -y --no-install-recommends \
        cron \
        ed \
        gawk \
        jq \
        opensmtpd \
        openssh-client \
        postgresql-${POSTGRES_VERSION} \
#        postgresql-${POSTGRES_VERSION}-partman \
#        postgresql-${POSTGRES_VERSION}-pldebugger \
#        postgresql-${POSTGRES_VERSION}-plsh \
        postgresql-client-${POSTGRES_VERSION} \
        postgresql-client-common \
        postgresql-common \
        postgresql-contrib \
        procps \
        runit \
        sed \
    ; \
    cd "${HOME}/src"; \
    dpkg -i libcjson1_1.7.14-1_amd64.deb opensmtpd_6.8.0p2-3_amd64.deb; \
    cd /; \
    find /usr -type f -name "*.a" -delete; \
    find /usr -type f -name "*.la" -delete; \
    rm -rf "${HOME}" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/cache/ldconfig; \
    chmod -R 0755 /etc/service; \
    rm -f /var/spool/cron/crontabs/root; \
    sed -i 's|table aliases|#table aliases|g' /etc/smtpd.conf; \
    sed -i 's|listen on lo|listen on 0.0.0.0|g' /etc/smtpd.conf; \
    sed -i 's|action "local" maildir alias|#action "local" maildir alias|g' /etc/smtpd.conf; \
    sed -i 's|match from local for any action "relay"|match from any for any action "relay"|g' /etc/smtpd.conf; \
    sed -i 's|match for local action "local"|#match for local action "local"|g' /etc/smtpd.conf; \
    echo done
