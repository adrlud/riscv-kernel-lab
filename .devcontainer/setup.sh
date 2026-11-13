#!/usr/bin/env bash
# Installerar allt som behövs för att korskompilera Linux för RISC-V och köra i QEMU.
set -euo pipefail
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  build-essential bc bison flex libssl-dev libelf-dev libncurses-dev \
  gcc-riscv64-linux-gnu libc6-dev-riscv64-cross \
  qemu-system-misc opensbi cpio git ca-certificates gdb-multiarch
echo "Klart. Kör: ./scripts/build-kernel.sh && ./scripts/build-rootfs.sh && ./scripts/run.sh"
