# UniClOGS Linux

**UniClOGS Linux** is a project that extends the
[rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen)
tool to build images specifically for UniClOGS running on Raspberry Pi.

## 📖 Overview

This project contains a series of configs used to define the desired
customizations for a "golden" UniClOGS Ground System OS image, which
standardizes and simplifies the process of spinning up a UniClOGS Ground System.

It achieves this by leveraging the rpi-image-gen tool, which reads the config
files in this project to produce the exact image assets specified, along with a
software bill of materials (SBOM) file.

The configuration and scripts that provision the resulting image can be found in
the `uniclogs/` directory of this project, which is also made available for use
inside the container (where the image build process occurs).

## Getting Started

These instructions will walk you through the process of setting up this project
on a development system.

### Prerequisites
- [Podman](https://podman.io/docs/installation)
- [Podman Compose](https://github.com/containers/podman-compose)

**NOTE:** If you have a non-ARM CPU you will need
- [qemu-user-static (binfmt)](https://www.qemu.org/docs/master/about/emulation.html)

### Generating an Image

The preferred way to generate an image is to run the helper script found in the
root directory of this project. Upon successful generation, the image and sbom
assets will be found in the `build/` directory.

```sh
./generate.sh
```

**NOTE:** You will be prompted for the build user's password, which is
`imagegen`.

#### Manual Generation

To perform manual generation, you'll need access to the container directly. You
can get a shell inside the container by running the following command:

```sh
podman compose run rpi_imagegen bash
```

If running on a non-ARM host, from within the container, run the following
command to set binfmt_misc.

```sh
sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
```

Then build the image:

```sh
./build.sh -D ~/uniclogs -c uniclogs -o ~/uniclogs/uniclogs.options
```

This task will take a little time to complete.

#### Manually copying the Generated Image Files to Host

To copy the generated image and files from within the container onto the host
system, run:

```sh
podman ps
podman cp <containerid>:/home/imagegen/rpi-image-gen/work/rpi_uniclogs/deploy /path/to/destination
```

`podman ps` will show you the container id. Make sure to replace `<containerid>`
in the above command with the actual container id.

### Post-Generation Bootstrapping

The following steps are necessary to complete manually in order to get Uniclogs
Linux working.

1.  The root filesystem needs to be expanded to use the entire disk that the OS
    is installed on. In most commercially available linux distributions, this is
    done automatically during installation. To achieve this:

    1.  Run: `sudo raspi-config --expand-rootfs`
    2.  The system must be rebooted for this change to take effect.
    3.  After reboot, run `df -h` to confirm success.

2.  Set the FTDI Serial Number in `99-serial.rules` and `rotctld.service`, which
    can be found in /etc/udev/rules.d and `/etc/systemd/system` respectively.

    This can be done with the utility script `/home/uniclogs/bin/set-ftdi-sn.sh`

3.  Ensure that the chip and pin values inside `/etc/config/stationd.ini` are
    correct for your ground station hardware configuration.
