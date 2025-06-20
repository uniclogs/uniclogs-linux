FROM debian:bookworm AS base

# Install essential packages
RUN apt-get update && apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      ca-certificates \
      sudo \
      gpg \
      gpg-agent \
    && rm -rf /var/lib/apt/lists/*

# Get raspberry pi gpg key
RUN curl -fsSL https://archive.raspberrypi.com/debian/raspberrypi.gpg.key \
    | gpg --dearmor > /usr/share/keyrings/raspberrypi-archive-keyring.gpg

# Clone rpi-image-gen tool
# ARG RPIIG_GIT_SHA ba410bccd3f690a49cb8ec7a724cb59d08a4257e
ARG RPIIG_GIT_SHA 4492e0ffd45fa4f1aa73924b20270bb818b54286
RUN git clone --no-checkout https://github.com/raspberrypi/rpi-image-gen.git \
    && cd rpi-image-gen && git checkout ${RPIIG_GIT_SHA}

# TODO: Turn into a bash script that can handle multiple cpu architectures
RUN /bin/bash -c '\
  sed -i "s|\"\${binfmt_misc_required}\" == \"1\"|! -z \"\"|g" rpi-image-gen/scripts/dependencies_check && \
  if cat /proc/filesystems | grep -q binfmt_misc; then \
    echo \"binfmt_misc is supported\" ; \
  else \
    echo \"binfmt_misc is not supported. Install binfmt-support on your host machine\" ; \
    exit 1 ; \
  fi && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    qemu-user-static \
    dirmngr \
    slirp4netns \
    quilt \
    parted \
    debootstrap \
    zerofree \
    libcap2-bin \
    libarchive-tools \
    xxd \
    file \
    kmod \
    bc \
    pigz \
    arch-test && \
  rpi-image-gen/install_deps.sh \
'

ENV USER=imagegen
RUN useradd -u 4000 -ms /bin/bash "$USER" && echo "${USER}:${USER}" | chpasswd && adduser ${USER} sudo
USER ${USER}
WORKDIR /home/${USER}

RUN /bin/bash -c 'cp -r /rpi-image-gen ~/'


# ARG TARGETARCH
# RUN echo "Building for architecture: ${TARGETARCH}"
# # Example: Install different packages based on architecture
# RUN /bin/bash -c '\
#   case "${TARGETARCH}" in \
#     arm64) echo "Building for arm64" && \
#       apt-get update && \
#       rpi-image-gen/install_deps.sh ;; \
#     amd64) echo "Try to Build for amd64. \
#       As of Apr 2025 rpi-image-gen install_deps exits if arm arch is not detected. \
#       Override binfmt_misc_required flag and install known amd64 deps that are not \
#       provided in the depends file" && \
#       sed -i "s|\"\${binfmt_misc_required}\" == \"1\"|! -z \"\"|g" rpi-image-gen/scripts/dependencies_check && \
#       if cat /proc/filesystems | grep -q binfmt_misc; then \
#         echo \"binfmt_misc is supported\" ; \
#       else \
#         echo \"binfmt_misc is not supported. Install binfmt-support on your host machine\" ; \
#         exit 1 ; \
#       fi && \
#       apt-get update && \
#       apt-get install --no-install-recommends -y \
#         qemu-user-static \
#         dirmngr \
#         slirp4netns \
#         quilt \
#         parted \
#         debootstrap \
#         zerofree \
#         libcap2-bin \
#         libarchive-tools \
#         xxd \
#         file \
#         kmod \
#         bc \
#         pigz \
#         arch-test && \
#       rpi-image-gen/install_deps.sh ;; \
#     *) echo "Architecture $ARCH is not arm64 or amd64. Skipping package installation." ;; \
#   esac'
