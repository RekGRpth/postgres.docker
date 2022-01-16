#!/bin/sh -eux

mkdir -p "$HOME/src"
cd "$HOME/src"
git clone -b master https://github.com/RekGRpth/pg_curl.git
git clone -b master https://github.com/RekGRpth/pg_handlebars.git
git clone -b master https://github.com/RekGRpth/pg_htmldoc.git
git clone -b master https://github.com/RekGRpth/pg_jobmon.git
git clone -b master https://github.com/RekGRpth/pgjwt.git
git clone -b master https://github.com/RekGRpth/pg_mustach.git
git clone -b master https://github.com/RekGRpth/pg_partman.git
git clone -b master https://github.com/RekGRpth/pg_qualstats.git
git clone -b master https://github.com/RekGRpth/pg_restrict.git
git clone -b master https://github.com/RekGRpth/pg_save.git
git clone -b master https://github.com/RekGRpth/pg_ssl.git
git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git
git clone -b master https://github.com/RekGRpth/pgtap.git
git clone -b master https://github.com/RekGRpth/pg_task.git
git clone -b master https://github.com/RekGRpth/pg_track_settings.git
git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git
git clone -b master https://github.com/RekGRpth/pldebugger.git
git clone -b master https://github.com/RekGRpth/plpgsql_check.git
git clone -b master https://github.com/RekGRpth/powa-archivist.git
git clone -b master https://github.com/RekGRpth/prefix.git
git clone -b master https://github.com/RekGRpth/session_variable.git
git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git
test "$DOCKER_BUILD" = "build" && git clone -b "$DOCKER_POSTGRES_BRANCH" https://github.com/RekGRpth/postgres.git
test "$DOCKER_BUILD" = "build" && git clone -b main https://github.com/RekGRpth/pgcopydb.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/pg_graphql.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/pg_profile.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/pgq.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/pgq-node.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/pg_repack.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/plsh.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/postgis.git
test "$DOCKER_BUILD" = "build" && git clone -b master https://github.com/RekGRpth/repack_bgw.git
test "$DOCKER_BUILD" = "build" && git clone -b master --recursive https://github.com/RekGRpth/pgqd.git
