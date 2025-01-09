# https://github.com/adnanh/webhook
FROM        docker.io/golang:1.23.4-alpine3.21 AS base
ENV         WEBHOOK_VERSION 2.8.2
RUN         apk update

FROM        base as build
WORKDIR     /go/src/github.com/adnanh/webhook
RUN         apk add -t build-deps curl libc-dev gcc libgcc
RUN         curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
  tar -xzf webhook.tar.gz --strip 1
RUN         go get -d -v
RUN         CGO_ENABLED=0 go build -ldflags="-s -w" -o /usr/local/bin/webhook

FROM        docker.io/node:22.13.0-alpine3.21 as deploy
COPY        --from=build /usr/local/bin/webhook /usr/local/bin/webhook
RUN         apk add git
WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
LABEL       org.opencontainers.image.authors="mikael@lofjard.se"
