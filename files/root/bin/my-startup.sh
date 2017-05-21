#!/bin/bash -e
function die {
   echo >&2 "$@"
   exit 1
}

#######################################
# Echo/log function
# Arguments:
#   String: value to log
#######################################
log() {
   if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
   else echo; fi
}

if [ -n "$SERVER_CONF" ] ; then
   echo "[`date +'%Y-%m-%d %T'`] Getting new server conf"
   mv /etc/nginx/sites-enabled/server.conf /etc/nginx/sites-enabled/server.bak
   curl -SL $SERVER_CONF --output /etc/nginx/sites-enabled/server.conf
fi

if [ -n "$GEODB_URL" ] ; then
   echo "[`date +'%Y-%m-%d %T'`] Updating geo db"
   curl $GEODB_URL | gzip -d - > /etc/nginx/GeoLiteCity.dat
fi

nginx -t || true
