FROM hyperknot/baseimage16:1.0.1

MAINTAINER friends@niiknow.org

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 TERM=xterm container=docker
ENV IMAGE_FILTER_URL=https://gist.githubusercontent.com/noogen/4a662ade2d9570f8996f3af9869c5216/raw/11077edb7fe189b918e3f2abb41d2e352cb7d936/ngx_http_image_filter_module.c
ENV NGINX_VERSION=1.13.0
ENV NGINX_DIR=/tmp/nginx
ENV NGINX_URL=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

# start
RUN \
    apt-get -o Acquire::GzipIndexes=false update \
    && apt-get update && apt-get -y upgrade \
    && apt-get -y install wget curl unzip nano vim rsync tar git apt-transport-https openssh-client openssh-server \
       apt-utils software-properties-common build-essential tcl openssl dnsmasq ca-certificates libssl-dev \
       zlib1g-dev dpkg-dev cpp libpcre3 libpcre3-dev libgd-dev \

    && dpkg --configure -a \

# re-enable all default services
    && rm -f /etc/service/syslog-forwarder/down \
    && rm -f /etc/service/cron/down \
    && rm -f /etc/service/syslog-ng/down \
    && rm -f /core

RUN \
    cd /tmp \
    && wget -O - http://nginx.org/keys/nginx_signing.key | apt-key add - \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && apt-get update -y && apt-get install nginx -y

# prepare for installation
RUN \
    apt-get update -y \
    && mkdir -p ${NGINX_DIR} \
    && cd ${NGINX_DIR}; apt-get source nginx -y \
    && mv ${NGINX_DIR}/nginx-${NGINX_VERSION}/src/http/modules/ngx_http_image_filter_module.c ${NGINX_DIR}/nginx-${NGINX_VERSION}/src/http/modules/ngx_http_image_filter_module.bak \
    && curl -SL $IMAGE_FILTER_URL --output ${NGINX_DIR}/nginx-${NGINX_VERSION}/src/http/modules/ngx_http_image_filter_module.c \
    && sed -i "s/--with-http_ssl_module/--with-http_ssl_module --with-http_image_filter_module/g" ${NGINX_DIR}/nginx-${NGINX_VERSION}/debian/rules \
    && cd ${NGINX_DIR}; apt-get build-dep nginx -y \
    && cd ${NGINX_DIR}/nginx-${NGINX_VERSION}; dpkg-buildpackage -b \
    && apt-get remove -y nginx nginx-common nginx-full \
    && cd ${NGINX_DIR}; dpkg -i nginx_${NGINX_VERSION}-1~xenial_amd64.deb

ADD ./files /

# cleanup
RUN \
    service nginx stop \
    && mv /etc/nginx/nginx.conf /etc/nginx/nginx.old \
    && mv /etc/nginx/nginx.new /etc/nginx/nginx.conf \
    && mkdir -p /etc/nginx/sites-enabled \
    && rm -rf /tmp/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=teletype

VOLUME ["/etc/nginx/", "/var/log/nginx"]

EXPOSE 80

CMD ["/sbin/my_init"]

