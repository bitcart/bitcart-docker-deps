# renovate: datasource=github-releases depName=cloudflare/cloudflared
ARG VERSION=2026.10.7

FROM --platform=$BUILDPLATFORM golang:1.27 AS builder

ARG TARGETARCH
ARG VERSION
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    CONTAINER_BUILD=1
WORKDIR /go/src/github.com/cloudflare/cloudflared/

RUN git clone --branch ${VERSION} --single-branch --depth 1 https://github.com/cloudflare/cloudflared.git .
RUN GOOS=linux GOARCH=${TARGETARCH} make cloudflared

FROM gcr.io/distroless/base-debian13:nonroot

LABEL org.opencontainers.image.source="https://github.com/cloudflare/cloudflared"

COPY --from=builder --chown=nonroot /go/src/github.com/cloudflare/cloudflared/cloudflared /usr/local/bin/

USER nonroot

ENTRYPOINT ["cloudflared", "--no-autoupdate"]
CMD ["version"]
