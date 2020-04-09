#!/bin/sh -ex

#docker build --tag rekgrpth/postgres . || exit $?
#docker push rekgrpth/postgres || exit $?
docker pull rekgrpth/postgres || exit $?
docker volume create postgres || exit $?
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker stop postgres || echo $?
docker rm postgres || echo $?
rm /run/postgresql/* || echo $?
docker run \
    --detach \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname postgres \
    --name postgres \
    --network name=docker \
    --publish target=5432,published=5432,mode=host \
    --restart always \
    --volume /etc/certs/:/etc/certs \
    --volume postgres:/home \
    --volume /run/postgresql:/run/postgresql \
    rekgrpth/postgres
