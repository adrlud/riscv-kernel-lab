#!/usr/bin/env bash
# Bygger alla moduler i modules/, packar om rotfilsystemet och bootar i QEMU.
#   ./scripts/go.sh        moduler + packa + boota
#   ./scripts/go.sh -k     bygg även om kärnan först
#   ./scripts/go.sh -n     bygg och packa, men boota inte
set -euo pipefail
cd "$(dirname "$0")/.."
export ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu-

KERNEL=0
BOOT=1
while getopts "kn" opt; do
  case $opt in
    k) KERNEL=1 ;;
    n) BOOT=0 ;;
    *) echo "Användning: $0 [-k] [-n]"; exit 1 ;;
  esac
done

if [ "$KERNEL" = 1 ]; then
  ./scripts/build-kernel.sh
fi
if [ ! -f linux/arch/riscv/boot/Image ]; then
  echo "Ingen kärna byggd. Kör ./scripts/build-kernel.sh först."
  exit 1
fi
if [ ! -d rootfs ]; then
  ./scripts/build-rootfs.sh
fi

mkdir -p rootfs/lib/modules
rm -f rootfs/lib/modules/*.ko
shopt -s nullglob
for dir in modules/*/; do
  name=$(basename "$dir")
  echo "== Bygger modul: $name"
  make -s -C linux M="$PWD/modules/$name" modules
  cp "$dir"*.ko rootfs/lib/modules/
done

(cd rootfs && find . | cpio -o -H newc 2>/dev/null | gzip > ../initramfs.cpio.gz)
echo "== Moduler i rotfilsystemet: $(ls rootfs/lib/modules | tr '\n' ' ')"

if [ "$BOOT" = 1 ]; then
  exec ./scripts/run.sh
fi
