#!/bin/sh -eux

docker build --progress=plain $(env | grep -v ' ' | sort -u | sed 's@^@--build-arg @g' | paste -s -d ' ') --tag "ghcr.io/rekgrpth/postgres.docker:${INPUTS_BRANCH:-latest}" . 2>&1 | tee build.log
