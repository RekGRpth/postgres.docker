#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create postgres0
docker stop postgres0 || echo $?
docker rm postgres0 || echo $?
docker run \
    --detach \
    --env CLUSTER_NAME=monitor \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PG_AUTO_FAILOVER=true \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres0 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres0,destination=/home \
    --name postgres0 \
    --network name=docker \
    --restart always \
    rekgrpth/postgres runsvdir /etc/service
