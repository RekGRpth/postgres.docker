#!/bin/sh -eux

psql --quiet --dbname=postgres --tuples-only --no-align --file=globals.sql
find -type d -mindepth 1 -maxdepth 1 | sort -u | while read -r FILE; do
    NAME="$(basename -- "$FILE")"
    psql --quiet --dbname=postgres --tuples-only --no-align --command="select pg_terminate_backend(pid) from pg_stat_activity where datname = '$NAME'"
    pg_restore --no-tablespaces --jobs=$(nproc) --clean --if-exists --create --format=directory --verbose --disable-triggers --dbname=postgres "$NAME" || echo "$?"
done
