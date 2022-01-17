#!/bin/sh -eux

addgroup -g 70 -S "$GROUP"
adduser -u 70 -S -D -G "$GROUP" -H -h "$HOME" -s /bin/sh "$USER"
