#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


is_container_environment() {
    if [ ! -f "/home/imagegen/rpi-image-gen/build.sh" ];
    then
        print_info "Not running inside container. Launching container and running script ..."
        print_info "This will build the container if needed and run the image generation process."
        return 1
    else
        return 0
    fi
}

run_in_container() {
    if [ ! -f "compose.yml" ]; then
        print_error "compose.yml not found. Please run this script from the project root directory."
        exit 1
    fi

    exec podman compose run --remove-orphans --build rpi_imagegen bash -c "
        /home/imagegen/scripts/generate-image.sh
    "
}

check_binfmt_misc() {
    if mount | grep -q "binfmt_misc";
    then
        print_info "binfmt_misc is already mounted."
        return 0
    else
        return 1
    fi
}

mount_binfmt_misc() {
    print_info "Mounting binfmt_misc ..."
    print_info "You will be prompted for the imagegen user's password (imagegen)."

    if sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc; then
        print_success "binfmt_misc mounted successfully."
    else
        print_error "Failed to mount binfmt_misc."
        exit 1
    fi
}

build_image() {
    print_info "Starting UniClOGS Linux image build ..."
    print_info "This process will take some time to complete ..."

    if ./build.sh -D ~/uniclogs -c uniclogs -o ~/uniclogs/uniclogs.options;
    then
        mkdir ~/build/$(date +"%d%m%Y-%H%M%S") && cd $_
        cp -r ~/rpi-image-gen/work/rpi_uniclogs/deploy/* .
        print_success "Image build completed successfully!"
        print_info "Generated files can be found in the build/ directory."
    else
        print_error "Image build failed!"
        exit 1
    fi
}

main() {
    if ! is_container_environment;
    then
        run_in_container
        exit $?
    fi

    echo -e "\n"
    print_info "======================================"
    print_info "UniClOGS Linux Image Generation Script"
    print_info "======================================"
    echo -e "\n"

    if ! check_binfmt_misc; then
        mount_binfmt_misc
    fi

    build_image
}

main "$@"
