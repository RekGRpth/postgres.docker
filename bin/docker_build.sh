#!/bin/sh -eux

PACKAGE_VERSION="$(cat "$HOME/src/postgres/configure" | grep PACKAGE_VERSION= | cut -f2 -d= | tr -d "'")"
PG_VERSION_NUM="$(echo "$PACKAGE_VERSION" | sed 's/[A-Za-z].*$//' | tr '.' '	' | awk '{printf "%d%02d%02d", $1, (NF >= 3) ? $2 : 0, (NF >= 3) ? $3 : $2}')"
cd "$HOME/src/postgres"
./configure \
    --disable-rpath \
    --enable-integer-datetimes \
    --enable-thread-safety \
    --prefix=/usr/local \
    --with-gnu-ld \
    --with-gssapi \
    --with-icu \
    --with-includes=/usr/local/include \
    --with-krb5 \
    --with-ldap \
    --with-libedit-preferred \
    --with-libraries=/usr/local/lib \
    --with-libxml \
    --with-libxslt \
    --with-llvm \
    --with-lz4 \
    --with-openssl \
    --with-pam \
    --with-perl \
    --with-pgport=5432 \
    --with-python \
    --with-system-tzdata=/usr/share/zoneinfo \
    --with-tcl \
    --with-uuid=e2fs \
;
make -j"$(nproc)" -C src install
make -j"$(nproc)" -C contrib install
if [ "$PG_VERSION_NUM" -ge 90600 ]; then
    make -j"$(nproc)" submake-libpq submake-libpgport submake-libpgfeutils install
else
    make -j"$(nproc)" submake-libpq submake-libpgport install
fi
if [ "$PG_VERSION_NUM" -ge 90600 ]; then
    cd "$HOME/src/postgis"
    ./autogen.sh
    ./configure
fi
cd "$HOME"
find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/postgres | sort -u | while read -r NAME; do
    cd "$NAME"
    make -j"$(nproc)" USE_PGXS=1 install || exit 1
done
