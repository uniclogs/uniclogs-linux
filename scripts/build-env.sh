#!/bin/bash

set -e

BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

main() {
    print_info "Starting container and launching image build process ..."
    print_info "This will build the container if needed and run the image generation process."
    echo ""

    SCRIPT_DIR="$(dirname "$0")"
    PROJECT_ROOT="$SCRIPT_DIR/.."

    cd "$PROJECT_ROOT"
    exec podman compose run --build rpi_imagegen bash -c "
        /home/imagegen/scripts/generate-image.sh
    "
}

main "$@"
