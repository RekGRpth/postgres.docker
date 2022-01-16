#!/bin/sh -eux

DOCKER_BUILDKIT=1 BUILDKIT_STEP_LOG_MAX_SIZE=-1 BUILDKIT_STEP_LOG_MAX_SPEED=-1 docker build --progress=plain --tag "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-latest}" . 2>&1 | tee build.log
