FROM alpine:latest
MAINTAINER Strategies 360 <websupport@strategies360.com>

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm"

RUN addgroup -S mysql && adduser -S -G mysql mysql && apk -U upgrade && \
    apk --update add su-exec mariadb mariadb-client && \
    rm -rf /tmp/src && rm -rf /var/cache/apk/*

ADD ./root /

RUN chmod u+x /start.sh && chmod 777 /var/run

VOLUME ["/data"]
EXPOSE 3306

CMD ["/start.sh"]
