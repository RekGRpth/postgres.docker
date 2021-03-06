#!/bin/sh -eux

docker build --progress=plain --tag "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-oracle}" $(env | grep -E '^DOCKER_' | grep -v ' ' | sort -u | sed 's@^@--build-arg @g' | paste -s -d ' ') --file "${INPUTS_DOCKERFILE:-oracle.Dockerfile}" . 2>&1 | tee build.log
