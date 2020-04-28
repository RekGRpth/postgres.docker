#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --driver overlay docker || echo $?
docker volume create postgres
docker service rm postgres1 || echo $?
docker service create \
    --constraint node.hostname==docker1 \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env REDIS_HOST=tasks.redis \
    --env NODE_ID=1 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname tasks.postgres1 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres,destination=/var/lib/postgresql \
    --name postgres1 \
    --network name=docker \
    --publish target=5432,published=5432,mode=host \
    --publish target=5433,published=5433,mode=host \
    --replicas-max-per-node 1 \
    rekgrpth/postgres
