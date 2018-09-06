FROM ubuntu:bionic

ENV SQUID_BASE_DIR=/squid3
ENV SQUID_VERSION=3.5.27 \
    SQUID_LOG_DIR=$SQUID_BASE_DIR/logs \
    SQUID_CONF_DIR=$SQUID_BASE_DIR/conf \
    SQUID_USER=proxy

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apache2-utils \
    squid=${SQUID_VERSION}* \
    sudo \
 && rm -rf /var/lib/apt/lists/*

COPY terraform/start-squid.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh && \
    mkdir -p $SQUID_LOG_DIR && \
    mkdir -p $SQUID_CONF_DIR && \
    chmod -R 755 $SQUID_LOG_DIR && \
    chown -R $SQUID_USER:$SQUID_USER $SQUID_BASE_DIR
COPY terraform/conf/squid.conf $SQUID_CONF_DIR/squid.conf

EXPOSE 3128/tcp
ENTRYPOINT ["/sbin/entrypoint.sh"]
