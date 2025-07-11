#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_info "Checking prerequisites ..."

    if [ ! -f "compose.yml" ]; then
        print_error "compose.yml not found. Please run this script from the project root directory."
        exit 1
    fi
}

run_container_build() {
    print_info "Starting container and launching image build process ..."
    print_info "This will build the container if needed and run the image generation process."
    echo ""

    exec podman compose run --remove-orphans --build rpi_imagegen bash -c "
        /home/imagegen/scripts/generate-image.sh
    "
}

main() {
    check_prerequisites
    run_container_build
}

main "$@"
