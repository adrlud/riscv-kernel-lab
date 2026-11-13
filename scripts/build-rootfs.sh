#!/usr/bin/env bash
# Bygger ett minimalt rotfilsystem (BusyBox) som initramfs.
set -euo pipefail
cd "$(dirname "$0")/.."
export ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu-

if [ ! -d busybox ]; then
  git clone --depth 1 --branch 1_36_1 https://github.com/mirror/busybox.git busybox
fi
cd busybox
if [ ! -f .config ]; then
  make defconfig >/dev/null
  sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
  sed -i 's/^CONFIG_TC=y/# CONFIG_TC is not set/' .config   # bygger inte mot nya kärnheaders
  (yes "" || true) | make oldconfig >/dev/null
fi
make -j"$(nproc)"
rm -rf ../rootfs && make CONFIG_PREFIX=../rootfs install >/dev/null
cd ../rootfs
mkdir -p proc sys dev etc tmp
cat > init <<'INIT'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null
echo
echo "Din egen RISC-V-kärna kör: $(uname -r) på $(uname -m)"
echo "Skriv 'poweroff -f' för att avsluta."
setsid cttyhack sh
poweroff -f
INIT
chmod +x init
find . | cpio -o -H newc 2>/dev/null | gzip > ../initramfs.cpio.gz
echo "Rotfilsystemet ligger i initramfs.cpio.gz"
