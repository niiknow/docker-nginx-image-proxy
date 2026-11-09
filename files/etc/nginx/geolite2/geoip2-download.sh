#!/bin/bash
#
# Download GeoLite2 databases; fail the build if any download is bad.
set -euo pipefail

BASE_URL="https://github.com/P3TERX/GeoLite.mmdb/releases/latest/download"

for db in ASN City Country; do
    file="GeoLite2-${db}.mmdb"
    curl -fsSL --retry 5 --retry-delay 5 --retry-all-errors -o "$file" "$BASE_URL/$file"
    # make sure we got a real MaxMind DB, not an HTML error page
    mmdblookup --file "$file" --ip 8.8.8.8 >/dev/null
    echo "$file OK ($(stat -c %s "$file") bytes)"
done
