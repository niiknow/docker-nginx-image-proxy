#!/bin/bash

export NGINX_VERSION=1.13.1
export IMAGE_FILTER_URL=https://gist.githubusercontent.com/noogen/4a662ade2d9570f8996f3af9869c5216/raw/54ff0a221a069a3c2574b0404afb71552fd4066d/ngx_http_image_filter_module.c
export NGINX_BUILD_DIR=/usr/src/nginx/nginx-${NGINX_VERSION}

cd /tmp
curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - 
cp /etc/apt/sources.list /etc/apt/sources.list.bak 
echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list 
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list 

apt-get update && apt-get upgrade -y --no-install-recommends --no-install-suggests 
apt-get install -y --no-install-recommends --no-install-suggests curl unzip nano vim apt-transport-https \
        apt-utils software-properties-common build-essential ca-certificates libssl-dev \
        zlib1g-dev dpkg-dev libpcre3 libpcre3-dev libgd-dev ftp 

dpkg --configure -a 

mkdir -p /usr/src/nginx 

cd /usr/src/nginx
apt-get source nginx=${NGINX_VERSION} -y 
mv ${NGINX_BUILD_DIR}/src/http/modules/ngx_http_image_filter_module.c ${NGINX_BUILD_DIR}/src/http/modules/ngx_http_image_filter_module.bak 

curl -SL $IMAGE_FILTER_URL --output ${NGINX_BUILD_DIR}/src/http/modules/ngx_http_image_filter_module.c 
sed -i "s/--with-http_ssl_module/--with-http_ssl_module --with-http_image_filter_module/g" ${NGINX_BUILD_DIR}/debian/rules 

cd /usr/src/nginx
apt-get build-dep nginx -y
cd ${NGINX_BUILD_DIR}
dpkg-buildpackage -uc -us -b
