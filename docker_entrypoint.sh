#!/bin/sh -ex

if [ "$GROUP" != "" ]; then
    if [ "$GROUP_ID" = "" ]; then GROUP_ID=$(id -g "$GROUP"); fi
    if [ "$GROUP_ID" != "$(id -g "$GROUP")" ]; then
        groupmod --gid "$GROUP_ID" "$GROUP"
        chgrp "$GROUP_ID" "$HOME"
        chgrp "$GROUP_ID" /run/postgresql
    fi
fi
if [ "$USER" != "" ]; then
    if [ "$USER_ID" = "" ]; then USER_ID=$(id -u "$USER"); fi
    if [ "$USER_ID" != "$(id -u "$USER")" ]; then
        usermod --uid "$USER_ID" "$USER"
        chown "$USER_ID" "$HOME"
        chown "$USER_ID" /run/postgresql
    fi
    if [ ! -s "$PGDATA/PG_VERSION" ]; then
        if [ "$PGINIT" != "" ]; then
            eval su-exec "$USER" $PGINIT --nodename "$(hostname)"
        else
            su-exec "$USER" initdb
        fi
    else
        if [ "$PGEXEC" != "" ]; then
            eval su-exec "$USER" $PGEXEC
        fi
    fi
    exec su-exec "$USER" "$@"
else
    exec "$@"
fi
