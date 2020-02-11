FROM alpine:3.11.3

RUN apk add --no-cache git docker-cli bash make

WORKDIR /code
