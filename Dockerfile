FROM golang:1.10.1-alpine3.7 as builder
COPY mywechat-main.go .
COPY wechat-db.go .
COPY wechat-index.go .
RUN set -x && \
    go get github.com/go-sql-driver/mysql && \
    go get github.com/devfeel/dotweb && \
    go get github.com/bitly/go-simplejson && \
    go get github.com/garyburd/redigo/redis && \
    go get github.com/enescakir/emoji && \
    dep ensure -v
RUN CGO_ENABLED=0 GOOS=linux go build -o /mywechat mywechat-main.go
RUN CGO_ENABLED=0 GOOS=linux go build -o /wechat-db wechat-db.go
RUN CGO_ENABLED=0 GOOS=linux go build -o /wechat-index wechat-index.go


FROM alpine:latest

WORKDIR /
COPY --from=builder /mywechat . && COPY --from=builder /wechat-db . && COPY --from=builder /wechat-index .
ADD entrypoint.sh /entrypoint.sh
RUN  chmod +x /mywechat && chmod +x /wechat-index && chmod +x /wechat-db  && chmod 777 /entrypoint.sh
ENTRYPOINT  /entrypoint.sh 

EXPOSE 80
