#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create postgres1
docker volume create gfs
docker stop postgres1 || echo $?
docker rm postgres1 || echo $?
docker run \
    --detach \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres1 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=gfs,destination=/var/lib/postgresql/gfs \
    --mount type=volume,source=postgres1,destination=/var/lib/postgresql \
    --name postgres1 \
    --network name=docker \
    --publish target=5432,published=5432,mode=host \
    --publish target=5433,published=5433,mode=host \
    --restart always \
    rekgrpth/postgres
