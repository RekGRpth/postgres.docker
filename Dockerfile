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
    export DOCKER_TYPE="$(cat /etc/os-release | grep -E '^ID=' | cut -f2 -d '=')"; \
    if [ $DOCKER_TYPE = "alpine" ]; then \
        ln -fs su-exec /sbin/gosu; \
    else \
        export DEBIAN_FRONTEND=noninteractive; \
        export savedAptMark="$(apt-mark showmanual)"; \
    fi; \
    chmod +x /usr/local/bin/*.sh; \
    test "$DOCKER_BUILD" = "build" && "docker_add_group_and_user_$DOCKER_TYPE.sh"; \
    "docker_${DOCKER_BUILD}_$DOCKER_TYPE.sh"; \
    docker_clone.sh; \
    "docker_$DOCKER_BUILD.sh"; \
    "docker_clean_$DOCKER_TYPE.sh"; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 1775 -o "$USER" -g "$GROUP" /run/postgresql /run/postgresql/pg_stat_tmp /var/log/postgresql; \
    install -d -m 0700 -o "$USER" -g "$GROUP" "$PGDATA"; \
    mkdir -p /docker-entrypoint-initdb.d; \
    echo done
