# Thanks to https://hub.docker.com/r/chriswayg/tor-alpine/dockerfile (Christian chriswayg@gmail.com)
# Dockerfile for Tor Relay Server with obfs4proxy (Multi-Stage build)

# renovate: datasource=gitlab-tags depName=tpo/core/tor registryUrl=https://gitlab.torproject.org versioning=regex:^(?<major>\d+)\.(?<minor>\d+)\.(?<patch>\d+)\.(?<build>\d+)(?:-(?<prerelease>.+))?$ extractVersion=^tor-(?<version>.+)$
ARG VERSION=0.4.9.17

FROM debian:trixie-slim AS tor-build
ARG TARGETARCH
ARG VERSION
ENV TOR_VERSION=${VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates perl autoconf automake build-essential git libtool python3 wget gnupg gpgv dirmngr git pkg-config

# See dependency versions on https://gitlab.torproject.org/tpo/applications/tor-browser-build/-/blob/main/projects
RUN wget -q https://github.com/madler/zlib/releases/download/v1.3.2/zlib-1.3.2.tar.gz \
&& TAR_NAME=zlib-1.3.2.tar.gz \
&& FOLDER_NAME=zlib-1.3.2 \
&& echo "bb329a0a2cd0274d05519d61c667c062e06990d72e125ee2dfa8de64f0119d16 $TAR_NAME" | sha256sum -c - \
&& tar xvf $TAR_NAME \
&& cd $FOLDER_NAME \
&& ./configure --static \
&& make -j"$(nproc)" \
&& make install && cd .. && rm $TAR_NAME && rm -rf $FOLDER_NAME

RUN wget -q https://github.com/openssl/openssl/releases/download/openssl-3.5.9/openssl-3.5.9.tar.gz \
&& TAR_NAME=openssl-3.5.9.tar.gz \
&& FOLDER_NAME=openssl-3.5.9 \
&& echo "603f5602e2eef00d77fbd429d34dcd5822bb301757a1bc9cdb24c670f1eb859a $TAR_NAME" | sha256sum -c - \
&& tar xvf $TAR_NAME \
&& cd $FOLDER_NAME \
&& ./Configure --libdir=lib no-shared no-dso no-zlib no-asm no-tests enable-ec_nistp_64_gcc_128 \
&& make -j"$(nproc)" \
&& make install_sw && cd .. && rm $TAR_NAME && rm -rf $FOLDER_NAME

RUN wget -q https://github.com/libevent/libevent/releases/download/release-2.1.13-stable/libevent-2.1.13-stable.tar.gz \
&& TAR_NAME=libevent-2.1.13-stable.tar.gz \
&& FOLDER_NAME=libevent-2.1.13-stable \
&& echo "f7e9383b8c0baa81b687e5b5eecc01beefaf1b19b64151d95ed61647fe7a315c $TAR_NAME" | sha256sum -c - \
&& tar xvf $TAR_NAME \
&& cd $FOLDER_NAME \
&& ./autogen.sh \
&& ./configure --disable-shared --with-pic --disable-samples --disable-libevent-regress \
&& make -j"$(nproc)" \
&& make install && cd .. && rm $TAR_NAME && rm -rf $FOLDER_NAME

# Release signers listed on https://support.torproject.org/little-t-tor/verify-little-t-tor/
COPY tor-signing-keys.asc /tmp/

# Install Tor from source, incl. GeoIP files (get latest release version number from Tor ReleaseNotes)
RUN TOR_TARBALL_NAME="tor-${TOR_VERSION}.tar.gz" \
      && TOR_TARBALL_LINK="https://dist.torproject.org/${TOR_TARBALL_NAME}" \
      && wget -q "$TOR_TARBALL_LINK" "$TOR_TARBALL_LINK.sha256sum" "$TOR_TARBALL_LINK.sha256sum.asc" \
      && gpg --dearmor -o /tmp/tor.keyring /tmp/tor-signing-keys.asc \
      && gpgv --keyring /tmp/tor.keyring "$TOR_TARBALL_NAME.sha256sum.asc" "$TOR_TARBALL_NAME.sha256sum" \
      && sha256sum -c "$TOR_TARBALL_NAME.sha256sum" \
      && tar xf $TOR_TARBALL_NAME \
      && cd tor-$TOR_VERSION \
      && ./configure \
      --disable-zstd --disable-lzma \
      --disable-systemd --disable-seccomp --disable-unittests --disable-tool-name-check \
      && make -j"$(nproc)" \
      && make install \
      && ls -R /usr/local/ \
      && strip /usr/local/bin/tor-* && strip /usr/local/bin/tor
      # Main files created (plus docs):
        # /usr/local/bin/tor
        # /usr/local/bin/tor-gencert
        # /usr/local/bin/tor-resolve
        # /usr/local/bin/torify
        # /usr/local/share/tor/geoip
        # /usr/local/share/tor/geoip6
        # /usr/local/etc/tor/torrc.sample

WORKDIR /tmp/bin
RUN case "${TARGETARCH}" in \
      amd64) GOSU_HASH=b1892636c281590f34bc63c1118f058cd9de66c4ea463772e3909672d8b302ac ;; \
      arm64) GOSU_HASH=c216cb762520edb5ab0acb21cb9bc4bcc5f1544d365e8952a21514f04ea233ee ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac \
    && wget -qO gosu "https://github.com/tianon/gosu/releases/download/1.20/gosu-${TARGETARCH}" \
    && echo "${GOSU_HASH}  gosu" | sha256sum -c -

FROM debian:trixie-slim

ARG VERSION
ENV TOR_VERSION=${VERSION}

# Copy Tor
COPY --from=tor-build "/tmp/bin" /usr/local/bin
COPY --from=tor-build /usr/local/ /usr/local/

ENV TOR_DATA=/home/tor/.tor

RUN chmod +x /usr/local/bin/gosu && groupadd -g 19001 tor && useradd -u 19001 -m -g tor tor && mkdir -p ${TOR_DATA} && chown -R tor:tor "$TOR_DATA"

VOLUME /home/tor/.tor
COPY docker-entrypoint.sh /entrypoint.sh

# SOCKS5, TOR control
EXPOSE 9050 9051
ENV TOR_CONFIG=/usr/local/etc/tor/torrc

ENTRYPOINT ["./entrypoint.sh"]
CMD ["tor"]
