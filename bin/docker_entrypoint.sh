#!/bin/sh -ex

if [ "$(id -u)" = '0' ]; then
    if [ -n "$GROUP" ] && [ -n "$GROUP_ID" ] && [ "$GROUP_ID" != "$(id -g "$GROUP")" ]; then
        test -n "$USER" && usermod --home /tmp "$USER"
        groupmod --gid "$GROUP_ID" "$GROUP"
        chgrp "$GROUP_ID" "$HOME"
        test -n "$USER" && usermod --home "$HOME" "$USER"
    fi
    if [ -n "$USER" ] && [ -n "$USER_ID" ] && [ "$USER_ID" != "$(id -u "$USER")" ]; then
        usermod --home /tmp "$USER"
        usermod --uid "$USER_ID" "$USER"
        chown "$USER_ID" "$HOME"
        usermod --home "$HOME" "$USER"
    fi
fi
install -d -m 1775 -o "$USER" -g "$GROUP" /run/postgresql /run/postgresql/pg_stat_tmp /var/log/postgresql
install -d -m 0755 -o "$USER" -g "$GROUP" "$(dirname "$PGDATA")"
install -d -m 0700 -o "$USER" -g "$GROUP" "$PGDATA"
if [ "$(id -u)" = '0' ]; then
    find "$PGDATA" \! -user "$USER" -exec chown "$USER" '{}' +
    find /var/run/postgresql \! -user "$USER" -exec chown "$USER" '{}' +
fi
if [ "$1" = 'postgres' ]; then
    if [ "$(id -u)" = '0' ]; then exec gosu "$USER" "$0" "$@"; fi
    if [ -s "$PGDATA/PG_VERSION" ]; then
        echo done
    else
        ls /docker-entrypoint-initdb.d/ >/dev/null
        initdb -k
        cat >>"$PGDATA/pg_hba.conf" <<EOF
host all all samenet trust
host replication all samenet trust
EOF
        cat >>"$PGDATA/postgresql.auto.conf" <<EOF
listen_addresses = '*'
EOF
        pg_ctl -o "-c listen_addresses=" -w start
        for f in /docker-entrypoint-initdb.d/*; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo "$0: running $f"
                        "$f"
                    else
                        echo "$0: sourcing $f"
                        . "$f"
                    fi
                ;;
                *.sql) echo "$0: running $f"; psql -v ON_ERROR_STOP=1 -w -X -f "$f"; echo ;;
                *.sql.gz) echo "$0: running $f"; gunzip -c "$f" | psql -v ON_ERROR_STOP=1 -w -X; echo ;;
                *.sql.xz) echo "$0: running $f"; xzcat "$f" | psql -v ON_ERROR_STOP=1 -w -X; echo ;;
                *) echo "$0: ignoring $f" ;;
            esac
            echo
        done
        pg_ctl -m fast -w stop
        echo done
    fi
fi
exec "$@"
