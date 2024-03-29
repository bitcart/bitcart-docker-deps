FROM python:3.8-bullseye as qemu
RUN apt-get update && apt-get install -qq --no-install-recommends qemu-user-static binfmt-support

FROM arm64v8/python:3.8-bullseye as builder
# Add env
ENV LANG C.UTF-8

COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin/qemu-aarch64-static
RUN apt-get update && apt-get install -qq --no-install-recommends unzip curl
RUN curl https://sh.rustup.rs -sSf > installrust.sh && \
    chmod +x installrust.sh && \
    sh installrust.sh -y

# Set the versions
ENV DOCKER_COMPOSE_VER 1.29.2
# docker-compose requires pyinstaller (check github.com/docker/compose/requirements-build.txt)
# If this changes, you may need to modify the version of "six" below
ENV PYINSTALLER_VER 4.1
# "six" is needed for PyInstaller.
ENV SIX_VER 1.15.0

# Install dependencies
# RUN apt-get update && apt-get install -y
RUN python3.8 -m pip install --upgrade pip
RUN python3.8 -m pip install six==$SIX_VER

# Compile the pyinstaller "bootloader"
# https://pyinstaller.readthedocs.io/en/stable/bootloader-building.html
WORKDIR /build/pyinstallerbootloader
RUN curl -fsSL https://github.com/pyinstaller/pyinstaller/releases/download/v$PYINSTALLER_VER/PyInstaller-$PYINSTALLER_VER.tar.gz | tar xvz >/dev/null \
    && cd pyinstaller-$PYINSTALLER_VER/bootloader \
    && python3.8 waf configure all && cd .. && python3.8 -m pip install .

# Clone docker-compose
WORKDIR /build/dockercompose
RUN curl -fsSL https://github.com/docker/compose/archive/$DOCKER_COMPOSE_VER.zip > $DOCKER_COMPOSE_VER.zip \
    && unzip $DOCKER_COMPOSE_VER.zip

ENV PATH="$PATH:/root/.cargo/bin"
RUN cd compose-$DOCKER_COMPOSE_VER \
    && echo "unknown" > compose/GITSHA \
    && python3.8 -m pip install -r requirements-indirect.txt \
    && python3.8 -m pip install -r requirements.txt \
    && pyinstaller docker-compose.spec \
    && mkdir /dist \
    && mv dist/docker-compose /dist/docker-compose

FROM arm64v8/debian:bullseye-slim

COPY --from=builder /dist/docker-compose /tmp/docker-compose

# Copy out the generated binary
VOLUME /dist
CMD /bin/cp /tmp/docker-compose /dist/docker-compose