#!/bin/sh
# https://github.com/v2fly/docker

ARCH="64"
TAG=$(curl -sSL --retry 5 "https://api.github.com/repos/v2fly/v2ray-core/releases/latest" | jq .tag_name | awk -F '"' '{print $2}')

# Download files
V2RAY_FILE="v2ray-linux-${ARCH}.zip"
DGST_FILE="v2ray-linux-${ARCH}.zip.dgst"
echo "Downloading binary file: ${V2RAY_FILE}"
echo "Downloading binary file: ${DGST_FILE}"

wget -O ${PWD}/v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${V2RAY_FILE} > /dev/null 2>&1
wget -O ${PWD}/v2ray.zip.dgst https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${DGST_FILE} > /dev/null 2>&1


if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${V2RAY_FILE} ${DGST_FILE}" && exit 1
fi
echo "Download binary file: ${V2RAY_FILE} ${DGST_FILE} completed"

# Check SHA512
V2RAY_ZIP_HASH=$(openssl dgst -sha512 v2ray.zip | sed 's/([^)]*)//g' | awk '{split($0,a,"= "); print a[2]}')
V2RAY_ZIP_DGST_HASH=$(cat v2ray.zip.dgst | grep -E 'SHA(2-)?512' | awk '{split($0,a,"= "); print a[2]}')

if [ "${V2RAY_ZIP_HASH}" = "${V2RAY_ZIP_DGST_HASH}" ]; then
    echo " Check passed" && rm -fv v2ray.zip.dgst
else
    echo "V2RAY_ZIP_HASH: ${V2RAY_ZIP_HASH}"
    echo "V2RAY_ZIP_DGST_HASH: ${V2RAY_ZIP_DGST_HASH}"
    echo " Check have not passed yet " && exit 1
fi

# Prepare
echo "Prepare to use"
unzip v2ray.zip && chmod +x v2ray
mv v2ray /usr/bin/
mv geosite.dat geoip.dat /usr/local/share/v2ray/
mv config.json /etc/v2ray/config.json

# Clean
rm -rf ${PWD}/*
echo "Done"
