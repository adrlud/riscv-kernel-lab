#!/usr/bin/env bash
# Hämtar och bygger Linux-kärnan för RISC-V (64-bit).
set -euo pipefail
cd "$(dirname "$0")/.."
BRANCH="${KERNEL_BRANCH:-linux-6.18.y}"   # LTS-gren; byt med KERNEL_BRANCH=...
export ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu-

if [ ! -d linux ]; then
  git clone --depth 1 --branch "$BRANCH" https://github.com/gregkh/linux.git linux
fi
cd linux
[ -f .config ] || make defconfig
make -j"$(nproc)"
echo "Kärnan ligger i linux/arch/riscv/boot/Image"
