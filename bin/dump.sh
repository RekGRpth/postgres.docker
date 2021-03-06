#!/bin/sh -eux

psql --dbname=target_session_attrs=read-write -Aqtc "select now()"
DT="$(date "+%F %T")"
echo "all dump begin at $DT"
FILE="$(psql -Aqt -c 'SELECT pg_walfile_name(pg_current_wal_lsn())')"
pg_archivecleanup -x .gz "$PGDATA/$ARC" "$FILE"
DUMP="$PGDUMP/$DT"
mkdir -p "$DUMP"
cd "$DUMP"
pg_dumpall --clean --if-exists --globals-only --file=globals.sql --quote-all-identifiers
psql postgres -qtAc "select datname from pg_database" | grep -v template | grep -v postgres | while read -r NAME; do
    echo "$NAME dump begin at $(date "+%F %T")"
    pg_dump --no-tablespaces --jobs=$(nproc) --blobs --disable-triggers --clean --if-exists --create --format=directory --file="$NAME" --quote-all-identifiers --dbname="$NAME" --exclude-schema="_$NAME"
    pg_dump --no-tablespaces --schema-only --blobs --disable-triggers --clean --if-exists --create --format=plain --file="$NAME/schema.sql" --quote-all-identifiers --dbname="$NAME" --exclude-schema="_$NAME"
    echo "$NAME dump end at $(date "+%F %T")"
done
mkdir -p "$PGDUMP/log"
find "$PGDATA/$LOG" -type f -mtime +7 -exec mv '{}' "$PGDUMP/log/" \;
echo "all dump end at $(date "+%F %T")"
cd "$HOME"
find dump -mtime +35 -delete
