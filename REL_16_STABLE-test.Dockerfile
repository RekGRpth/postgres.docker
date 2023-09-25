FROM ghcr.io/rekgrpth/postgres.docker:REL_16_STABLE
RUN set -eux; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build \
        diffutils \
        git \
        make \
        patch \
        perl \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone -b master https://github.com/RekGRpth/pg_curl.git; \
    git clone -b master https://github.com/RekGRpth/pg_htmldoc.git; \
    git clone -b master https://github.com/RekGRpth/pg_jobmon.git; \
    git clone -b master https://github.com/RekGRpth/pgjwt.git; \
    git clone -b master https://github.com/RekGRpth/pg_mustach.git; \
    git clone -b master https://github.com/RekGRpth/pg_partman.git; \
    git clone -b master https://github.com/RekGRpth/pg_qualstats.git; \
    git clone -b master https://github.com/RekGRpth/pg_ssl.git; \
#    git clone -b master https://github.com/RekGRpth/pg_stat_kcache.git; \
    git clone -b master https://github.com/RekGRpth/pg_task.git; \
    git clone -b master https://github.com/RekGRpth/pg_track_settings.git; \
    git clone -b master https://github.com/RekGRpth/pg_wait_sampling.git; \
    git clone -b master https://github.com/RekGRpth/pldebugger.git; \
    git clone -b master https://github.com/RekGRpth/powa-archivist.git; \
    git clone -b master https://github.com/RekGRpth/prefix.git; \
    git clone -b REL1_STABLE https://github.com/RekGRpth/hypopg.git; \
    cd /; \
    gosu postgres initdb --auth=trust; \
    echo "max_worker_processes = '128'" >>"$PGDATA/postgresql.auto.conf"; \
    echo "shared_preload_libraries = 'auto_explain,pg_stat_statements,pg_stat_kcache,pg_qualstats,pg_wait_sampling,plugin_debugger,pg_partman_bgw,pg_task'" >>"$PGDATA/postgresql.auto.conf"; \
    gosu postgres pg_ctl -w start; \
    sleep 10; \
    export PGUSER=postgres; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/pg_task -e src/postgres | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 installcheck || (cat regression.diffs; exit 1); done; \
    cd "$HOME/src/pg_task"; \
    export PGDATABASE=postgres; \
    make -j"$(nproc)" USE_PGXS=1 installcheck CONTRIB_TESTDB="$PGDATABASE" || (cat "$HOME/src/pg_task/regression.diffs"; exit 1); \
    gosu postgres pg_ctl -m fast -w stop; \
    cd /; \
    apk del --no-cache .build; \
    echo done
