FROM debian:stretch-slim

# Install exim4
ENV DEBIAN_FRONTEND noninteractive
RUN set -ex; \
    apt-get update; \
    apt-get install -y exim4-daemon-light; \
    apt-get clean

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
EXPOSE 25/tcp
ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "exim", "-bdf", "-v", "-q30m" ]
