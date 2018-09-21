FROM alpine

MAINTAINER RekGRpth

ADD entrypoint.sh /

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    TZ=Asia/Yekaterinburg \
    USER=postgres \
    GROUP=postgres \
    PGDATA=/data/postgres

RUN apk add --no-cache \
        alpine-sdk \
        git \
        postgresql \
        postgresql-contrib \
        postgresql-dev \
        repmgr \
        shadow \
        su-exec \
        tzdata \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        pg_cron \
        postgis \
    && mkdir -p /usr/src/pg-safeupdate \
    && git clone --progress https://github.com/eradman/pg-safeupdate.git /usr/src/pg-safeupdate \
    && (cd /usr/src/pg-safeupdate && make install) \
    && rm -rf /usr/src/pg-safeupdate \
    && echo "shared_preload_libraries=safeupdate" >> /usr/share/postgresql/postgresql.conf.sample \
    && apk del \
        alpine-sdk \
        git \
        postgresql-dev \
    && find -name "*.pyc" -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME  ${HOME}

WORKDIR ${HOME}/postgres

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "postgres" ]
