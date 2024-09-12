FROM ubuntu:22.04

# Labels
LABEL org.opencontainers.image.authors="konstantosjim@gmail.com"
LABEL org.opencontainers.image.url="https://github.com/vbrawl/easykivy"
LABEL org.opencontainers.image.title="EasyKivy"
LABEL org.opencontainers.image.description="Container for easy compilation of kivy apps for android"

# Prepare environment
SHELL ["/usr/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Disable Auto-Upgrades, then Update and Install dependencies
RUN set -x \
    && apt-get update \
    && apt-get full-upgrade -y \
    && apt-get autoremove \
    && apt-get install -y \
        build-essential autoconf gdb lcov pkg-config libtool \
        zip unzip curl sudo aidl \
    && apt-get install -y \
        python3 python3-pip python3-venv \
        libffi-dev libgdbm-dev libgdbm-compat-dev \
        lzma lzma-dev liblzma-dev libbz2-dev \
        libreadline6-dev libsqlite3-dev \
        libssl-dev tk-dev uuid-dev zlib1g-dev \
    && apt-get install -y --no-install-recommends \
        git openjdk-17-jdk \
    && apt-get autoremove

ADD build.sh /project/build.sh

# Setup builder user
RUN set -x \
    && useradd -s /usr/bin/bash -U -m builder \
    && echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers \
    && chown -R builder:builder /project/

# Change user and CWD
USER builder
VOLUME /project
WORKDIR /project


# Install buildozer and some of it's dependencies
RUN set -x \
    && python3 -m venv .venv \
    && source .venv/bin/activate \
    && python3 -m pip install --upgrade pip \
    && python3 -m pip install cython buildozer python-for-android pyOpenssl

ENTRYPOINT ["/project/build.sh"]
