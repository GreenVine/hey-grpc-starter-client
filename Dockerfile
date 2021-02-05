ARG BUILDER_BASE_IMAGE=golang
ARG BUILDER_BASE_TAG=alpine
ARG RUNNER_BASE_IMAGE=alpine
ARG RUNNER_BASE_TAG=latest
ARG TARGET_OS=linux
ARG TARGET_ARCH=amd64
ARG ENABLE_TESTS=1
ARG ENABLE_UPX=0

### Builder ###
FROM ${BUILDER_BASE_IMAGE}:${BUILDER_BASE_TAG} AS builder
LABEL maintainer="Robin Liu <opensource@greenvine.dev>"
ARG RUNNER_BASE_IMAGE
ARG RUNNER_BASE_TAG
ARG TARGET_OS
ARG TARGET_ARCH
ARG ENABLE_TESTS
ARG ENABLE_UPX

ENV CGO_ENABLED=0
ENV GOOS=${TARGET_OS}
ENV GOARCH=${TARGET_ARCH}

RUN mkdir -p /home/app /home/build

WORKDIR /home/app
COPY . .

# Install dependencies and build binaries
RUN apk update \
    && apk --no-cache add ca-certificates \
    && if [ "${ENABLE_UPX}" = '1' ] || [ "${ENABLE_UPX}" = 'true' ]; then apk --no-cache add upx; fi \
    && rm -rf /var/cache/apk/* \
    && update-ca-certificates \
    && adduser \
           --disabled-password \
           --gecos "" \
           --no-create-home \
           --shell "/sbin/nologin" \
           --uid 10001 \
           apprunner

RUN go get -d \
    && go build -o /home/build/server -ldflags="-s -w" \
    && if [ "${ENABLE_TESTS}" = '1' ] || [ "${ENABLE_TESTS}" = 'true' ]; then go test -v ./... ; fi \
    && if [ "${ENABLE_UPX}" = '1' ] || [ "${ENABLE_UPX}" = 'true' ]; then upx --lzma -q /home/build/server; fi

### Runner ###
FROM ${RUNNER_BASE_IMAGE}:${RUNNER_BASE_TAG} AS runner

# Copy over essential system files
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/group /etc/

# Copy application binaries
COPY --from=builder --chown="10001:10001" /home/build/server /usr/bin/

# Run as unprivileged user
USER apprunner:apprunner

# Expose default port
EXPOSE 3000

# Run the main API server
ENTRYPOINT ["/usr/bin/server"]
