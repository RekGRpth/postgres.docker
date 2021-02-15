FROM rekgrpth/pdf:ubuntu
ADD service /etc/service
CMD /etc/service/postgres/run
ENV BACKUP_PATH=${HOME}/pg_rman \
    GROUP=postgres \
    PGDATA=${HOME}/pg_data \
    USER=postgres
VOLUME "${HOME}"
RUN exec 2>&1 \
    && set -ex \
    && mkdir -p "${HOME}" \
    && addgroup --system "${GROUP}" \
    && adduser --disabled-password --system --home "${HOME}" --shell /sbin/nologin --ingroup "${GROUP}" "${USER}" \
    && savedAptMark="$(apt-mark showmanual)" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        autopoint \
        binutils \
        bison \
        clang \
        file \
        flex \
        g++ \
        gawk \
        gcc \
        gettext \
        git \
        groff \
        libbrotli-dev \
        libc-ares-dev \
        libcurl4-openssl-dev \
        libedit-dev \
        libevent-dev \
        libgdal-dev \
        libgeos-dev \
        libgss-dev \
        libicu-dev \
        libidn11-dev \
        libidn2-dev \
        libjson-c-dev \
        libkrb5-dev \
        libldap2-dev \
        libnghttp2-dev \
        libpam0g-dev \
        libproj-dev \
        libprotobuf-c-dev \
        libpsl-dev \
        libreadline-dev \
        libssh-dev \
        libssl-dev \
        libtool \
        libudns-dev \
        libunwind-dev \
        libxml2-dev \
        libxslt-dev \
        libzfslinux-dev \
        libzstd-dev \
        linux-headers-generic \
        linux-libc-dev \
        llvm \
        llvm-dev \
        make \
        mt-st \
        patch \
        protobuf-c-compiler \
        rtmpdump \
        texinfo \
        zlib1g-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/gawkextlib.git \
    && git clone --recursive https://github.com/RekGRpth/pg_auto_failover.git \
    && git clone --recursive https://github.com/RekGRpth/pg_backtrace.git \
    && git clone --recursive https://github.com/RekGRpth/pgbouncer.git \
    && git clone --recursive https://github.com/RekGRpth/pg_curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_htmldoc.git \
    && git clone --recursive https://github.com/RekGRpth/pg_jobmon.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_mustach.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
    && git clone --recursive https://github.com/RekGRpth/pgq.git \
    && git clone --recursive https://github.com/RekGRpth/pgq-node.git \
    && git clone --recursive https://github.com/RekGRpth/pg_repack.git \
    && git clone --recursive https://github.com/RekGRpth/pg_rman.git \
    && git clone --recursive https://github.com/RekGRpth/pgsidekick.git \
    && git clone --recursive https://github.com/RekGRpth/pg_ssl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_task.git \
    && git clone --recursive https://github.com/RekGRpth/pldebugger.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && git clone --recursive https://github.com/RekGRpth/postgis.git \
    && git clone --recursive https://github.com/RekGRpth/postgres.git \
    && git clone --recursive https://github.com/RekGRpth/slony1-engine.git \
    && cd /usr/src/postgres \
    && git checkout REL_13_STABLE \
    && ./configure \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gssapi \
        --with-icu \
        --with-ldap \
        --with-libedit-preferred \
        --with-libxml \
        --with-libxslt \
        --with-llvm \
        --with-openssl \
        --with-pam \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && make -j"$(nproc)" -C src install \
    && make -j"$(nproc)" -C contrib install \
    && make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install \
    && cd /usr/src/gawkextlib/lib \
    && autoreconf -vif \
    && ./configure \
    && make -j"$(nproc)" install \
    && cd /usr/src/gawkextlib/pgsql \
    && autoreconf -vif \
    && ./configure \
    && make -j"$(nproc)" install \
    && cd /usr/src/pgsidekick \
    && make -j"$(nproc)" pglisten \
    && cp -f pglisten /usr/local/bin/ \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && cd /usr/src/pgbouncer \
    && ./autogen.sh \
    && ./configure \
        --disable-debug \
        --with-pam \
    && cd /usr/src/slony1-engine \
    && autoconf \
    && ./configure \
    && make \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" ! -name "pgsidekick" ! -name "gawkextlib" ! -name "linux-headers-*" | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done \
    && apt-mark auto '.*' > /dev/null \
    && apt-mark manual $savedAptMark \
    && find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | sort -u | xargs -r apt-mark manual \
    && find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | sort -u  | xargs -r apt-mark manual \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get install -y --no-install-recommends \
        cron \
        gawk \
        jq \
        locales \
        opensmtpd \
        openssh-client \
        procps \
        runit \
        sed \
    && locale-gen --lang ${LANG} \
    && rm -rf /usr/src /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man \
    && find /usr/local -name '*.a' -delete \
    && chmod -R 0755 /etc/service \
    && rm -f /var/spool/cron/crontabs/root \
    && sed -i 's|table aliases|#table aliases|g' /etc/smtpd.conf \
    && sed -i 's|listen on lo|listen on 0.0.0.0|g' /etc/smtpd.conf \
    && sed -i 's|action "local" maildir alias|#action "local" maildir alias|g' /etc/smtpd.conf \
    && sed -i 's|match from local for any action "relay"|match from any for any action "relay"|g' /etc/smtpd.conf \
    && sed -i 's|match for local action "local"|#match for local action "local"|g' /etc/smtpd.conf \
    && echo done
