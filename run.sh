#!/bin/sh

#docker build --tag rekgrpth/postgres . || exit $?
#docker push rekgrpth/postgres || exit $?
docker stop postgres
docker rm postgres
docker pull rekgrpth/postgres || exit $?
docker volume create postgres || exit $?
docker network create --opt com.docker.network.bridge.name=docker docker
docker run \
    --detach \
    --env GROUP_ID=$(id -g) \
    --env USER_ID=$(id -u) \
    --hostname postgres \
    --link nginx:$(hostname -f) \
    --name postgres \
    --network docker \
    --publish 5432:5432 \
    --restart always \
    --volume /etc/certs/$(hostname -d).crt:/etc/ssl/server.crt \
    --volume /etc/certs/$(hostname -d).key:/etc/ssl/server.key \
    --volume postgres:/home \
    rekgrpth/postgres
