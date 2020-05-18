#!/bin/bash

export NGINX_BUILD_DIR=/usr/src/nginx/nginx-${NGINX_VERSION}
cd /tmp

apt-get update
apt-get install -y --no-install-recommends --no-install-suggests curl apt-transport-https \
        apt-utils software-properties-common build-essential ca-certificates libssl-dev \
        zlib1g-dev dpkg-dev libpcre3 libpcre3-dev libgd-dev gpg-agent

dpkg --configure -a

curl -sL "https://github.com/simplresty/ngx_devel_kit/archive/v$NGINX_DEVEL_KIT_VERSION.tar.gz" -o dev-kit.tar.gz
mkdir -p /usr/src/nginx/ngx_devel_kit
tar -xof dev-kit.tar.gz -C /usr/src/nginx/ngx_devel_kit --strip-components=1
rm dev-kit.tar.gz

curl -sL "https://github.com/openresty/set-misc-nginx-module/archive/v$NGINX_SET_MISC_MODULE_VERSION.tar.gz" -o ngx-misc.tar.gz
mkdir -p /usr/src/nginx/set-misc-nginx-module
tar -xof ngx-misc.tar.gz -C /usr/src/nginx/set-misc-nginx-module --strip-components=1
rm ngx-misc.tar.gz

curl -s https://nginx.org/keys/nginx_signing.key | apt-key add -
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo "deb http://nginx.org/packages/ubuntu/ focal nginx" | tee -a /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/ubuntu/ focal nginx" | tee -a /etc/apt/sources.list

apt-get update && apt-get upgrade -y --no-install-recommends --no-install-suggests

mkdir -p /usr/src/nginx

cd /usr/src/nginx
apt-get source nginx=${NGINX_VERSION} -y

pwd
ls -la

cd ${NGINX_BUILD_DIR}
patch src/http/modules/ngx_http_image_filter_module.c /tmp/image_filter.patch

sed -i "s/--with-http_ssl_module/--with-http_ssl_module --with-http_image_filter_module --add-module=\/usr\/src\/nginx\/ngx_devel_kit --add-module=\/usr\/src\/nginx\/set-misc-nginx-module /g" \
    ${NGINX_BUILD_DIR}/debian/rules

cd /usr/src/nginx
apt-get build-dep nginx -y
cd ${NGINX_BUILD_DIR}
dpkg-buildpackage -uc -us -b

cd /usr/src/nginx
pwd
ls -la
