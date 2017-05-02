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

safe_reload() {
  echo "[`date +'%Y-%m-%d %T'`] nginx safe reload"

  nginx -t &&
    service nginx reload # only runs if nginx -t succeeds
}

rm -f /etc/nginx/sites-enabled/server.conf

if [ -z "$SERVER_CONF" ] ; then
   cp /root/server.conf /etc/nginx/sites-enabled/server.conf
else
   curl -SL $SERVER_CONF --output /etc/nginx/sites-enabled/server.conf
fi

safe_reload();
