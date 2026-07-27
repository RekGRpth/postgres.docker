#!/bin/bash -eux

exec 2>&1 &> >(tee build-dev.log)

docker build \
    --file dev.Dockerfile \
    --pull \
    --network=host \
    --tag "ghcr.io/rekgrpth/postgres.docker:dev" \
    .
