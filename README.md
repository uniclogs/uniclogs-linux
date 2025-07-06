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
inside the Docker container (where the image build process occurs).

## Getting Started

These instructions will walk you through the process of setting up this project
on a development system.

### Prerequisites

- [Docker](https://docs.docker.com/engine/)
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

### Generating an Image

If running on a non-ARM host, from within the container, run the following
command to set binfmt_misc (it will prompt for the build user's password, which
is `imagegen`):

```sh
sudo mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
```

Then build the image:

```sh
./build.sh -D ~/uniclogs -c uniclogs -o ~/uniclogs/uniclogs.options
```

This task will take a little time to complete.

### Copying the Generated Image Files

To copy the generated image and files from within the container onto the host
system, run:

```sh
docker ps
docker cp <containerid>:/home/imagegen/rpi-image-gen/work/rpi_uniclogs/deploy /path/to/destination
```

docker ps will show you the container id. Make sure to replace `<containerid>`
in the above command with the actual container id.
