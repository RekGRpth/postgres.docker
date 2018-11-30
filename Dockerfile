FROM alpine

MAINTAINER RekGRpth

ADD entrypoint.sh /

ENV GROUP=postgres \
    HOME=/data \
    LANG=ru_RU.UTF-8 \
    PGDATA=/data/postgres \
    TZ=Asia/Yekaterinburg \
    USER=postgres

RUN apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        bison \
        boost-dev \
        cmake \
        curl-dev \
        file \
        flex \
        g++ \
        gcc \
        gettext-dev \
        git \
        icu-dev \
        krb5-dev \
        libc-dev \
        libedit-dev \
        libtool \
        libxml2-dev \
        libxml2-utils \
        libxslt \
        libxslt-dev \
        linux-pam-dev \
        m4 \
        make \
        musl-dev \
        openldap-dev \
        perl-dev \
        perl-utils \
        python \
        util-linux-dev \
        zlib-dev \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main --virtual .build-deps \
        libcrypto1.1 \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --virtual .build-deps \
        gdal-dev \
        geos-dev \
        proj4-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/pgagent.git \
    && git clone --recursive https://github.com/RekGRpth/pg_background.git \
    && git clone --recursive https://github.com/RekGRpth/pg_cron.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
    && git clone --recursive https://github.com/RekGRpth/pg_proctab.git \
    && git clone --recursive https://github.com/RekGRpth/pgqbw.git \
    && git clone --recursive https://github.com/RekGRpth/pgqd.git \
    && git clone --recursive https://github.com/RekGRpth/pgq.git \
    && git clone --recursive https://github.com/RekGRpth/pg-safeupdate.git \
    && git clone --recursive https://github.com/RekGRpth/pgsql-http.git \
    && git clone --recursive https://github.com/RekGRpth/pgtap.git \
    && git clone --recursive https://github.com/RekGRpth/pg_variables.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && git clone --recursive https://github.com/RekGRpth/postgis.git \
    && git clone --recursive https://github.com/RekGRpth/postgres.git \
    && git clone --recursive https://github.com/RekGRpth/postgresql-numeral.git \
    && git clone --recursive https://github.com/RekGRpth/postgresql-unit.git \
    && cd /usr/src/postgres \
    && git checkout --track origin/REL_11_STABLE \
    && ./configure \
        --disable-rpath \
        --enable-integer-datetimes \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gnu-ld \
        --with-gssapi \
        --with-icu \
        --with-includes=/usr/local/include \
        --with-krb5 \
        --with-ldap \
        --with-libraries=/usr/local/lib \
        --with-libxml \
        --with-libxslt \
        --with-openssl \
        --with-pam \
        --with-pgport=5432 \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && make -j"$(nproc)" world \
    && make install-world \
    && make -C contrib install \
    && cd /usr/src/pgagent \
    && cmake . \
    && cd /usr/src/pgqd/lib \
    && ./autogen.sh \
    && ./configure \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && cd / \
    $(find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" | while read -r NAME; do echo "$NAME"; cd "$NAME" && make USE_PGXS=1 install; done) \
    && cpan TAP::Parser::SourceHandler::pgTAP \
    && runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" \
    && apk add --no-cache --virtual .postgresql-rundeps \
        $runDeps \
        shadow \
        su-exec \
        tzdata \
    && apk del .build-deps \
    && cd / \
    && rm -rf \
        /usr/src \
        /usr/local/share/doc \
        /usr/local/share/man \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME  ${HOME}

WORKDIR ${HOME}

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "postgres" ]
