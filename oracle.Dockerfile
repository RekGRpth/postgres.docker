FROM ghcr.io/rekgrpth/postgres.docker:gost
ADD fakeglibc.c "$HOME/src/"
ENV LD_PRELOAD=/usr/local/lib/fakeglibc.so
RUN set -eux; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build \
        clang \
        clang-dev \
        gcc \
        git \
        llvm \
        llvm-dev \
        make \
        mariadb-dev \
        musl-dev \
        sqlite-dev \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    gcc -c fakeglibc.c -fPIC -o fakeglibc.o; \
    gcc -shared -o /usr/local/lib/fakeglibc.so -fPIC fakeglibc.o; \
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip; \
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip; \
    unzip instantclient-basiclite-linuxx64.zip; \
    unzip instantclient-sdk-linuxx64.zip; \
    mkdir -p /usr/local/include /usr/local/bin /usr/local/lib; \
    cp -r instantclient*/*.so* /usr/local/lib/; \
    cp -r instantclient*/sdk/include/*.h /usr/local/include/; \
    cd "$HOME"; \
    ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1; \
    ln -s /lib/libc.so.6 /usr/lib/libresolv.so.2; \
    ln -s /lib64/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2; \
    cd "$HOME/src"; \
    git clone -b master https://github.com/RekGRpth/dblink_plus.git; \
    git clone -b master https://github.com/RekGRpth/oracle_fdw.git; \
    cd "$HOME"; \
    find "$HOME/src" -maxdepth 1 -mindepth 1 -type d ! -name "instantclient*" | sort -u | while read -r NAME; do cd "$NAME"; make -j"$(nproc)" USE_PGXS=1 install || exit 1; done; \
    apk add --no-cache --virtual .oracle \
        libaio \
        libc6-compat \
        libnsl \
    ; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 1775 -o "$USER" -g "$GROUP" /run/postgresql /run/postgresql/pg_stat_tmp /var/log/postgresql; \
    install -d -m 0700 -o "$USER" -g "$GROUP" "$PGDATA"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo done
