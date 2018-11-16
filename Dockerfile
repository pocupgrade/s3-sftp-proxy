FROM golang:1.11.2-alpine3.8 as builder

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

WORKDIR /go/src/github.com/moriyoshi/s3-sftp-proxy
COPY . .

RUN echo "Building" \
    && go build \
	&& echo

FROM alpine:3.8

RUN apk update && apk upgrade && \
    apk add --no-cache ca-certificates

COPY --from=builder /go/src/github.com/moriyoshi/s3-sftp-proxy/s3-sftp-proxy /

CMD ["./s3-sftp-proxy", "-debug"]
