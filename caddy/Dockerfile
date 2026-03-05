ARG CADDY_VERSION=2.11.1
FROM caddy:${CADDY_VERSION}-builder AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
    --with github.com/caddy-dns/namecheap \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/mholt/caddy-dynamicdns \
    --with github.com/mholt/caddy-l4 \
    --with github.com/WeidiDeng/caddy-cloudflare-ip

FROM caddy:${CADDY_VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
