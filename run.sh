#!/bin/sh -eux

docker pull "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-latest}"
docker network create --attachable --opt com.docker.network.bridge.name=docker docker || echo $?
docker volume create postgres
docker stop postgres || echo $?
docker rm postgres || echo $?
docker run \
    --detach \
    --env ASAN_OPTIONS="detect_odr_violation=0,alloc_dealloc_mismatch=false,halt_on_error=false" \
    --env GROUP_ID="$(id -g)" \
    --env LANG=ru_RU.UTF-8 \
    --env TZ=Asia/Yekaterinburg \
    --env USER_ID="$(id -u)" \
    --hostname postgres \
    --mount type=bind,source=/etc/certs,destination=/etc/certs,readonly \
    --mount type=bind,source=/run/postgresql,destination=/run/postgresql \
    --mount type=volume,source=postgres,destination=/var/lib/postgresql \
    --name postgres \
    --network name=docker \
    --privileged \
    --restart always \
    "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-latest}"
