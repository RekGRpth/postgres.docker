#!/bin/sh -eux

mkdir -p "$HOME/src"
cd "$HOME/src"
if [ "$DOCKER_BUILD" = "build" ]; then
    git clone -b "$DOCKER_POSTGRES_BRANCH" https://github.com/RekGRpth/postgres.git
    PACKAGE_VERSION="$(cat "$HOME/src/postgres/configure" | grep PACKAGE_VERSION= | cut -f2 -d= | tr -d "'")"
    PG_VERSION_NUM="$(echo "$PACKAGE_VERSION" | sed 's/[A-Za-z].*$//' | tr '.' '	' | awk '{printf "%d%02d%02d", $1, (NF >= 3) ? $2 : 0, (NF >= 3) ? $3 : $2}')"
    git clone -b master https://github.com/RekGRpth/pg_curl.git
    git clone -b master https://github.com/RekGRpth/plsh.git
    git clone -b master https://github.com/RekGRpth/powa-archivist.git
    git clone -b master https://github.com/RekGRpth/session_variable.git
    if [ "$PG_VERSION_NUM" -ge 100000 ]; then git clone -b main https://github.com/RekGRpth/pgcopydb.git; fi
    if [ "$PG_VERSION_NUM" -ge 120000 ]; then git clone -b master https://github.com/RekGRpth/pg_graphql.git; fi
    if [ "$PG_VERSION_NUM" -ge 90600 ]; then git clone -b master https://github.com/RekGRpth/postgis.git; fi
else
    PG_VERSION_NUM="$(cat /usr/local/include/postgresql/server/pg_config.h | grep PG_VERSION_NUM | cut -f3 -d ' ')"
    if [ "$PG_VERSION_NUM" -ge 130000 ]; then git clone -b master https://github.com/RekGRpth/pg_curl.git; fi
    if [ "$PG_VERSION_NUM" -ge 90500 ]; then git clone -b master https://github.com/RekGRpth/powa-archivist.git; fi
    if [ "$PG_VERSION_NUM" -ge 110000 ]; then git clone -b master https://github.com/RekGRpth/session_variable.git; fi
fi
git clone -b master https://github.com/RekGRpth/pg_handlebars.git
git clone -b master https://github.com/RekGRpth/pg_htmldoc.git
git clone -b master https://github.com/RekGRpth/pg_jobmon.git
git clone -b master https://github.com/RekGRpth/pgjwt.git
git clone -b master https://github.com/RekGRpth/pg_mustach.git
git clone -b master https://github.com/RekGRpth/pg_partman.git
git clone -b master https://github.com/RekGRpth/pg_qualstats.git
#git clone -b master https://github.com/RekGRpth/pg_save.git
git clone -b master https://github.com/RekGRpth/pg_ssl.git
git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git
git clone -b master https://github.com/RekGRpth/pgtap.git
git clone -b master https://github.com/RekGRpth/pg_task.git
git clone -b master https://github.com/RekGRpth/pldebugger.git
git clone -b master https://github.com/RekGRpth/prefix.git
git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git
if [ "$PG_VERSION_NUM" -ge 140000 ]; then git clone -b main https://github.com/RekGRpth/pg_injection.git; fi
if [ "$PG_VERSION_NUM" -ge 90600 ]; then git clone -b master https://github.com/RekGRpth/pg_track_settings.git; fi
if [ "$PG_VERSION_NUM" -ge 90600 ]; then git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; fi
