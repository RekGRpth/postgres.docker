FROM alpine

MAINTAINER RekGRpth

ADD entrypoint.sh /

ENV GROUP=postgres \
    HOME=/data \
    LANG=ru_RU.UTF-8 \
    PGDATA=/data/postgres \
    TZ=Asia/Yekaterinburg \
    USER=postgres

RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories \
    && apk update --no-cache \
    && apk upgrade --no-cache \
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        automake \
        bison \
        boost-dev \
        cmake \
        curl-dev \
        flex \
        g++ \
        gcc \
        git \
        libtool \
        m4 \
        make \
        musl-dev \
        openldap-dev \
        perl-dev \
        perl-utils \
        postgresql-dev \
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
    && git clone --recursive https://github.com/RekGRpth/postgresql-numeral.git \
    && git clone --recursive https://github.com/RekGRpth/postgresql-unit.git \
    && cd /usr/src/pgagent \
    && cmake . \
    && cd /usr/src/pgqd/lib \
    && ./autogen.sh \
    && ./configure \
    && cd / \
    "$(find /usr/src -maxdepth 1 -mindepth 1 -type d ! -name "postgres" | while read -r NAME; do echo "$NAME"; cd "$NAME" && make -j"$(nproc)" USE_PGXS=1 install; done)" \
    && cpan TAP::Parser::SourceHandler::pgTAP \
    && apk add --no-cache --virtual .postgresql-rundeps \
        $( scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
            | tr ',' '\n' \
            | sort -u \
            | grep -v liblwgeom \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
        ) \
        ca-certificates \
        postgis \
        postgresql \
        postgresql-contrib \
        shadow \
        su-exec \
        tzdata \
    && apk del --no-cache .build-deps \
    && cd / \
    && rm -rf \
        /usr/src \
        /usr/local/share/doc \
        /usr/local/share/man \
        /usr/local/include \
    && find /usr/local -name '*.a' -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME "${HOME}"

WORKDIR "${HOME}"

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "postgres" ]
