FROM hyperknot/baseimage16:1.0.2

MAINTAINER friends@niiknow.org

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
    TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive 

ADD ./src/ /tmp/

# start
RUN \
    cd /tmp \
    && bash ubuntu.sh

# docker run -it -v ./:/backup imageid /bin/bash
# copy image from inside to backup

VOLUME ["/backup"]

CMD ["/sbin/my_init"]
