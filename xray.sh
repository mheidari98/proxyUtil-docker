#!/bin/sh
# https://github.com/teddysun/across/tree/master/docker/xray

ARCH="amd64"

# Download binary file
XRAY_FILE="xray_linux_${ARCH}"

echo "Downloading binary file: ${XRAY_FILE}"
wget -O /usr/bin/xray https://dl.lamp.sh/files/${XRAY_FILE} > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${XRAY_FILE}" && exit 1
fi
echo "Download binary file: ${XRAY_FILE} completed"

chmod +x /usr/bin/xray
