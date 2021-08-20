#!/bin/sh -eux

docker pull ghcr.io/rekgrpth/postgres.docker:ubuntu
docker network create --attachable --driver overlay docker || echo $?
docker volume create postgres1
docker service rm postgres1 || echo $?
docker service create \
    --env CLUSTER_NAME=test \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PG_AUTOCTL_FORMATION=test \
    --env PG_AUTOCTL_MONITOR=postgres://autoctl_node@tasks.monitor:5432/pg_auto_failover?sslmode=prefer \
    --env PG_AUTOCTL_NAME=postgres1 \
    --env PG_AUTOCTL_REPLICATION_QUORUM=false \
    --env PG_AUTOCTL_SERVER_CERT=/etc/certs/cert.pem \
    --env PG_AUTOCTL_SERVER_KEY=/etc/certs/key.pem \
    --env PG_AUTOCTL_SSL_CA_FILE=/etc/certs/ca.pem \
    --env PG_AUTOCTL_SSL_MODE=prefer \
    --env PG_AUTOCTL=true \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname tasks.postgres1 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres1,destination=/home \
    --name postgres1 \
    --network name=docker \
    --replicas-max-per-node 1 \
    ghcr.io/rekgrpth/postgres.docker:ubuntu runsvdir /etc/service
