FROM rekgrpth/gost

ADD entrypoint.sh /
ADD plpgsql.patch /usr/src/postgres/
ADD postgres_fdw.patch /usr/src/postgres/

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
        binutils \
        bison \
        brotli-dev \
        dev86 \
        file \
        flex \
        g++ \
        gcc \
        gettext-dev \
        git \
        groff \
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
        openldap-dev \
        openssl-dev \
        postgresql-dev \
        readline-dev \
        util-linux-dev \
        tar \
        wkhtmltopdf-dev \
        wt-dev \
        zfs-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_curl.git \
    && git clone --recursive https://github.com/RekGRpth/pg_html2pdf.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_rman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_ssl.git \
    && git clone --recursive https://github.com/RekGRpth/pgtap.git \
    && git clone --recursive https://github.com/RekGRpth/pg_task.git \
    && git clone --recursive https://github.com/RekGRpth/pg_wkhtmltopdf.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && cd /usr/src/curl \
    && autoreconf -vif \
    && ./configure \
        --enable-ipv6 \
        --enable-ldap \
        --enable-unix-sockets \
        --with-libssh \
        --with-nghttp2 \
    && make -j"$(nproc)" install \
    && cd /usr/src/postgres \
    && curl "https://ftp.postgresql.org/pub/source/v$(curl -s https://git.alpinelinux.org/aports/plain/main/postgresql/APKBUILD | grep pkgver= | cut -d = -f 2)/postgresql-$(curl -s https://git.alpinelinux.org/aports/plain/main/postgresql/APKBUILD | grep pkgver= | cut -d = -f 2).tar.bz2" | tar -jx --strip-components 1 \
    && git apply plpgsql.patch \
    && git apply postgres_fdw.patch \
    && ./configure \
        --disable-rpath \
        --prefix=/usr/local \
        --with-ldap \
        --with-libedit-preferred \
        --with-libxml \
        --with-openssl \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && cd /usr/src/postgres/src/pl/plpgsql \
    && make -j"$(nproc)" install \
    && cd /usr/src/postgres/contrib/postgres_fdw \
    && make -j"$(nproc)" install \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" ! -name "curl" | sort -u | while read -r NAME; do \
        echo "$NAME"; \
        cd "$NAME" \
        && make -j"$(nproc)" USE_PGXS=1 install; \
    done \
    && (strip /usr/local/bin/* /usr/local/lib/*.so /usr/local/lib/postgresql/*.so || true) \
    && apk add --no-cache --virtual .postgresql-rundeps \
        openssh-client \
        postgresql \
        postgresql-contrib \
        sshpass \
        ttf-dejavu \
        $( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local /usr/lib/postgresql \
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
