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
        boost-dev \
        clang \
        cmake \
        coreutils \
        curl-dev \
        docker \
        dpkg \
        dpkg-dev \
        file \
        flex \
        g++ \
        gcc \
        gdal-dev \
        geos-dev \
        gettext-dev \
        git \
        icu-dev \
        json-c-dev \
        krb5-dev \
        libbsd-dev \
        libc-dev \
        libcrypto1.1 \
        libedit-dev \
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
        openldap-dev \
        openssl-dev \
        pcre-dev \
        perl-dev \
        perl-ipc-run \
        perl-utils \
        proj4-dev \
        python \
        util-linux-dev \
        zlib-dev \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone --recursive https://github.com/RekGRpth/citus.git \
    && git clone --recursive https://github.com/RekGRpth/pgagent.git \
    && git clone --recursive https://github.com/RekGRpth/pg_background.git \
    && git clone --recursive https://github.com/RekGRpth/pg_cron.git \
    && git clone --recursive https://github.com/RekGRpth/pgjwt.git \
    && git clone --recursive https://github.com/RekGRpth/pg_partman.git \
#    && git clone --recursive https://github.com/RekGRpth/pg_probackup.git \
    && git clone --recursive https://github.com/RekGRpth/pg_proctab.git \
    && git clone --recursive https://github.com/RekGRpth/pgqbw.git \
    && git clone --recursive https://github.com/RekGRpth/pgqd.git \
    && git clone --recursive https://github.com/RekGRpth/pgq.git \
    && git clone --recursive https://github.com/RekGRpth/pg_rman.git \
    && git clone --recursive https://github.com/RekGRpth/pg-safeupdate.git \
    && git clone --recursive https://github.com/RekGRpth/pg_scheduler.git \
    && git clone --recursive https://github.com/RekGRpth/pgsentinel.git \
    && git clone --recursive https://github.com/RekGRpth/pg_similarity.git \
    && git clone --recursive https://github.com/RekGRpth/pgsql-http.git \
    && git clone --recursive https://github.com/RekGRpth/pgtap.git \
    && git clone --recursive https://github.com/RekGRpth/pg_variables.git \
    && git clone --recursive https://github.com/RekGRpth/pg_xid.git \
    && git clone --recursive https://github.com/RekGRpth/plsh.git \
    && git clone --recursive https://github.com/RekGRpth/postgis.git \
    && git clone --recursive https://github.com/RekGRpth/postgres.git \
    && git clone --recursive https://github.com/RekGRpth/postgresql-numeral.git \
    && git clone --recursive https://github.com/RekGRpth/postgresql-unit.git \
    && git clone --recursive https://github.com/RekGRpth/timescaledb.git \
    && cd /usr/src/postgres \
    && git checkout --track origin/REL_11_STABLE \
    && ./configure \
        --disable-rpath \
        --enable-integer-datetimes \
        --enable-tap-tests \
        --enable-thread-safety \
        --prefix=/usr/local \
        --with-gnu-ld \
        --with-gssapi \
        --with-icu \
        --with-includes=/usr/local/include \
        --with-ldap \
        --with-libraries=/usr/local/lib \
        --with-libxml \
        --with-libxslt \
        --with-openssl \
        --with-pam \
        --with-pgport=5432 \
        --with-system-tzdata=/usr/share/zoneinfo \
        --with-uuid=e2fs \
#    && make -j"$(nproc)" world \
#    && make -j"$(nproc)" install-world \
    && make -j"$(nproc)" -C src install \
    && make -j"$(nproc)" -C contrib install \
    && make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install \
    && cd /usr/src/pgagent \
    && cmake . \
    && cd /usr/src/pgqd/lib \
    && ./autogen.sh \
    && ./configure \
    && cd /usr/src/postgis \
    && ./autogen.sh \
    && ./configure \
        --disable-gtktest \
        --disable-rpath \
        --prefix=/usr/local \
        --with-gnu-ld \
    && cd /usr/src/citus \
    && ./configure \
    && cd /usr/src/timescaledb \
    && cmake . \
    && cd / \
    && find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" | while read -r NAME; do \
        echo "$NAME"; \
        cd "$NAME" \
        && make -j"$(nproc)" USE_PGXS=1 install; \
    done \
#    && cpan TAP::Parser::SourceHandler::pgTAP \
    && apk add --no-cache --virtual .postgresql-rundeps \
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
#        /usr/local/include \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME "${HOME}"

WORKDIR "${HOME}"

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "postgres" ]
