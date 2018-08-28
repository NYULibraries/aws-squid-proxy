FROM ubuntu:bionic

ENV SQUID_VERSION=3.5.27 \
    SQUID_CACHE_DIR=/var/spool/squid \
    SQUID_LOG_DIR=/var/log/squid \
    SQUID_PASS_DIR=/etc/squid/users \
    SQUID_USER=proxy

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2-utils \
    squid=${SQUID_VERSION}* \
 && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh \
 && mv /etc/squid/squid.conf /etc/squid/squid.conf.dist \
 && mkdir /etc/squid/users \
 && chown -R $SQUID_USER:$SQUID_USER /etc/squid/users \
 && chmod -R 750 /etc/squid/users
COPY squid.conf /etc/squid/squid.conf

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
