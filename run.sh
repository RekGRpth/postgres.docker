#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create postgres
docker stop postgres || echo $?
docker rm postgres || echo $?
docker run \
    --detach \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env SERVER_CERT=/etc/certs/cert.pem \
    --env SERVER_KEY=/etc/certs/key.pem \
    --env SSL_CA_FILE=/etc/certs/ca.pem \
    --env SSL_MODE=prefer \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=bind,source=/var/lib/docker/volumes/postgres/_data/pg_data/smtpd.conf,destination=/etc/smtpd/smtpd.conf,readonly \
    --mount type=volume,source=postgres,destination=/home \
    --name postgres \
    --network name=docker,alias=postgres."$(hostname -d)" \
    --publish target=5432,published=5432,mode=host \
    --restart always \
    --tmpfs=/home/pg_data/pg_stat_tmp \
    rekgrpth/postgres runsvdir /etc/service
