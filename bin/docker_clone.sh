#!/bin/sh -eux

mkdir -p "$HOME/src"
cd "$HOME/src"
if [ "$DOCKER_BUILD" = "build" ]; then
    git clone -b master https://github.com/RekGRpth/pg_curl.git
else
    if [ "$DOCKER_POSTGRES_BRANCH" != "REL_12_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL_11_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL_10_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_6_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
        git clone -b master https://github.com/RekGRpth/pg_curl.git
    fi
fi
git clone -b master https://github.com/RekGRpth/pg_handlebars.git
git clone -b master https://github.com/RekGRpth/pg_htmldoc.git
git clone -b master https://github.com/RekGRpth/pg_jobmon.git
git clone -b master https://github.com/RekGRpth/pgjwt.git
git clone -b master https://github.com/RekGRpth/pg_mustach.git
git clone -b master https://github.com/RekGRpth/pg_partman.git
git clone -b master https://github.com/RekGRpth/pg_qualstats.git
git clone -b master https://github.com/RekGRpth/pg_restrict.git
#git clone -b master https://github.com/RekGRpth/pg_save.git
git clone -b master https://github.com/RekGRpth/pg_ssl.git
git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git
git clone -b master https://github.com/RekGRpth/pgtap.git
git clone -b master https://github.com/RekGRpth/pg_task.git
if [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git
fi
git clone -b master https://github.com/RekGRpth/pldebugger.git
if [ "$DOCKER_POSTGRES_BRANCH" != "REL9_6_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
    git clone -b master https://github.com/RekGRpth/plpgsql_check.git
fi
git clone -b master https://github.com/RekGRpth/powa-archivist.git
git clone -b master https://github.com/RekGRpth/prefix.git
git clone -b master https://github.com/RekGRpth/session_variable.git
git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git
if [ "$DOCKER_BUILD" = "build" ]; then
    git clone -b "$DOCKER_POSTGRES_BRANCH" https://github.com/RekGRpth/postgres.git
    if [ "$DOCKER_POSTGRES_BRANCH" != "REL9_6_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
        git clone -b main https://github.com/RekGRpth/pgcopydb.git
    fi
    if [ "$DOCKER_POSTGRES_BRANCH" != "REL_11_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL_10_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_6_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
        git clone -b master https://github.com/RekGRpth/pg_graphql.git
    fi
    git clone -b master https://github.com/RekGRpth/pg_profile.git
    git clone -b master https://github.com/RekGRpth/pgq.git
    git clone -b master https://github.com/RekGRpth/pgq-node.git
    git clone -b master https://github.com/RekGRpth/pg_repack.git
    git clone -b master https://github.com/RekGRpth/plsh.git
    if [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
        git clone -b master https://github.com/RekGRpth/postgis.git
    fi
    if [ "$DOCKER_POSTGRES_BRANCH" != "REL_10_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_6_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_5_STABLE" ] && [ "$DOCKER_POSTGRES_BRANCH" != "REL9_4_STABLE" ]; then
        git clone -b master https://github.com/RekGRpth/repack_bgw.git
    fi
    git clone -b master --recursive https://github.com/RekGRpth/pgqd.git
fi
