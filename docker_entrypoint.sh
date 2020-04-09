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
    if [ "$PGMONITOR" = "true" ]; then
        if [ "$MONITOR" = "" ]; then
            if [ ! -s "$PGDATA/PG_VERSION" ]; then
                su-exec "$USER" pg_autoctl -vvv create monitor --no-ssl --auth trust --nodename "$(hostname)"
            fi
        else
            if [ ! -s "$PGDATA/PG_VERSION" ]; then
                su-exec "$USER" pg_autoctl -vvv create postgres --no-ssl --auth trust --nodename "$(hostname)" --monitor "$MONITOR"
            fi
        fi
    else
        if [ ! -s "$PGDATA/PG_VERSION" ]; then
            su-exec "$USER" initdb
        fi
    fi
    exec su-exec "$USER" "$@"
else
    exec "$@"
fi
