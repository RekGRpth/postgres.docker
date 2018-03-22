FROM alpine

MAINTAINER RekGRpth

RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    shadow \
    su-exec \
    tzdata

ENV HOME=/data \
    LANG=ru_RU.UTF-8 \
    TZ=Asia/Yekaterinburg \
    USER=postgres \
    GROUP=postgres \
    PGDATA=/data/postgres

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh && usermod --home "${HOME}" "${USER}"
ENTRYPOINT ["/entrypoint.sh"]

VOLUME  ${HOME}
WORKDIR ${HOME}/postgres

CMD [ "postgres" ]
