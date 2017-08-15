#!/bin/bash

export NGINX_VERSION=1.13.4
export NGINX_BUILD_DIR=/usr/src/nginx/nginx-${NGINX_VERSION}
export NGINX_DEVEL_KIT_VERSION=0.3.0
export NGINX_SET_MISC_MODULE_VERSION=0.31
cd /tmp

curl -sL "https://github.com/simpl/ngx_devel_kit/archive/v$NGINX_DEVEL_KIT_VERSION.tar.gz" -o dev-kit.tar.gz
mkdir -p /usr/src/nginx/ngx_devel_kit 
tar -xof dev-kit.tar.gz -C /usr/src/nginx/ngx_devel_kit --strip-components=1
rm dev-kit.tar.gz

curl -sL "https://github.com/openresty/set-misc-nginx-module/archive/v$NGINX_SET_MISC_MODULE_VERSION.tar.gz" -o ngx-misc.tar.gz
mkdir -p /usr/src/nginx/set-misc-nginx-module
tar -xof ngx-misc.tar.gz -C /usr/src/nginx/set-misc-nginx-module --strip-components=1
rm ngx-misc.tar.gz

curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - 
cp /etc/apt/sources.list /etc/apt/sources.list.bak 
echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list 
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list 

apt-get update && apt-get upgrade -y --no-install-recommends --no-install-suggests 
apt-get install -y --no-install-recommends --no-install-suggests curl unzip apt-transport-https \
        apt-utils software-properties-common build-essential ca-certificates libssl-dev \
        zlib1g-dev dpkg-dev libpcre3 libpcre3-dev libgd-dev 

dpkg --configure -a 

mkdir -p /usr/src/nginx 

cd /usr/src/nginx
apt-get source nginx=${NGINX_VERSION} -y 

cd ${NGINX_BUILD_DIR}/src/http/modules/
mv ngx_http_image_filter_module.c ngx_http_image_filter_module.bak 
mv /tmp/ngx_http_image_filter_module.c ./ngx_http_image_filter_module.c 

sed -i "s/--with-http_ssl_module/--with-http_ssl_module --with-http_image_filter_module --add-module=\/usr\/src\/nginx\/ngx_devel_kit --add-module=\/usr\/src\/nginx\/set-misc-nginx-module /g" \
    ${NGINX_BUILD_DIR}/debian/rules 

cd /usr/src/nginx
apt-get build-dep nginx -y
cd ${NGINX_BUILD_DIR}
dpkg-buildpackage -uc -us -b

