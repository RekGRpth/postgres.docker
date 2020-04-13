#!/bin/sh -x

#docker build --tag rekgrpth/postgres . || exit $?
#docker push rekgrpth/postgres || exit $?
docker pull rekgrpth/postgres || exit $?
docker volume create monitor || echo $?
docker volume create postgres || echo $?
docker network create --attachable --driver overlay docker || echo $?
docker service rm postgres-1 || echo $?
docker service rm postgres-1 || echo $?
docker service rm monitor || echo $?
rm /run/postgresql/* || echo $?
docker service create \
    --constraint node.role==manager \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env MONITOR="-vvv create monitor --ssl-self-signed --auth trust" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname tasks.monitor \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=volume,source=monitor,destination=/home \
    --name monitor \
    --network name=docker \
    --replicas-max-per-node 1 \
    rekgrpth/postgres pg_autoctl -vvv run
docker service create \
    --constraint node.labels.host==docker-1 \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env MONITOR="-vvv create postgres --ssl-self-signed --auth trust --monitor=postgres://autoctl_node@tasks.monitor:5432/pg_auto_failover" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname tasks.postgres-1 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=volume,source=postgres,destination=/home \
    --name postgres-1 \
    --network name=docker \
    --publish target=5432,published=5432,mode=host \
    --replicas-max-per-node 1 \
    rekgrpth/postgres pg_autoctl -vvv run
docker service create \
    --constraint node.labels.host==docker-2 \
    --env GROUP_ID=$(id -g) \
    --env LANG=ru_RU.UTF-8 \
    --env MONITOR="-vvv create postgres --ssl-self-signed --auth trust --monitor=postgres://autoctl_node@tasks.monitor:5432/pg_auto_failover" \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID=$(id -u) \
    --hostname tasks.postgres-2 \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=volume,source=postgres,destination=/home \
    --name postgres-2 \
    --network name=docker \
    --publish target=5432,published=5432,mode=host \
    --replicas-max-per-node 1 \
    rekgrpth/postgres pg_autoctl -vvv run
