FROM rekgrpth/pdf
ADD service /etc/service
CMD [ "runsvdir", "/etc/service" ]
ENV BACKUP_PATH=${HOME}/pg_rman \
    GROUP=postgres \
    PGDATA=${HOME}/pg_data \
    USER=postgres
VOLUME "${HOME}"
RUN exec 2>&1 \
    && set -ex \
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
        fish-dev \
        flex \
        g++ \
        gcc \
        gettext-dev \
        git \
        groff \
#        icu-dev \
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
#        libxslt-dev \
        linux-headers \
        linux-pam-dev \
        make \
        mt-st \
        musl-dev \
        nghttp2-dev \
        openldap-dev \
        openssl-dev \
        readline-dev \
        rtmpdump-dev \
        udns-dev \
        util-linux-dev \
        zfs-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_backtrace.git \
    && git clone --recursive https://github.com/RekGRpth/pgbouncer.git \
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
    && git clone --recursive https://github.com/RekGRpth/repmgr.git \
    && cd /usr/src/curl \
    && autoreconf -vif \
    && ./configure \
        --enable-ares \
#        --enable-esni \
        --enable-ipv6 \
        --enable-ldap \
        --enable-libgcc \
#        --enable-sspi \
        --enable-unix-sockets \
        --with-gssapi \
        --with-libmetalink \
        --with-librtmp \
        --with-libssh \
        --with-nghttp2 \
#        --with-ngtcp2 \
#        --with-quiche \
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
        --with-gssapi \
#        --with-icu \
        --with-ldap \
        --with-libedit-preferred \
        --with-libxml \
#        --with-libxslt \
        --with-openssl \
        --with-pam \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && make -j"$(nproc)" -C src install \
    && make -j"$(nproc)" -C contrib install \
    && make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install \
    && cd /usr/src/pgbouncer \
    && ./autogen.sh \
    && ./configure \
        --disable-debug \
        --with-pam \
    && make -j"$(nproc)" USE_PGXS=1 install pgbouncer \
    && cd /usr/src/repmgr \
    && ./configure \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "curl" ! -name "pgbouncer" ! -name "postgres" | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done \
    && (strip /usr/local/bin/* /usr/local/lib/*.so /usr/local/lib/postgresql/*.so || true) \
    && apk add --no-cache --virtual .postgresql-rundeps \
        openssh-client \
        openssh-server \
        redis \
        rsync \
        runit \
        sshpass \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk del --no-cache .build-deps \
    && rm -rf /usr/src /usr/local/share/doc /usr/local/share/man \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /usr/local/bin/docker_entrypoint.sh \
    && sed -i -e 's|#PasswordAuthentication yes|PasswordAuthentication no|g' /etc/ssh/sshd_config \
    && sed -i -e 's|#   StrictHostKeyChecking ask|   StrictHostKeyChecking no|g' /etc/ssh/ssh_config \
    && echo "   UserKnownHostsFile=/dev/null" >>/etc/ssh/ssh_config \
#    && sed -i -e 's|postgres:!:|postgres::|g' /etc/shadow \
    && chmod -R 0755 /etc/service \
    && echo done
