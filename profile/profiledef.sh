#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="arch-hypr"
iso_label="ARCH_HYPR"
iso_publisher="Custom Arch Hyprland Build"
iso_application="Arch Linux with Hyprland Preconfigured"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux' 'uefi.systemd-boot')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logged' '--no-check')
file_permissions=(
  ["/etc/shadow"]="0:0:0400"
  ["/etc/gshadow"]="0:0:0400"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/post-install.sh"]="0:0:755"
)
