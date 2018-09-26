#!/bin/sh

#docker build --tag rekgrpth/postgres . || exit $?
#docker push rekgrpth/postgres || exit $?
docker stop postgres
docker stop pgqd
docker rm postgres
docker rm pgqd
docker pull rekgrpth/postgres || exit $?
docker volume create postgres || exit $?
docker network create my
docker run \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --publish 5432:5432 \
    --name postgres \
    --network my \
    --hostname postgres \
    --restart always \
    --volume postgres:/data \
    rekgrpth/postgres
docker run \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --name pgqd \
    --network my \
    --hostname pgqd \
    --restart always \
    --volume postgres:/data \
    rekgrpth/postgres pgqd /data/pgqd/pgqd.ini
