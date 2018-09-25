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
        flex \
        gcc \
        git \
        icu-dev \
        libc-dev \
        libedit-dev \
        libtool \
        libxml2-dev \
        libxml2-utils \
        libxslt-dev \
        libxslt \
        m4 \
        make \
        openssl-dev \
        perl-utils \
        python \
        util-linux-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && git clone --progress --recursive https://github.com/RekGRpth/pg_cron.git /usr/src/pg_cron \
    && git clone --progress --recursive https://github.com/RekGRpth/pg-safeupdate.git /usr/src/pg-safeupdate \
    && git clone --progress --recursive https://github.com/RekGRpth/pgqd.git /usr/src/pgqd \
    && git clone --progress --recursive https://github.com/RekGRpth/pgq.git /usr/src/pgq \
    && git clone --progress --recursive https://github.com/RekGRpth/postgres.git /usr/src/postgres \
    && cd /usr/src/postgres \
    && ./configure \
        --disable-rpath \
        --enable-integer-datetimes \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gnu-ld \
        --with-icu \
        --with-includes=/usr/local/include \
        --with-libraries=/usr/local/lib \
        --with-libxml \
        --with-libxslt \
        --with-openssl \
        --with-pgport=5432 \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
    && make -j "$(nproc)" world \
    && make install-world \
    && make -C contrib install \
    && cd /usr/src/pg-safeupdate \
    && make install \
    && cd /usr/src/pg_cron \
    && make install \
    && cd /usr/src/pgqd/lib \
    && ./autogen.sh \
    && ./configure \
    && cd /usr/src/pgqd \
    && make install \
    && cd /usr/src/pgq \
    && make install \
    && echo "#shared_preload_libraries = 'safeupdate,pg_cron'" >> /usr/local/share/postgresql/postgresql.conf.sample \
    && echo "#cron.database_name = 'cron'" >> /usr/local/share/postgresql/postgresql.conf.sample \
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

WORKDIR ${HOME}/postgres

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "postgres" ]
