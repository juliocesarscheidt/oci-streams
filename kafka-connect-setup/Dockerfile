FROM alpine:3.10

RUN apk update && \
    apk add curl jq --no-cache

COPY docker-entrypoint.sh /opt/docker-entrypoint.sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
