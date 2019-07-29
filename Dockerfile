FROM rekgrpth/pdf
ADD entrypoint.sh /
CMD [ "postgres" ]
ENV ARCLOG_PATH=${HOME}/postgres/pg_arclog \
    BACKUP_PATH=${HOME}/pg_rman \
    GROUP=postgres \
    PGDATA=${HOME}/postgres \
    SRVLOG_PATH=${HOME}/postgres/pg_log \
    USER=postgres
VOLUME "${HOME}"
RUN set -ex \
    && apk update --no-cache \
    && apk upgrade --no-cache \
    && mkdir -p "${HOME}" \
    && addgroup -S "${GROUP}" \
    && adduser -D -S -h "${HOME}" -s /sbin/nologin -G "${GROUP}" "${USER}" \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        binutils \
        bison \
        brotli-dev \
        dev86 \
        file \
        flex \
        freeglut-dev \
        freetype-dev \
        g++ \
        gcc \
        gettext-dev \
        git \
        groff \
        harfbuzz-dev \
        jbig2dec-dev \
        jpeg-dev \
        libedit-dev \
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
        openjpeg-dev \
        openldap-dev \
        openssl-dev \
        readline-dev \
        util-linux-dev \
        zfs-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/pg_curl.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_mupdf.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_rman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_ssl.git \
    && git clone --recursive https://github.com/RekGRpth/pgtap.git \
    && git clone --recursive https://github.com/RekGRpth/pg_task.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && git clone --recursive https://github.com/RekGRpth/postgres.git \
    && cd /usr/src/postgres \
    && git checkout --track origin/REL_11_STABLE \
    && ./configure \
        --disable-rpath \
        --prefix=/usr/local \
        --with-ldap \
        --with-libedit-preferred \
        --with-libxml \
        --with-openssl \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && make -j"$(nproc)" -C src install \
    && make -j"$(nproc)" -C contrib install \
    && make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" ! -name "curl" ! -name "mupdf" | sort -u | while read -r NAME; do echo "$NAME" && cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install || exit 1; done \
    && apk add --no-cache --virtual .postgresql-rundeps \
        openssh-client \
        sshpass \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }') \
    && apk del --no-cache .build-deps \
    && rm -rf /usr/src /usr/local/share/doc /usr/local/share/man \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /entrypoint.sh
