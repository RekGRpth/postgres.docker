#!/bin/sh -eux

export BUILDKIT_STEP_LOG_MAX_SIZE=-1
export BUILDKIT_STEP_LOG_MAX_SPEED=-1
export DOCKER_BUILDKIT=1
docker build --progress=plain $(env | grep -v ' ' | sort -u | sed 's@^@--build-arg @g' | paste -s -d ' ') --tag "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-latest}" . 2>&1 | tee build.log
