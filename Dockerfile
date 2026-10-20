FROM golang:1.27.3-alpine

RUN apk update && \
    apk upgrade && \
    apk add build-base && \
    apk add git rsync bash && \
    git clone https://github.com/cli/cli.git -b v2.102.1 gh-cli && \
    cd gh-cli && \
    make && \
    mv ./bin/gh /usr/local/bin/

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
