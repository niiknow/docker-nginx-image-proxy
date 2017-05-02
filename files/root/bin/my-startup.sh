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
log() {
  if [[ "$@" ]]; then echo "[`date +'%Y-%m-%d %T'`] $@";
  else echo; fi
}

rm -f /etc/nginx/sites-enabled/server.conf

if [ -z "$SERVER_CONF" ] ; then
   cp /root/server.conf /etc/nginx/sites-enabled/server.conf
else
   curl -SL $SERVER_CONF --output /etc/nginx/sites-enabled/server.conf
fi

nginx -s reload
