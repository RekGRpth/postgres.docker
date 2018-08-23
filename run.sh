#!/bin/sh

#docker build --tag rekgrpth/postgres . || exit $?
#docker push rekgrpth/postgres || exit $?
docker stop postgres
docker rm postgres
docker pull rekgrpth/postgres || exit $?
docker volume create postgres || exit $?
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --publish 5432:5432 \
    --name postgres \
    --hostname postgres \
    --restart always \
    --volume postgres:/data \
    rekgrpth/postgres
