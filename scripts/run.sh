#!/usr/bin/env bash
# Bootar kärnan i QEMU. Avsluta med 'poweroff -f' (eller Ctrl-A följt av X).
# Lägg till -s -S för att vänta på gdb: ./scripts/run.sh -s -S
set -euo pipefail
cd "$(dirname "$0")/.."
exec qemu-system-riscv64 -machine virt -smp 2 -m 1G -nographic \
  -kernel linux/arch/riscv/boot/Image \
  -initrd initramfs.cpio.gz \
  -append "console=ttyS0 earlycon" "$@"
