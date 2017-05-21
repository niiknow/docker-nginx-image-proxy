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
regex='^(https?):\/\/'

if [[ "$SERVER_CONF" =~ regex ]] ; then
   echo "[`date +'%Y-%m-%d %T'`] Getting new server conf"
   mv /etc/nginx/sites-enabled/server.conf /etc/nginx/sites-enabled/server.bak
   curl -SL $SERVER_CONF --output /etc/nginx/sites-enabled/server.conf
fi

if [[ "$GEODB_URL" =~ regex ]]  ; then
   echo "[`date +'%Y-%m-%d %T'`] Updating geo db"
   curl $GEODB_URL | gzip -d - > /etc/nginx/GeoLiteCity.dat
fi

nginx -t || true
