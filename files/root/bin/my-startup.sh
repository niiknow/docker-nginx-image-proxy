#!/bin/bash
set -e

function die {
   echo >&2 "$@"
   exit 1
}

#######################################
# Echo/log function
# Arguments:
#   String: value to log
#######################################
function log {
   if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
   else echo; fi
}

if [ -n "$SERVER_CONF" ] ; then
   log "Getting new server.conf"

   mv /app/etc/nginx/sites-enabled/server.conf /app/etc/nginx/sites-enabled/server.bak
   curl -SL $SERVER_CONF --output /app/etc/nginx/sites-enabled/server.conf

   service nginx reload
fi

echo "*** Running cron"
cron 

echo "*** Running nginx"
exec /usr/sbin/nginx -g "daemon off;"