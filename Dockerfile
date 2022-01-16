ARG DOCKER_FROM=lib.docker:latest
FROM "ghcr.io/rekgrpth/$DOCKER_FROM"
ARG DOCKER_BUILD=true
ARG DOCKER_TYPE=su-exec
ARG INPUTS_BRANCH=latest
ARG POSTGRES_BRANCH=REL_14_STABLE
ADD bin /usr/local/bin
CMD [ "postgres" ]
ENV DOCKER_BUILD="$DOCKER_BUILD" \
    DOCKER_TYPE="$DOCKER_TYPE" \
    HOME=/var/lib/postgresql \
    INPUTS_BRANCH="$INPUTS_BRANCH" \
    POSTGRES_BRANCH="$POSTGRES_BRANCH"
STOPSIGNAL SIGINT
WORKDIR "$HOME"
ENV ARC=../arc \
    GROUP=postgres \
    LOG=../log \
    PGDATA="$HOME/data" \
    USER=postgres
RUN set -eux; \
    env; \
    chmod +x /usr/local/bin/*.sh; \
    test "$DOCKER_BUILD" = "true" && "docker_add_group_and_user_$DOCKER_TYPE.sh"; \
    "docker_build_$DOCKER_TYPE.sh"; \
    docker_clone.sh; \
    test "$DOCKER_BUILD" = "true" && docker_install.sh; \
    test "$DOCKER_BUILD" = "false" && docker_test.sh; \
    "docker_clean_$DOCKER_TYPE.sh"; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 1775 -o "$USER" -g "$GROUP" /run/postgresql /run/postgresql/pg_stat_tmp /var/log/postgresql; \
    install -d -m 0700 -o "$USER" -g "$GROUP" "$PGDATA"; \
    mkdir /docker-entrypoint-initdb.d; \
    echo done
