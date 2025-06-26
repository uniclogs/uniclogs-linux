FROM debian:bookworm AS base

# Install essential packages
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        build-essential \
        ca-certificates \
        curl \
        git \
        gpg \
        gpg-agent \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Get raspberry pi gpg key
RUN curl -fsSL https://archive.raspberrypi.com/debian/raspberrypi.gpg.key \
    | gpg --dearmor > /usr/share/keyrings/raspberrypi-archive-keyring.gpg

# Clone rpi-image-gen tool
ARG RPIIG_GIT_SHA 4492e0ffd45fa4f1aa73924b20270bb818b54286
RUN git clone --no-checkout https://github.com/raspberrypi/rpi-image-gen.git \
    && cd rpi-image-gen && git checkout ${RPIIG_GIT_SHA}

# Copy setup script, make it executable, and run
COPY docker/scripts/setup-build-deps.sh /tmp/setup-build-deps.sh
RUN chmod +x /tmp/setup-build-deps.sh
RUN /tmp/setup-build-deps.sh

# Create user
ENV USER=imagegen
RUN useradd -u 4000 -ms /bin/bash "$USER" \
    && echo "${USER}:${USER}" | chpasswd \
    && adduser ${USER} sudo
USER ${USER}
WORKDIR /home/${USER}

# Copy rpi-image-gen tool into the user home directory and set it as working
# directory.
RUN /bin/bash -c 'cp -r /rpi-image-gen ~/'
WORKDIR /home/${USER}/rpi-image-gen
