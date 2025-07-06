FROM debian:bookworm

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        curl \
        sudo

ARG RPIIG_GIT_SHA=4492e0ffd45fa4f1aa73924b20270bb818b54286
RUN curl -L -o rpi-image-gen.tar.gz https://github.com/raspberrypi/rpi-image-gen/archive/${RPIIG_GIT_SHA}.tar.gz \
    && tar -xzf rpi-image-gen.tar.gz \
    && mv rpi-image-gen-${RPIIG_GIT_SHA} /rpi-image-gen \
    && rm rpi-image-gen.tar.gz

RUN arch=$(uname -m); \
    if [ "$arch" != "aarch64" ] || [ "$arch" != "arm64" ]; then \
        apt-get install --no-install-recommends -y qemu-user-static; \
        # install_deps.sh will exit before installing the required dependencies
        # if binfmt_misc is needed but not set, so execute 'true' to proceed.
        /rpi-image-gen/install_deps.sh || true; \
    else \
        /rpi-image-gen/install_deps.sh; \
    fi

ENV USER=imagegen
RUN useradd -u 4000 -ms /bin/bash "$USER" \
    && echo "${USER}:${USER}" | chpasswd \
    && adduser ${USER} sudo
USER ${USER}
WORKDIR /home/${USER}

RUN /bin/bash -c 'cp -r /rpi-image-gen ~/'
WORKDIR /home/${USER}/rpi-image-gen
