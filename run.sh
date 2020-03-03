#!/bin/sh

#docker build --tag rekgrpth/postgres . || exit $?
#docker push rekgrpth/postgres || exit $?
docker pull rekgrpth/postgres || exit $?
docker volume create postgres || exit $?
docker network create -d overlay docker
docker service create \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname postgres \
    --mount type=bind,source=/etc/certs,destination=/etc/certs \
    --mount type=volume,source=postgres,destination=/home \
    --name postgres \
    --network docker \
    --publish target=5432,published=5432 \
    rekgrpth/postgres
