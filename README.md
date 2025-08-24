# Minix 2 (i386) — Pack/Unpack Dev Image

This repository produces a bootable MINIX 2 (32‑bit i386) hard disk image entirely from host‑side files using a manifest workflow. No binary `.img` is tracked in VCS. The filesystem already lives under `minix/fs`, so you can pack, boot in QEMU, and unpack changes back into regular files without any external image.

## Features
- Manifest system (create device nodes, permissions, copy files)
- `pack` builds `hd.img` from `minix/fs` and `minix/manifests`
- `unpack` syncs changes from the VM back into `minix/fs`
- No `.img` in VCS — images are generated locally

## Requirements
- Linux host
- `qemu-system-i386`, `rsync`, `sudo`
- Kernel module `minix` available: `sudo modprobe minix`

## Layout
- `scripts/`
  - `pack.sh`: build `hd.img` from template + manifests
  - `unpack.sh`: sync VM → host into `minix/fs`
  - `run-qemu.sh`: run QEMU with `hd.img`
  - `mkmanifest`: pack helper (template + mount + manifests)
  - `mkmanifest.sh`: helper functions for manifests (`copyfile`, `include`)
- `minix/`
  - `fs/`: host‑side working tree (what goes into the image)
  - `manifests/`: create device nodes, set perms, copy files
  - `templates/hd-64MB.img.gz`: empty, bootable HD template (boot 2.19). Floppy templates are not used.

## Quick start
```bash
cd minix32

# Build the image
make pack

# Run in QEMU
make run

# After changes in VM: clean exit (^D), close QEMU, then
make unpack
```

### Boot behavior (pack profile)
The pack manifest sets `/etc/ttytab` so the console starts a small script `/etc/pack.rc`. That script logs you in as `root` and shuts down when you exit.

## Manifests
Key manifests under `minix/manifests/`:
- `_core.manifest`: creates device nodes/permissions/owners
- `_everything.manifest`: rsyncs all host files into the image
- `pack.manifest`: pack profile; includes `_core` + `_everything`; sets `/etc/ttytab` to run `sh /etc/pack.rc`

## Makefile
Convenience targets: `make pack`, `make run`, `make unpack`, `make clean`.

## Common issues
- QEMU: “Could not open hd.img: Permission denied” → remove a root‑owned image: `sudo rm -f hd.img`, then `make pack`
- Boot: “Can’t load minix” → your `minix/fs` lacks the kernel or base system. Restore from VCS or copy from a known good tree.
- Mount errors: `unknown filesystem type 'minix'` → `sudo modprobe minix`

## Credits
- Templates, manifests, and pack/unpack approach adapted from `davidgiven/minix2` (Minix QD).
- MINIX 2 (i386) image layout and offsets referenced from `o-oconnell/minixfromscratch`.
- All original licenses retained (BSD 3‑Clause where applicable). Upstreams:
  - https://github.com/davidgiven/minix2
  - https://github.com/o-oconnell/minixfromscratch

## License
See individual file headers and upstream notices. Scripts derived from the above are BSD 3‑Clause.
