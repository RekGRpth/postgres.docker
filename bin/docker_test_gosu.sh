#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive
savedAptMark="$(apt-mark showmanual)"
apt-get update
apt-get full-upgrade -y --no-install-recommends
apt-get install -y --no-install-recommends \
    git \
    make \
    patch \
;
