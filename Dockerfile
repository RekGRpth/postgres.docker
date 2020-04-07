FROM rekgrpth/pdf
ADD docker_entrypoint.sh /usr/local/bin/
CMD [ "postgres" ]
ENV BACKUP_PATH=${HOME}/pg_rman \
    GROUP=postgres \
    PGDATA=${HOME}/pg_data \
    USER=postgres
VOLUME "${HOME}"
RUN set -ex \
    && mkdir -p "${HOME}" \
    && addgroup -S "${GROUP}" \
    && adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}" \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        binutils \
        bison \
        brotli-dev \
        c-ares-dev \
        file \
        flex \
        g++ \
        gcc \
        gettext-dev \
        git \
        groff \
#        icu-dev \
        krb5-dev \
        libedit-dev \
        libidn2-dev \
        libidn-dev \
        libpsl-dev \
        libssh-dev \
        libtool \
        libxml2-dev \
        linux-headers \
        make \
        mt-st \
        musl-dev \
        nghttp2-dev \
        openldap-dev \
        openssl-dev \
        readline-dev \
        rtmpdump-dev \
        util-linux-dev \
        zfs-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_auto_failover.git \
    && git clone --recursive https://github.com/RekGRpth/pg_backtrace.git \
    && git clone --recursive https://github.com/RekGRpth/pg_curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_htmldoc.git \
    && git clone --recursive https://github.com/RekGRpth/pg_jobmon.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_rman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_ssl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_task.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && git clone --recursive https://github.com/RekGRpth/postgres.git \
#    && git clone --recursive https://github.com/RekGRpth/repmgr.git \
    && cd /usr/src/curl \
    && autoreconf -vif \
    && ./configure \
        --enable-ares \
#        --enable-esni \
        --enable-ipv6 \
        --enable-ldap \
        --enable-libgcc \
        --enable-sspi \
        --enable-unix-sockets \
        --with-gssapi \
        --with-libmetalink \
        --with-librtmp \
        --with-libssh \
        --with-nghttp2 \
        --with-ngtcp2 \
        --with-quiche \
    && make -j"$(nproc)" curl-config install \
    && cd /usr/src/curl/include \
    && make -j"$(nproc)" install \
    && cd /usr/src/curl/lib \
    && make -j"$(nproc)" install \
    && cd /usr/src/postgres \
    && git checkout REL_12_STABLE \
    && ./configure \
#        --enable-cassert \
#        --enable-debug \
        --prefix=/usr/local \
#        --with-icu \
        --with-ldap \
        --with-libedit-preferred \
        --with-libxml \
        --with-openssl \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && make -j"$(nproc)" -C src install \
    && make -j"$(nproc)" -C contrib install \
    && make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install \
#    && cd /usr/src/repmgr \
#    && ./configure \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" ! -name "curl" | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done \
    && (strip /usr/local/bin/* /usr/local/lib/*.so /usr/local/lib/postgresql/*.so || true) \
    && apk add --no-cache --virtual .postgresql-rundeps \
        openssh-client \
        sshpass \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk del --no-cache .build-deps \
    && rm -rf /usr/src /usr/local/share/doc /usr/local/share/man \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /usr/local/bin/docker_entrypoint.sh
