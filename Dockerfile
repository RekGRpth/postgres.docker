FROM alpine

MAINTAINER RekGRpth

RUN apk add --no-cache \
    postgresql \
#    postgresql-bdr \
#    postgresql-bdr-contrib \
    postgresql-contrib \
    shadow \
    su-exec \
    tzdata

ENV HOME /data
ENV LANG ru_RU.UTF-8
ENV TZ   Asia/Yekaterinburg

ENV PGDATA /data/postgres

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

VOLUME  /data
WORKDIR /data/postgres

CMD [ "postgres" ]
