FROM debian:bookworm AS base

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        git \
        sudo \
    && rm -rf /var/lib/apt/lists/*

ARG RPIIG_GIT_SHA 4492e0ffd45fa4f1aa73924b20270bb818b54286
RUN git clone --no-checkout https://github.com/raspberrypi/rpi-image-gen.git \
    && cd rpi-image-gen && git checkout ${RPIIG_GIT_SHA}

COPY docker/scripts/setup-build-deps.sh /tmp/setup-build-deps.sh
RUN chmod +x /tmp/setup-build-deps.sh
RUN /tmp/setup-build-deps.sh

ENV USER=imagegen
RUN useradd -u 4000 -ms /bin/bash "$USER" \
    && echo "${USER}:${USER}" | chpasswd \
    && adduser ${USER} sudo
USER ${USER}
WORKDIR /home/${USER}

RUN /bin/bash -c 'cp -r /rpi-image-gen ~/'
WORKDIR /home/${USER}/rpi-image-gen
