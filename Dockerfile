FROM rekgrpth/gost

MAINTAINER RekGRpth

ADD entrypoint.sh /

ENV ARCLOG_PATH=/data/postgres/pg_arclog \
    BACKUP_PATH=/data/pg_rman \
    GROUP=postgres \
    HOME=/data \
    LANG=ru_RU.UTF-8 \
    PGDATA=/data/postgres \
    SRVLOG_PATH=/data/postgres/pg_log \
    TZ=Asia/Yekaterinburg \
    USER=postgres

RUN apk update --no-cache \
    && apk upgrade --no-cache \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        bison \
        coreutils \
        dpkg \
        dpkg-dev \
        file \
        flex \
        gcc \
        gdal-dev \
        gettext-dev \
        git \
        icu-dev \
        json-c-dev \
        krb5-dev \
        libbsd-dev \
        libc-dev \
        libcrypto1.1 \
        libedit-dev \
        libidn-dev \
        libpsl-dev \
        libssh-dev \
        libtool \
        libxml2-dev \
        libxml2-utils \
        libxslt \
        libxslt-dev \
        linux-headers \
        linux-pam-dev \
        m4 \
        make \
        musl-dev \
        nghttp2-dev \
        openldap-dev \
        openssl-dev \
        pcre-dev \
        perl-dev \
        perl-ipc-run \
        perl-utils \
        postgresql-dev \
        proj4-dev \
        util-linux-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_curl.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_rman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_ssl.git \
    && git clone --recursive https://github.com/RekGRpth/pgtap.git \
    && git clone --recursive https://github.com/RekGRpth/pg_task.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && cd /usr/src/curl \
    && autoreconf -vif \
    && ./configure --with-libssh --with-nghttp2 --enable-ipv6 --enable-unix-sockets \
    && make -j"$(nproc)" curl-config install \
    && cd /usr/src/curl/include \
    && make -j"$(nproc)" install \
    && cd /usr/src/curl/lib \
    && make -j"$(nproc)" install \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" ! -name "curl" | sort -u | while read -r NAME; do \
        echo "$NAME"; \
        cd "$NAME" \
        && make -j"$(nproc)" USE_PGXS=1 install; \
    done \
    && apk add --no-cache --virtual .postgresql-rundeps \
        openssh-client \
        postgresql \
        postgresql-client \
        postgresql-contrib \
        sshpass \
        $( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        ) \
    && apk del --no-cache .build-deps \
    && cd / \
    && rm -rf \
        /usr/src \
        /usr/local/share/doc \
        /usr/local/share/man \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME "${HOME}"

WORKDIR "${HOME}"

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "postgres" ]
