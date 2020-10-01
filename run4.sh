#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create postgres4
docker stop postgres4 || echo $?
docker rm postgres4 || echo $?
docker run \
    --detach \
    --env CLUSTER_NAME=test \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PG_AUTO_FAILOVER=true \
    --env PG_AUTO_FAILOVER_MONITOR=postgres://autoctl_node@postgres0/pg_auto_failover?sslmode=prefer \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres4 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres4,destination=/home \
    --name postgres4 \
    --network name=docker \
    --restart always \
    rekgrpth/postgres runsvdir /etc/service
