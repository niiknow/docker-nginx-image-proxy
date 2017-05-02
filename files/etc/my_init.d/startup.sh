#!/bin/bash

export TERM=xterm

# save environment variables for use later
env > /root/env.txt

mkdir -p /etc/nginx/sites-enabled
mkdir -p /tmp/nginx/cache
chown -R www-data:nginx /tmp/nginx

service nginx start

bash /root/bin/my-startup.sh
