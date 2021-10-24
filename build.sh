#!/bin/bash
#

EXTRA_PACKAGES="luci luci-app-unbound luci-app-adblock python3-requests libustream-openssl nano avahi-daemon tcpdump kmod-jool jool-tools smcroute"

if [[ ! -d ./buildroot ]]; then
  mkdir ./buildroot
fi

if [[ ! -f ./buildroot/openwrt/.config ]]; then
  echo "Copying configuration"
  cp config ./buildroot/openwrt/.config
  docker-compose run --rm -w /home/builder/openwrt builder make defconfig
else
  docker-compose run --rm -w /home/builder/openwrt builder make oldconfig
fi

# Clean up first
echo "Cleaning up sources..."
docker-compose run --rm -w /home/builder/openwrt builder make clean

echo "Updating/fetching OpenWRT sources..."
if [[ ! -d ./buildroot/openwrt ]]; then
  # Get fresh git repo
  docker-compose run --rm -w /home/builder builder git clone https://git.openwrt.org/openwrt/openwrt.git
else
  # Update repo
  docker-compose run --rm -w /home/builder/openwrt builder git pull
fi

echo "Updating package feeds..."
docker-compose run --rm -w /home/builder/openwrt builder "scripts/feeds" "update" "-a"

echo "Installing extra packages..."
docker-compose run --rm -w /home/builder/openwrt builder "scripts/feeds" "install" ${EXTRA_PACKAGES}

echo "Building custom OpenWRT image..."
docker-compose run --rm -w /home/builder/openwrt builder make -j2 download
docker-compose run --rm -w /home/builder/openwrt builder make -j6 world

echo "Done!"
echo "Image file(s):"
find buildroot/openwrt/bin/targets -name '*-sysupgrade.bin'
