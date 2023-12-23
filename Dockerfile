# Module Cached image
FROM --platform=$BUILDPLATFORM docker-upgrade.artifactory.build.upgrade.com/go-builder:2.0.20231218.0-62.1.21.5-82 AS build_base

WORKDIR /go/src/github.com/moriyoshi/s3-sftp-proxy

COPY --chown=upgrade:upgrade . .

RUN go mod download

RUN echo "Testing" \
    && go test ./...  -short \
    && echo


#Disabling linter since this project is a fork
#RUN echo "Inspecting code" \
#    && GOGC=10 golangci-lint run ./... \
#         --timeout 5m \
#    && echo

FROM docker-upgrade.artifactory.build.upgrade.com/go-builder:2.0.20231218.0-62.1.21.5-82 AS build

WORKDIR /go/src/github.com/moriyoshi/s3-sftp-proxy

# Copy go mod download from base layer into each cross arch build
COPY --from=build_base --chown=upgrade /go/pkg/mod/cache /go/pkg/mod/cache

ENV CGO_ENABLED=1

COPY --chown=upgrade:upgrade . .

RUN echo "Building" \
    && go install \
    && echo

# Definitive image
FROM docker-upgrade.artifactory.build.upgrade.com/container-base:2.0.20231218.0-63

WORKDIR /

COPY --from=build /go/bin/s3-sftp-proxy  /usr/bin/s3-sftp-proxy

CMD ["/usr/bin/s3-sftp-proxy", "-debug"]
