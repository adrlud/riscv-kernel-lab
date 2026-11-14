# RISC-V kernel lab

En färdig GitHub Codespaces-miljö för att bygga Linux-kärnan för RISC-V och boota den i QEMU.

## Kom igång

1. Öppna repot på GitHub, välj **Code → Codespaces → Create codespace**.
2. Vänta tills verktygen installerats (ett par minuter).
3. Kör i terminalen:

```
./scripts/build-kernel.sh    # hämtar och bygger kärnan (ca 20–40 min första gången)
./scripts/build-rootfs.sh    # bygger ett minimalt BusyBox-system (ca 1 min)
./scripts/run.sh             # bootar i QEMU
```

Avsluta QEMU med `poweroff -f`.

## Utvecklingsloopen

1. Ändra något i `linux/`, t.ex. lägg till `pr_info("Hej från Adrian\n");` i `start_kernel()` i `linux/init/main.c`.
2. `./scripts/build-kernel.sh` (bygger bara om det ändrade).
3. `./scripts/run.sh` och leta efter din rad i loggen.

## Egna moduler

Lägg varje modul i en egen mapp under `modules/` (källfil + `Makefile` med `obj-m := namn.o`). Sedan:

```
./scripts/go.sh       # bygger alla moduler, packar om rotfilsystemet och bootar
./scripts/go.sh -k    # bygger även om kärnan först
./scripts/go.sh -n    # bygger och packar, men bootar inte
```

Modulerna hamnar i `/lib/modules/` i den bootade kärnan.

Vanliga program (userspace) läggs som `.c`-filer i `userspace/`. `go.sh` bygger dem statiskt och lägger dem i `/bin/`, så `userspace/satp.c` körs med kommandot `satp`.

## Felsöka med gdb

```
./scripts/run.sh -s -S                  # terminal 1: QEMU väntar på gdb
gdb-multiarch linux/vmlinux \
  -ex "target remote :1234" -ex "break start_kernel" -ex "continue"   # terminal 2
```

## Kostnad

Miljön begär 4 kärnor. Stoppa codespacet när du är klar (det stoppas också
automatiskt efter 30 min inaktivitet) så räcker gratiskvoten längre.
