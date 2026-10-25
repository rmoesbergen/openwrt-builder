#!/bin/bash
#

function reconfig() {
  # Re-config after installing new packages
  echo "Re-copying configuration"
  cp config ./buildroot/openwrt/.config
  docker compose run --rm -w /home/builder/openwrt builder make defconfig
}

EXTRA_PACKAGES="luci luci-app-unbound luci-app-adblock luci-proto-wireguard python3-light python3-paho-mqtt libustream-openssl avahi-daemon tcpdump nano htop ethtool iputils-arping"

# Clean up first
echo "Cleaning up sources..."
docker compose run --rm -w /home/builder/openwrt builder make dirclean

cp config ./buildroot/openwrt/.config

echo "Updating/fetching OpenWRT sources..."
if [[ ! -d ./buildroot/openwrt ]]; then
  # Get fresh git repo
  docker compose run --rm -w /home/builder builder git clone https://git.openwrt.org/openwrt/openwrt.git
else
  # Update repo
  docker compose run --rm -w /home/builder/openwrt builder git pull
fi

echo "Updating package feeds..."
docker compose run --rm -w /home/builder/openwrt builder "scripts/feeds" "update" "-a"
docker compose run --rm -w /home/builder/openwrt builder "scripts/feeds" "install" "-a"

echo "Installing extra packages..."
docker compose run --rm -w /home/builder/openwrt builder "scripts/feeds" "install" ${EXTRA_PACKAGES}

reconfig

echo "Building world..."
docker compose run --rm -w /home/builder/openwrt builder make -j2 download clean world

echo "Done!"
echo "Image file(s):"
find buildroot/openwrt/bin/targets -name '*-sysupgrade.bin'
