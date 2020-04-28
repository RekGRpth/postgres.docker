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
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env REDIS_HOST=redis \
    --env NODE_ID=2 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres2 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres2,destination=/home \
    --name postgres2 \
    --network name=docker \
    --restart always \
    rekgrpth/postgres
