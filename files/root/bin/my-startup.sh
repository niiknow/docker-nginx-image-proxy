#!/bin/bash
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

   mv /etc/nginx/sites-enabled/server.conf /etc/nginx/sites-enabled/server.bak
   curl -SL $SERVER_CONF --output /etc/nginx/sites-enabled/server.conf
fi

 # only generate domain if not exists
if [ -n "$CERT_BUNDLE" ] ; then
   echo "$CERT_BUNDLE" > /etc/nginx/ssl/placeholder-fullchain.pem
   echo "$CERT_KEY" > /etc/nginx/ssl/placeholder-privkey.pem
   service nginx reload
fi

nginx -t || true
