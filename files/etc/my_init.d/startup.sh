#!/bin/bash

export TERM=xterm

# save environment variables for use later
env > /root/env.txt

mkdir -p /etc/nginx/sites-enabled
mkdir -p /tmp/nginx/cache
chown -R www-data:nginx /tmp/nginx

if [ -f /etc/nginx/nginx.new ]; then
  mv /etc/nginx/nginx.conf /etc/nginx/nginx.old
  mv /etc/nginx/nginx.new /etc/nginx/nginx.conf
fi

service nginx start

bash /root/bin/my-startup.sh
