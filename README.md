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


> [!NOTE]
> If you are looking for SatNOGS configs they are in the `satnogs` folder
> See our SatNOGS documentation [here](satnogs/README.md)


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
podman compose run --build rpi_imagegen bash
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
