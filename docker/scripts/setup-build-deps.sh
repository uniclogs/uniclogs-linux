#!/bin/bash

set -euo pipefail

echo "Setting up build dependencies for rpi-image-gen..."

# Detect architecture
ARCH=$(uname -m)
echo "Detected architecture: ${ARCH}"

case "${ARCH}" in
    aarch64|arm64)
        echo "Building for ARM64 architecture"
        echo "Using native ARM64 build process..."
        
        # Update package lists
        echo "Updating package lists..."
        apt-get update
        
        # Run the rpi-image-gen dependency installer (native ARM64)
        echo "Running rpi-image-gen install_deps.sh..."
        rpi-image-gen/install_deps.sh
        ;;
        
    x86_64|amd64)
        echo "Building for AMD64 architecture"
        echo "Setting up cross-compilation environment..."
        
        # Override binfmt_misc_required check in dependencies_check script
        # This allows the build to proceed on non-ARM architectures
        echo "Patching dependencies_check script..."
        sed -i 's|"${binfmt_misc_required}" == "1"|! -z ""|g' rpi-image-gen/scripts/dependencies_check

        # Check if binfmt_misc is supported
        echo "Checking binfmt_misc support..."
        if cat /proc/filesystems | grep -q binfmt_misc; then
            echo "✓ binfmt_misc is supported"
        else
            echo "✗ binfmt_misc is not supported. Install binfmt-support on your host machine"
            exit 1
        fi

        # Update package lists
        echo "Updating package lists..."
        apt-get update

        # Install required packages for cross-platform building
        echo "Installing build dependencies..."
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
            arch-test

        # Run the rpi-image-gen dependency installer
        echo "Running rpi-image-gen install_deps.sh..."
        rpi-image-gen/install_deps.sh
        ;;
        
    *)
        echo "Unsupported architecture: ${ARCH}"
        echo "Supported architectures: aarch64, arm64, x86_64, amd64"
        exit 1
        ;;
esac

echo "✓ Build dependencies setup complete"
