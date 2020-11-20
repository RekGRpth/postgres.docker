#!/bin/sh -ex

#docker build --tag rekgrpth/postgres .
#docker push rekgrpth/postgres
docker pull rekgrpth/postgres
docker network create --attachable --driver overlay dockers || echo $?
docker volume create postgres2
docker service rm postgres2 || echo $?
docker service create \
    --env CLUSTER_NAME=test \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env PG_AUTOCTL_MONITOR=postgres://autoctl_node@tasks.monitor/pg_auto_failover?sslmode=prefer \
    --env PG_AUTOCTL_NAME=postgres2 \
    --env PG_AUTOCTL_REPLICATION_QUORUM=false \
    --env PG_AUTOCTL_SERVER_CERT=/etc/certs/cert.pem \
    --env PG_AUTOCTL_SERVER_KEY=/etc/certs/key.pem \
    --env PG_AUTOCTL_SSL_CA_FILE=/etc/certs/ca.pem \
    --env PG_AUTOCTL_SSL_MODE=prefer \
    --env PG_AUTOCTL=true \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname "{{.Service.Name}}.{{.Task.Slot}}.{{.Task.ID}}.dockers" \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=postgres2,destination=/home \
    --name postgres2 \
    --network name=dockers \
    --replicas-max-per-node 1 \
    rekgrpth/postgres runsvdir /etc/service
