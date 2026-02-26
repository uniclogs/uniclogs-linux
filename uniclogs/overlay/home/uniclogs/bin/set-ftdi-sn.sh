#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
    echo "This tool must be run as root."
    exit 1
fi

echo "This tool makes no effort to determine if any install has already taken place."
read -p "Press Enter to proceed. Ctrl-C to abort." RVAL

SERIAL=$(lsusb -vd 0403:6001 2>/dev/null | awk '$1=="iSerial"{print$3}')
if [ "${#SERIAL}" -eq 8 ]; then
    echo "Found a single FTDI UART interface and assumed it is the rotator controller."
    sed -i "s/xxxxxxxx/$SERIAL/" /etc/udev/rules.d/99-serial.rules99-serial.rules /etc/systemd/system/rotctld.service
    echo "FTDI UART Serial Number updated in 99-serial.rules and rotctld.service!"
else
    echo -e "Could not find FTDI UART interface. \n" \
        "Be sure to manually update the rotator FTDI serial numbers in these files:\n" \
	    "   /etc/udev/rules.d/99-serial.rules\n" \
	    "   /etc/systemd/system/rotctld.service"
fi
