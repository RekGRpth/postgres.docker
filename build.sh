#!/bin/sh -eux

DOCKER_BUILDKIT=1 docker build --progress=plain --tag ghcr.io/rekgrpth/postgres.docker:alpine-12 . 2>&1 | tee build.log
