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
        curl \
        postgresql \
        postgresql-contrib \
        postgresql-dev \
        repmgr \
        shadow \
        su-exec \
        tzdata \
        unzip \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        postgis \
#        barman \
    && (curl "https://bitbucket.org/eradman/pg-safeupdate/get/pg-safeupdate-1.1.zip" --output pg-safeupdate.zip \
        && unzip pg-safeupdate.zip \
        && cd eradman-pg-safeupdate-3e34b479661d \
        && make install \
        && cd .. \
        && rm -rf eradman-pg-safeupdate-3e34b479661d \
        && rm pg-safeupdate.zip) \
    && echo "shared_preload_libraries=safeupdate" >> /usr/share/postgresql/postgresql.conf.sample \
    && apk del \
        alpine-sdk \
        curl \
        postgresql-dev \
        unzip \
    && find -name "*.pyc" -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME  ${HOME}

WORKDIR ${HOME}/postgres

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "postgres" ]
