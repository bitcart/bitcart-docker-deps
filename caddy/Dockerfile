ARG VERSION=2.11.8
FROM caddy:${VERSION}-builder AS builder

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build \
    --with github.com/caddy-dns/namecheap \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/caddy-dns/desec \
    --with github.com/mholt/caddy-dynamicdns \
    --with github.com/mholt/caddy-l4 \
    --with github.com/WeidiDeng/caddy-cloudflare-ip \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/corazawaf/coraza-caddy/v2

FROM caddy:${VERSION}

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
