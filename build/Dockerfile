FROM hyperknot/baseimage16:1.0.1

MAINTAINER friends@niiknow.org

ENV LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 \
    TERM=xterm container=docker DEBIAN_FRONTEND=noninteractive 

ADD ./src/ /tmp/

# start
RUN \
    cd /tmp \
    && bash ubuntu.sh

# docker run -it imageid /bin/bash
# ftp passive

VOLUME ["/backup"]

CMD ["/sbin/my_init"]
