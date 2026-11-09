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

    log "Getting new server.conf from $SERVER_CONF"

    # download to a temp file first so a failed download never replaces a working config
    if ! curl -fsSL --retry 3 "$SERVER_CONF" --output /tmp/server.conf.new; then
        rm -f /tmp/server.conf.new
        die "ERROR: unable to download SERVER_CONF from '$SERVER_CONF' (not found or unreachable), aborting startup"
    fi

	# backup old config if exists
    if [ -f /app/etc/nginx/sites-enabled/server.conf ]; then
        mv /app/etc/nginx/sites-enabled/server.conf /app/etc/nginx/sites-enabled/server.bak
    fi

    mv /tmp/server.conf.new /app/etc/nginx/sites-enabled/server.conf
fi

# now=$(date +"%T")
# echo "Current time : $now"

ls -la /root/bin

echo "*** Running nginx"
exec /usr/sbin/nginx -g "daemon off;"