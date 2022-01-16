#!/bin/sh -eux

docker build --progress=plain --tag "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-latest}" $(env | grep -v ' ' | sort -u | sed 's@^@--build-arg @g' | paste -s -d ' ') . 2>&1 | tee build.log
