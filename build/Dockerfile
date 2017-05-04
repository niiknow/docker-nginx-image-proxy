FROM hyperknot/baseimage16:1.0.1

MAINTAINER friends@niiknow.org

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive NGINX_VERSION=1.13.0 NGINX_BUILD_DIR=/tmp/nginx 
ENV IMAGE_FILTER_URL=https://raw.githubusercontent.com/niiknow/docker-nginx-image-proxy/master/build/src/ngx_http_image_filter_module.c

# start
RUN \
    apt-get update && apt-get upgrade -y --force-yes --no-install-recommends \
    && apt-get install -y --force-yes --no-install-recommends wget curl unzip nano vim apt-transport-https \
       apt-utils software-properties-common build-essential ca-certificates libssl-dev \
       zlib1g-dev dpkg-dev libpcre3 libpcre3-dev libgd-dev \

    && dpkg --configure -a \

# re-enable all default services
    && rm -f /etc/service/syslog-forwarder/down \
    && rm -f /etc/service/cron/down \
    && rm -f /etc/service/syslog-ng/down \
    && rm -f /core \
    && wget -O - http://nginx.org/keys/nginx_signing.key | apt-key add - \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && apt-get update \

# recompile nginx
    && mkdir -p ${NGINX_BUILD_DIR} \

# get the source
    && cd ${NGINX_BUILD_DIR}; apt-get source nginx -y \
    && mv ${NGINX_BUILD_DIR}/nginx-${NGINX_VERSION}/src/http/modules/ngx_http_image_filter_module.c ${NGINX_BUILD_DIR}/nginx-${NGINX_VERSION}/src/http/modules/ngx_http_image_filter_module.bak \

# apply patch
    && curl -SL $IMAGE_FILTER_URL --output ${NGINX_BUILD_DIR}/nginx-${NGINX_VERSION}/src/http/modules/ngx_http_image_filter_module.c \
    && sed -i "s/--with-http_ssl_module/--with-http_ssl_module --with-http_image_filter_module=dynamic/g" ${NGINX_BUILD_DIR}/nginx-${NGINX_VERSION}/debian/rules \

# get build dependencies
    && cd ${NGINX_BUILD_DIR}; apt-get build-dep nginx -y \
    && cd ${NGINX_BUILD_DIR}/nginx-${NGINX_VERSION}; dpkg-buildpackage -b \

# install new nginx package
    && cd ${NGINX_BUILD_DIR}; dpkg -i nginx_${NGINX_VERSION}-1~xenial_amd64.deb

ADD ./files /

EXPOSE 80

CMD ["/sbin/my_init"]
