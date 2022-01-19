#!/bin/sh -eux

cd /
apt-mark auto '.*' > /dev/null
apt-mark manual $savedAptMark
find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r dpkg-query --search | cut -d: -f1 | grep -v -e gdal -e geos -e perl -e python -e tcl | sort -u | xargs -r apt-mark manual
find /usr/local -type f -executable -exec ldd '{}' ';' | grep -v 'not found' | awk '/=>/ { print $(NF-1) }' | sort -u | xargs -r -i echo "/usr{}" | xargs -r dpkg-query --search | cut -d: -f1 | grep -v -e gdal -e geos -e perl -e python -e tcl | sort -u | xargs -r apt-mark manual
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
apt-get install -y --no-install-recommends \
    openssh-client \
;
rm -rf /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/cache/ldconfig
