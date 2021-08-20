#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/postgres.docker:ubuntu
docker network create --attachable --driver overlay docker || echo $?
docker volume create monitor
docker service rm monitor || echo $?
docker service create \
    --env CLUSTER_NAME=monitor \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PG_AUTOCTL_SERVER_CERT=/etc/certs/cert.pem \
    --env PG_AUTOCTL_SERVER_KEY=/etc/certs/key.pem \
    --env PG_AUTOCTL_SSL_CA_FILE=/etc/certs/ca.pem \
    --env PG_AUTOCTL_SSL_MODE=prefer \
    --env PG_AUTOCTL=true \
    --env PGDATA=/tmp/pg_data \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname monitor \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=monitor,destination=/home \
    --name monitor \
    --network name=docker \
    --replicas-max-per-node 1 \
    ghcr.io/rekgrpth/postgres.docker:REL_13_STABLE runsvdir /etc/service
