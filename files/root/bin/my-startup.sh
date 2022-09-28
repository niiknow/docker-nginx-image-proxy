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

	# backup old config if exists
    if [ -f /app/etc/nginx/sites-enabled/server.conf ]; then
        mv /app/etc/nginx/sites-enabled/server.conf /app/etc/nginx/sites-enabled/server.bak
    fi
   
    log "Getting new server.conf"
    curl -SL $SERVER_CONF --output /app/etc/nginx/sites-enabled/server.conf
fi

echo "*** Running cron"
cron 

# now=$(date +"%T")
# echo "Current time : $now"

ls -la /root/bin

echo "*** Running nginx"
exec /usr/sbin/nginx -g "daemon off;"