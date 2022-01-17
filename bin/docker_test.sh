#!/bin/sh -eux

cd /
gosu postgres pg_ctl initdb
echo "max_worker_processes = '128'" >>"$PGDATA/postgresql.auto.conf"
echo "shared_preload_libraries = 'auto_explain,pg_stat_statements,pg_stat_kcache,pg_qualstats,pg_wait_sampling,plugin_debugger,pg_partman_bgw,pg_task'" >>"$PGDATA/postgresql.auto.conf"
gosu postgres pg_ctl start
sleep 10
export PGUSER=postgres
find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/pg_task -e src/postgres | sort -u | while read -r NAME; do
    cd "$NAME"
    make -j"$(nproc)" USE_PGXS=1 installcheck || (cat regression.diffs; exit 1)
done
cd "$HOME/src/pg_task"
export PGDATABASE=postgres
make -j"$(nproc)" USE_PGXS=1 installcheck CONTRIB_TESTDB="$PGDATABASE" || (cat "$HOME/src/pg_task/regression.diffs"; exit 1)
