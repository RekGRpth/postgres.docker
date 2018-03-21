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
    PGDATA=/data/postgres

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME  /data
WORKDIR /data/postgres

CMD [ "postgres" ]
