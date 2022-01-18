#!/bin/sh -eux

PACKAGE_VERSION="$(cat "$HOME/src/postgres/configure" | grep PACKAGE_VERSION= | cut -f2 -d= | tr -d "'")"
PG_MAJORVERSION=`expr "$PACKAGE_VERSION" : '\([0-9][0-9]*\)'`
PG_MINORVERSION=`expr "$PACKAGE_VERSION" : '.*\.\([0-9][0-9]*\)'`
PG_VERSION_NUM=`echo $PG_MAJORVERSION $PG_MINORVERSION | awk '{printf "%d%04d", $1, $2}'`
if [ "$PG_VERSION_NUM" -lt 90600 ]; then
    ln -fs libldap.a /usr/lib/libldap_r.a
    ln -fs libldap.so /usr/lib/libldap_r.so
fi
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
cd "$HOME/src/postgis" && ./autogen.sh && ./configure
cd "$HOME"
find "$HOME/src" -maxdepth 1 -mindepth 1 -type d | grep -v -e src/postgres | sort -u | while read -r NAME; do
    cd "$NAME"
    make -j"$(nproc)" USE_PGXS=1 install || exit 1
done
