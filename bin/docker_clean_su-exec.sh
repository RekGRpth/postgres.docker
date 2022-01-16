#!/bin/sh -eux

cd /
apk add --no-cache --virtual .postgresql-rundeps \
    openssh-client \
    su-exec \
    $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v -e gdal -e geos -e perl -e python -e tcl | sort -u | while read -r lib; do test ! -e "/usr/local/lib/$lib" && echo "so:$lib"; done) \
;
find /usr/local/bin -type f -exec strip '{}' \;
find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;
apk del --no-cache .build-deps
