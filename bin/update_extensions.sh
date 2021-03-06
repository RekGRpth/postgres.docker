#!/bin/sh -eux

pg_ctl status
pg_isready
psql --quiet --tuples-only --no-align --command="select quote_ident(datname) from pg_database where not datistemplate and datallowconn" | while read -r datname; do
    echo "$datname"
    psql --quiet --tuples-only --no-align --dbname="$datname" --command="select quote_ident(name) from pg_available_extensions where installed_version is not null and installed_version != default_version" | while read -r name; do
        echo "$name"
        psql --quiet --tuples-only --no-align --dbname="$datname" --command="alter extension $name update"
    done
done
