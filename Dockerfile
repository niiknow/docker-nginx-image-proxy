FROM hyperknot/baseimage16:1.0.6 AS buildstep
ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
    TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive \
    NGINX_DEVEL_KIT_VERSION=0.3.0 NGINX_SET_MISC_MODULE_VERSION=0.31 \
    NGINX_VERSION=1.14.2
ADD ./build/src/ /tmp/
RUN bash /tmp/ubuntu.sh


FROM hyperknot/baseimage16:1.0.6

MAINTAINER friends@niiknow.org

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
    TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive \
    NGINX_VERSION=_1.14.2-1~xenial_amd64.deb \
    NGINX_DEBUG=-dbg${NGINX_VERSION}

COPY --from=buildstep /usr/src/nginx/nginx${NGINX_VERSION} /tmp

RUN cd /tmp \
    && echo "\n\n* soft nofile 800000\n* hard nofile 800000\n\n" >> /etc/security/limits.conf \
    && curl -s https://nginx.org/keys/nginx_signing.key | apt-key add - \
    && cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" | tee -a /etc/apt/sources.list \
    && apt-get update -y && apt-get upgrade -y --no-install-recommends --no-install-suggests \
    && apt-get install -y --no-install-recommends --no-install-suggests \
       nano libgd3 gettext-base unzip rsync \
    && dpkg --configure -a \
    && dpkg -i nginx${NGINX_VERSION} \
    && rm -rf /etc/nginx/conf.d/default.conf \
    && rm -f /etc/service/syslog-forwarder/down \
    && rm -f /etc/service/cron/down \
    && rm -f /etc/service/syslog-ng/down \
    && rm -f /core \
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
