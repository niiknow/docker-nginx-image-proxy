FROM ubuntu:24.04 AS buildstep
ENV TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive \
    NGINX_DEVEL_KIT_VERSION=0.3.3 NGINX_SET_MISC_MODULE_VERSION=0.33 \
    NGINX_VERSION=1.26.2
ADD ./build/ /tmp/
RUN bash /tmp/ubuntu.sh


FROM ubuntu:24.04
LABEL maintainer="noogen <friends@niiknow.org>"
ENV TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=_1.26.2-1~noble_arm64.deb

COPY --from=buildstep /usr/src/nginx/nginx${NGINX_VERSION} /tmp

RUN cd /tmp \
    && echo "\n\n* soft nofile 800000\n* hard nofile 800000\n\n" >> /etc/security/limits.conf \
    && apt-get update -y && apt-get upgrade -y --no-install-recommends --no-install-suggests \
    && apt-get install -y --no-install-recommends --no-install-suggests curl gpg-agent nano \
       libgd3 gettext-base unzip rsync cron apt-transport-https software-properties-common \
       ca-certificates libmaxminddb0 libmaxminddb-dev mmdb-bin python3-pip git \
    && dpkg --configure -a \
    && touch /var/log/cron.log \
    && curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://nginx.org/packages/ubuntu/ noble nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/ubuntu/ noble nginx" | tee -a /etc/apt/sources.list \
    && apt-get update -y \
    && dpkg -i nginx${NGINX_VERSION} \
    && apt-get install --no-install-recommends --no-install-suggests -y nginx-module-njs gettext-base \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && mkdir -p /var/log/nginx /etc/nginx/ssl \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && service nginx stop && update-rc.d -f nginx disable \
    && pip3 install requests boto3 --break-system-packages \
    && apt-get clean -y && apt-get autoclean -y \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

ADD ./files/etc/ /etc/
ADD ./files/root/ /root/
ADD ./files/sbin/ /sbin/

RUN bash /root/bin/dummycert.sh \
    && mkdir -p /app-start/etc \
    && mv /etc/nginx /app-start/etc/nginx \
    && rm -rf /etc/nginx \
    && cd /app-start/etc/nginx/geolite2 \
    && bash geoip2-download.sh \
    && ln -s /app/etc/nginx /etc/nginx \
    && mkdir -p /app-start/var/log \
    && mv /var/log/nginx /app-start/var/log/nginx \
    && rm -rf /var/log/nginx \
    && ln -s /app/var/log/nginx /var/log/nginx

EXPOSE 80 443

VOLUME ["/app"]

CMD ["/sbin/my_init"]
