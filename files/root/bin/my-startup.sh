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

if [ -z "$WHITELIST_HOSTS" ] ; then
# wildcard default
  WHITELIST_HOSTS=".*"
fi

rm -f /etc/nginx/sites-enabled/default.conf
cp /etc/nginx/sites-available/default.tpl /etc/nginx/sites-enabled/default.conf
sed -i "s/___MY_WHITELIST_HOSTS___/$WHITELIST_HOSTS/g" /etc/nginx/sites-enabled/default.conf
nginx -s reload
