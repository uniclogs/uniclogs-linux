# uniclogs-linux

**TODO:** Clean this up before merge

## Helpful Commands

```sh
docker compose build
docker compose run --rm rpi_imagegen 
```

When in the container, run the following command to build the image

```sh
./build.sh -D ~/uniclogs/ext_dir -c uniclogs -o ~/uniclogs/ext_dir/uniclogs.options
```

To copy the generated image and files from within the container , run:

```sh
docker ps
docker cp <containerid>:/home/imagegen/rpi-image-gen/work/uniclogs/deploy /path/to/destination
```

docker ps will show you the container id. Make sure to replace `<containerid>`
in the above command with the actual container id.



Original README content below
--------------------------------------------------------------------------------


**NOTE:** This is copied from the [UniClOGS v2 Main Info Doc](https://docs.google.com/document/d/1X3NJvZIJBoTSr9gLLe9Uswm0GSTiX_2NS_AyfrqKy0U/edit). These instructions are out of date and should **not be used**, they are here only as a starting point. Please fix.

Possible staring points:
- [Raspberry Pi Imager](https://www.raspberrypi.com/news/raspberry-pi-imager-imaging-utility/)
- [Ansible](https://docs.ansible.com/ansible/latest/index.html)


## Load software onto Station SBC (RasPi)

- RasPi distro
  - Using a laptop connected to the Internet, go to https://www.raspberrypi.com/software/operating-systems/
    - Choose  Raspberry Pi OS (64-bit) then [Raspberry Pi OS Lite](https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2023-10-10/2023-10-10-raspios-bookworm-arm64-lite.img.xz?_gl=1*fugisi*_ga*NTI1MjkwMTM3LjE3MDAzNDk3MDI.*_ga_22FD70LWDS*MTcwMDM2MjIxNS4yLjEuMTcwMDM2MjI0Ni4wLjAuMA..) to download
  - Using the laptop, to place onto a uSD card I use [Etcher - AppImage](https://github.com/balena-io/etcher/releases/tag/v1.18.13)
    - Choose the latest AppImage in the repo to download
      - Actually there is an issue with newer versions of Etcher, and the GitHub site says that [version 1.18.11](https://github.com/balena-io/etcher/releases?page=2) is needed. I confirmed this older version does work under Ubuntu.
    - Make the Appimage executable
    - Double click to run
      - Depending on your laptop system, you may need to install the FUSE library
        - sudo apt install libfuse2
    - Choose Flash from file, and then select the RasPi image file just downloaded
    - Place a 32 GB Type 10 uSD card into an SD card slot and choose that as the target
    - Click Flash
    - Remove uSD card from the laptop and place into RasPi
  - Connect a KVM to the Pi
  - Power up RasPi by placing the USB-C power cable back in; Should see the Linux startup messages on the KVM.
  - Initial RasPi Linux setup
    - US Keyboard (Maybe UK keyboard?)
    - Set username/password (See BitWarden for credentials)
    - Login for the first time
    - Find IPV4 address using ifconfig and make note of it for future use.
    - Run raspi-config
      - sudo raspi-config
        - Set hostname (follow naming conventions for UniClOGS stations; For example ucl-uniclogs)
        - Set locale; en_GB.UTF-8 is currently set; Either leave it, or change to en_US.UTL-8.
        - Expand file system
        - Reboot
  - Login again
  - Run raspi-config again
    - sudo raspi-config
      - Interface settings
        - ssh
        - Enable
  - Logout

  - Update and add some basic tools that will be needed later
    - sudo apt update
      - Set the system clock if you get time related errors
    - sudo apt upgrade
    - sudo apt install git i2c-tools netcat-openbsd libhamlib-utils




------------ // TODO: Implement steps below

  - Place 40 pin flat cable between Station SBC and UPD. Note location of pin-1 on each side.

  - Load UniClOGS ground station codebase for
    - Stationd
      - git clone --recurse-submodules https://github.com/uniclogs/uniclogs-stationd.git
      - cd uniclogs-stationd/examples/
      - sudo ./install.sh
      - sudo reboot

    - Pass-Commander
      - [Install instructions](https://github.com/uniclogs/uniclogs-pass_commander#installing)
      - Collect information and configure
        - Callsign to ident with at the beginning and end of each pass
        - GPS coordinates of ground station
        - Elevation in meters
        - OpenWeatherMap API key
        - IP address of radio host
        - IP addresses of system running rotctld and station if not the same system you are installing pass_commander on
    - Anything else needed

## Load Software onto Radio SBC

- Using a laptop connected to the InternetCreate image on USB stick
  - Go to ubuntu.com/download
  - Select Server
  - Download Ubuntu Server 22.04.3 LTS
  - Should see file:
  - Ubuntu-22.04.3-live-server-amd64.iso
  - Place an unused flash drive (I chose a 16 GB stick to be safe) into the laptop you're working on.
  - Find the drive: (I found)
  - /dev/sdb
  - /dev/sdb1  /media/glenn/USB20FD
  - Make a file system on the flash drive
  - sudo mkfs.vfat /dev/sdb -I
  - Copy the image file (ISO) to the flash drive
  - sudo dd if=~/Downloads/ubuntu-22.04.3-live-server-amd64.iso of=/dev/sdb
  - The dd command will silently copy the image, and then report at the end. Should see some 2GB copied.
  - The filesystem was never mounted, so umount is not needed. To be safe I used the “eject” command from the Files tool, but that may be unnecessary.

- AWOW powerup and setup screens
  - Connect a KVM to the AWOW
  - Connect the LAN connection to the AWOW.
  - Insert the USB stick just loaded with the OS into any of the USP ports on the AWOW.
  - Unless the UPD board has the Radio SBC (AWOW) power port active, remove that power connection and connect the  external power brick that came with the AOW. This powers up the AWOW for the first time.
  - Needing to get to the AWOW BIOS, and not load the default Windows configuration, press <[Del/Delete](https://awowtech.com/pages/how-to-enter-bios-settings-for-awow-mini-pc-pc-stick)> until the BIOS screen is seen. 
  - Change the default boot order to start with the USB stick.
  - Press <F4> - Save and Exit
  - Now the AWOW will boot Ubuntu Server 22.04 LTS for the first time;
    - Choose Install Ubuntu Server
    - Use entire disk
    - At this point we can discover the IPV4 address of the LAN connection we got from the DHCP server. Write it down for future use.
    - Most of the setup can be left as default
      - English
      - Continue without updating the installer to 23.04.3
      - Keyboard English US (Unless not)
      - Base -> Ubuntu Server
    - Storage layout and configuration left as default
  - Continue
  - Set the SBC’s identity for the first time
    - Name: UCL  (This is an example of the particular system being setup’ Change as appropriate)
    - Server name: ucl-radio
    - Username: ucl-admin [should be uniclogs]
    - Password: ********** (See BitWarden for credentials)
  - Skip upgrade to Ubuntu-Pro
  - Install ssh
  - Import ssh identity: No
  - Snaps: Choose none
  - Reboot
    - Pull out the USB stick and keep for any future needs
    - Press enter to actually do the reboot
    - login: ucl-admin [uniclogs]
  - Check LAN
    - ping google.com

- sudo apt update && sudo apt upgrade
- Load UniClOGS ground station codebase for Radio SBC by following instructions [here](https://github.com/uniclogs/uniclogs-sdr/blob/maint-3.10/flowgraphs/README.md#basic-setup-starting-from-a-fresh-install-of-ubuntu-server-22044-lts)



