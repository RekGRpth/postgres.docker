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
        postgresql \
        postgresql-contrib \
        repmgr \
        shadow \
        su-exec \
        tzdata \
    && apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        postgis \
        barman \
    && find -name "*.pyc" -delete \
    && chmod +x /entrypoint.sh \
    && usermod --home "${HOME}" "${USER}"

VOLUME  ${HOME}

WORKDIR ${HOME}/postgres

ENTRYPOINT ["/entrypoint.sh"]

CMD [ "postgres" ]
