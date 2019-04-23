FROM ubuntu:18.04 AS buildstep
ENV TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive \
    NGINX_DEVEL_KIT_VERSION=0.3.0 NGINX_SET_MISC_MODULE_VERSION=0.32 \
    NGINX_VERSION=1.16.0
ADD ./build/src/ /tmp/
RUN bash /tmp/ubuntu.sh


FROM ubuntu:18.04
LABEL maintainer="noogen <friends@niiknow.org>"
ENV TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=_1.16.0-1~bionic_amd64.deb \
    NGINX_DEBUG=-dbg${NGINX_VERSION}

COPY --from=buildstep /usr/src/nginx/nginx${NGINX_VERSION} /tmp

RUN cd /tmp \
    && echo "\n\n* soft nofile 800000\n* hard nofile 800000\n\n" >> /etc/security/limits.conf \
    && apt-get update -y && apt-get upgrade -y --no-install-recommends --no-install-suggests \
    && apt-get install -y --no-install-recommends --no-install-suggests \
       curl gpg-agent nano libgd3 gettext-base unzip rsync cron \
       apt-transport-https software-properties-common \
       ca-certificates \
    && dpkg --configure -a \
    && touch /var/log/cron.log \
    && curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://nginx.org/packages/ubuntu/ bionic nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/ubuntu/ bionic nginx" | tee -a /etc/apt/sources.list \
    && apt-get update -y \
    && dpkg -i nginx${NGINX_VERSION} \
    && apt-get install --no-install-recommends --no-install-suggests -y nginx-module-njs gettext-base \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && mkdir -p /var/log/nginx \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && service nginx stop && update-rc.d -f nginx disable \
    && apt-get clean -y && apt-get autoclean -y \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

ADD ./files /

RUN bash /root/bin/placeholder-ssl.sh \
    && mkdir -p /app-start/etc \
    && mv /etc/nginx /app-start/etc/nginx \
    && rm -rf /etc/nginx \
    && ln -s /app/etc/nginx /etc/nginx \
    && mkdir -p /app-start/var/log \
    && mv /var/log/nginx /app-start/var/log/nginx \
    && rm -rf /var/log/nginx \
    && ln -s /app/var/log/nginx /var/log/nginx

EXPOSE 80 443

VOLUME ["/app"]

CMD ["/sbin/my_init"]
