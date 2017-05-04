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

if [ -n "$SERVER_CONF" ] ; then
   mv /etc/nginx/sites-enabled/server.conf /etc/nginx/sites-enabled/server.bak
   curl -SL $SERVER_CONF --output /etc/nginx/sites-enabled/server.conf
fi

nginx -t && service nginx reload || exit 0
