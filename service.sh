#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --driver overlay docker || echo $?
docker volume create postgres
docker volume create --driver glusterfs gfs
docker service rm postgres || echo $?
docker service create \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres-{{.Node.Hostname}} \
    --mode global \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/mnt/gfs/postgres,destination=/home/gfs \
    --mount type=bind,source=/mnt/gfs/postgres/hosts,destination=/etc/hosts.gfs \
    --mount type=volume,source=postgres,destination=/home \
    --name postgres \
    --network name=docker \
    --publish target=5432,published=5432,mode=host \
    --publish target=5433,published=5433,mode=host \
    rekgrpth/postgres
