#!/bin/bash
#

function reconfig() {
  # Re-config after installing new packages
  echo "Re-copying configuration"
  cp config ./buildroot/openwrt/.config
  docker compose run --rm -w /home/builder/openwrt builder make defconfig
}

EXTRA_PACKAGES="luci luci-app-unbound luci-app-adblock python3-light python3-urllib python3-openssl python3-idna libustream-openssl avahi-daemon tcpdump nano htop"

reconfig

# Clean up first
echo "Cleaning up sources..."
docker compose run --rm -w /home/builder/openwrt builder make clean

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

echo "Installing extra packages..."
docker compose run --rm -w /home/builder/openwrt builder "scripts/feeds" "install" ${EXTRA_PACKAGES}

reconfig

echo "Downloading packages..."
docker compose run --rm -w /home/builder/openwrt builder make -j2 download

reconfig

echo "Building custom OpenWRT image..."
docker compose run --rm -w /home/builder/openwrt builder make -j6 clean world

echo "Done!"
echo "Image file(s):"
find buildroot/openwrt/bin/targets -name '*-sysupgrade.bin'
