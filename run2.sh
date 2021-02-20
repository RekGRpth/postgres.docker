#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create postgres2
docker stop postgres2 || echo $?
docker rm postgres2 || echo $?
docker run \
    --detach \
    --env CLUSTER_NAME=postgres \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PG_AUTOCTL_FORMATION=postgres \
    --env PG_AUTOCTL_MONITOR=postgres://autoctl_node@postgres0:5432/pg_auto_failover?sslmode=prefer \
    --env PG_AUTOCTL_NAME=postgres2 \
    --env PG_AUTOCTL_REPLICATION_QUORUM=false \
    --env PG_AUTOCTL_SERVER_CERT=/etc/certs/cert.pem \
    --env PG_AUTOCTL_SERVER_KEY=/etc/certs/key.pem \
    --env PG_AUTOCTL_SSL_CA_FILE=/etc/certs/ca.pem \
    --env PG_AUTOCTL_SSL_MODE=prefer \
    --env PG_AUTOCTL=true \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres2 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres2,destination=/home \
    --name postgres2 \
    --network name=docker \
    --restart always \
    rekgrpth/postgres runsvdir /etc/service
