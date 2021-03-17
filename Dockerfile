FROM golang:1.16-alpine3.13 as builder

WORKDIR $GOPATH/src/wechat-go
COPY . .

RUN apk add --no-cache git && set -x && \
    go mod init && go get -d -v
#    go get  github.com/go-sql-driver/mysql && \
#    go get  github.com/devfeel/dotweb && \
#    go get  github.com/bitly/go-simplejson && \
#    go get  github.com/garyburd/redigo/redis && \
#    go get  github.com/enescakir/emoji 
RUN CGO_ENABLED=0 GOOS=linux go build -o ./mywechat mywechat-main.go
RUN CGO_ENABLED=0 GOOS=linux go build -o ./wechat-db wechat-db.go
RUN CGO_ENABLED=0 GOOS=linux go build -o ./wechat-index wechat-index.go


FROM alpine:latest

WORKDIR /
COPY --from=builder /go/src/wechat-go/mywechat . && COPY --from=builder /go/src/wechat-go/wechat-db . && COPY --from=builder /go/src/wechat-go/wechat-index .
ADD entrypoint.sh /entrypoint.sh
RUN  chmod +x /mywechat && chmod +x /wechat-index && chmod +x /wechat-db  && chmod 777 /entrypoint.sh
ENTRYPOINT  /entrypoint.sh 

EXPOSE 80
