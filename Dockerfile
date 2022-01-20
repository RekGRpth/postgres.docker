ARG DOCKER_FROM=lib.docker:latest
FROM "ghcr.io/rekgrpth/$DOCKER_FROM"
ADD bin /usr/local/bin
ARG DOCKER_BUILD=build
ARG DOCKER_POSTGRES_BRANCH=REL_14_STABLE
CMD [ "postgres" ]
ENV HOME=/var/lib/postgresql
STOPSIGNAL SIGINT
WORKDIR "$HOME"
ENV ARC=../arc \
    GROUP=postgres \
    LOG=../log \
    PGDATA="$HOME/data" \
    USER=postgres
RUN set -eux; \
    export DOCKER_BUILD="$DOCKER_BUILD"; \
    export DOCKER_POSTGRES_BRANCH="$DOCKER_POSTGRES_BRANCH"; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    if [ "$DOCKER_BUILD" = "build" ]; then \
        addgroup -g 70 -S "$GROUP"; \
        adduser -u 70 -S -D -G "$GROUP" -H -h "$HOME" -s /bin/sh "$USER"; \
        apk add --no-cache --virtual .build \
            autoconf \
            automake \
            binutils \
            bison \
            brotli-dev \
            c-ares-dev \
            cjson-dev \
            clang \
            clang-dev \
            curl-dev \
            file \
            flex \
            g++ \
            gcc \
            gdal-dev \
            geos-dev \
            gettext-dev \
            git \
            groff \
            icu-dev \
            jansson-dev \
            json-c-dev \
            krb5-dev \
            libedit-dev \
            libevent-dev \
            libgss-dev \
            libidn2-dev \
            libidn-dev \
            libpsl-dev \
            libssh-dev \
            libtool \
            libxml2-dev \
            libxslt-dev \
            linux-headers \
            linux-pam-dev \
            llvm \
            llvm-dev \
            lz4-dev \
            make \
            mt-st \
            musl-dev \
            nghttp2-dev \
            openldap-dev \
            patch \
            pcre2-dev \
            pcre-dev \
            perl-dev \
            proj-dev \
            protobuf-c-dev \
            py3-docutils \
            python3-dev \
            readline-dev \
            rtmpdump-dev \
            talloc-dev \
            tcl-dev \
            texinfo \
            udns-dev \
            util-linux-dev \
            zlib-dev \
            zstd-dev \
        ; \
    else \
        apk add --no-cache --virtual .build \
            diffutils \
            git \
            make \
            patch \
            perl \
        ; \
    fi; \
    docker_clone.sh; \
    "docker_$DOCKER_BUILD.sh"; \
    cd /; \
    apk add --no-cache --virtual .postgres \
        openssh-client \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | grep -v -e gdal -e geos -e perl -e proj -e python -e tcl | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 1775 -o "$USER" -g "$GROUP" /run/postgresql /run/postgresql/pg_stat_tmp /var/log/postgresql; \
    install -d -m 0700 -o "$USER" -g "$GROUP" "$PGDATA"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo done
