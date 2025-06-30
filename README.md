# UniClOGS Linux

**UniClOGS Linux** is a project that extends the
[rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen)
tool to build images specifically for UniClOGS running on Raspberry Pi.

## 📖 Overview

We needed a way to reproducibly build custom operating system images for the
UniClOGS Ground System(s) that run on the Raspberry Pi, which uses an ARM
processor architecture. This is a straightforward task, made even easier, by the
[rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen)
cli tool, which allows developers to create a custom linux image through configs
and scripts.

However, this task gets trickier when trying to build a linux image designed to
run on ARM if the host (computer you run this project on), uses a different CPU
architecture, like x64. The need for emulation software and cross-compilation
arises.

To mitigate most of that problem, this project uses
[Docker](https://www.docker.com/), which spins up a container on the host
system with an environment designed for either ARM or x64 CPUs.

Inside the container, the
[rpi-image-gen](https://github.com/raspberrypi/rpi-image-gen)
cli tool is pulled down from github. This tool is what does the heavy lifting.

The configuration and scripts that provision the resulting image can be found in
the `uniclogs/` directory of this project, which is also made available for use
inside the Docker container. After running the build script inside the container
and copying the resulting files (sbom and the image itself) out of the
container, the image is then ready to be written to a disk and inserted into the
Raspberry Pi.

## Getting Started

These instructions will walk you through the process of setting up this project
on a development system.

### Prerequisites

- [Docker](https://docs.docker.com/desktop/)
- [Docker Compose](https://docs.docker.com/compose/)
  - (This ships with Docker by default)

### Installation

1.  Clone the project and change into the project directory.

    ```sh
    git clone https://github.com/uniclogs/uniclogs-linux && cd $_
    ```

2.  Use docker-compose to build the container.

    ```sh
    docker compose build    
    ```

3.  Run the container and remote into it.

    ```sh
    docker compose run --rm rpi_imagegen 
    ```

### Generate an Image

From within the container, run the following command to build the image:

```sh
./build.sh -D ~/uniclogs -c uniclogs -o ~/uniclogs/uniclogs.options
```

This task will take a little time to complete.

### Copy Generated Image

To copy the generated image and files from within the container onto your
development system, run:

```sh
docker ps
docker cp <containerid>:/home/imagegen/rpi-image-gen/work/rpi_uniclogs/deploy /path/to/destination
```

docker ps will show you the container id. Make sure to replace `<containerid>`
in the above command with the actual container id.

## 🪪 License

This project is licensed under GPL v3, see the
[LICENSE](#LICENSE)
file for details.
