FROM golang:1.16-alpine3.13

RUN apk update && \
    apk upgrade && \
    apk add build-base && \
    apk add git && \
    git clone https://github.com/cli/cli.git -b v2.14.3 gh-cli && \
    cd gh-cli && \
    make && \
    mv ./bin/gh /usr/local/bin/

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
