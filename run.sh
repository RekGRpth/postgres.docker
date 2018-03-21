#!/bin/sh

#docker build --tag rekgrpth/postgres . && \
#docker push rekgrpth/postgres && \
docker stop postgres
docker rm postgres
docker pull rekgrpth/postgres && \
docker volume create postgres && \
docker run \
    --add-host `hostname -f`:`ip -4 addr show docker0 | grep -oP 'inet \K[\d.]+'` \
    --detach \
    --env USER_ID=$(id -u) \
    --env GROUP_ID=$(id -g) \
    --publish 5555:5432 \
    --name postgres \
    --hostname postgres \
    --volume postgres:/data \
    rekgrpth/postgres
