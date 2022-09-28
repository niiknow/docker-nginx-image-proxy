#!/bin/bash
#
cd /etc/nginx
curl -sLo GeoLite2-ASN.mmdb https://git.io/GeoLite2-ASN.mmdb
curl -sLo GeoLite2-City.mmdb https://git.io/GeoLite2-City.mmdb
curl -sLo GeoLite2-Country.mmdb https://git.io/GeoLite2-Country.mmdb
