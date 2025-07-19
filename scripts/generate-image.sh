#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

mount_binfmt_misc() {
    print_info "Mounting binfmt_misc ..."
    print_warning "Enter the imagegen user's password (imagegen)!"

    if sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc;
    then
        print_success "binfmt_misc mounted successfully."
    else
        print_error "Failed to mount binfmt_misc."
        exit 1
    fi
}

build_image() {
    print_info "Starting UniClOGS Linux image build..."
    print_info "This process will take some time to complete..."

    config_dir="/home/imagegen/uniclogs"
    options_file="$config_dir/uniclogs.options"

    if ./build.sh -D "$config_dir" -c uniclogs -o "$options_file";
    then
        print_success "Image build completed successfully!"

        build_dir="/home/imagegen/build/"

        if cd "$build_dir";
        then
            cp -r ~/rpi-image-gen/work/rpi_uniclogs/deploy/* .
            print_success "Generated files copied to build directory."
            print_info "Build artifacts location: $build_dir"
            print_info ""
            print_info "Files generated:"
            ls -lah
        else
            print_warning "Could not create build directory. Files remain in:"
            print_info "/home/imagegen/rpi-image-gen/work/rpi_uniclogs/deploy"
        fi
    else
        print_error "Image build failed!"
        exit 1
    fi
}

main() {
    echo ""
    print_info "======================================"
    print_info "|    UniClOGS Linux Image Builder    |"
    print_info "======================================"
    echo ""

    # TODO: Only run this if host has non-ARM cpu architecture.
    mount_binfmt_misc
    build_image

    print_success "Image generation process completed!"
}

main "$@"
