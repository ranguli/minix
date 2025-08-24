# MINIX 2

## What is this?

This repository contains a full-fledged (unofficial) distribution of MINIX 2 which has been modernized from it's original form  (a series of raw floppy disk images to be installed on real hardware) to a coherent repository that uses version control and scripts to easily create MINIX systems in QEMU for easy tinkering. 

## Why did you make this?

Because of the way things worked when MINIX 2 was released. MINIX 2 was distributed as a series of floppy disk images, which all had to be installed (like any OS of the day). There wasn't a `git clone https://minix2.org && make && ./run-minix`. Setting up MINIX 2 to be structured and function like a project repository in the way we think of it today is actually fairly challenging (for a whole host of boring techical reasons I won't get into nor do I even fully understand).

There are already (at least) two existing projects that aim to achieve a similar goal. This project is essentially a fork of [davidgiven/minix2](https://github.com/davidgiven/minix2). This project handles those fairly challenging technical reasons I mentioned earlier, and allows simple conversion back and forth between a Git repository containing a MINIX filesystem (with the codebase) and a MINIX-compatible QEMU hard disk `.img`. However, it only supports 16-bit MINIX, and it also supports MINIX 1.7 (which I'm not interested in).

So I took the parts I was interested in (the QEMU <-> git plumbing glue), but actually used a 32-bit MINIX disk image from a second, similar project, [o-oconnel/minixfromscratch](https://github.com/o-oconnel/minixfromscratch) as the seed to bootstrap the initial system, then unpacked it (_with the glue_), and here we are.

## Why MINIX 2?

MINIX is really cool operating system in general - it's a full UNIX-like operating system that has an almost 1000 page book describing it's internals in a very high level of detail. It's literally designed to be a teaching/learning tool. To me MINIX 2 sits at a sweet spot between not too old (i.e we at least have C89 instead of K&R C) but not too complex to tinker with (MINIX 3 has a whole bunch of crazy stuff going on with integrating NetBSD compatibility, etc. It's a lot to try and wrap your head around).


## Quick start
```bash

# Build a QEMU VM image based on the contents of minix/
make pack

# Run that image in QEMU
make run

# After you're done modifying or recompiling MINIX inside the VM, run 'shutdown' (necessary to prevent data corruption!)
# then to have your work reflected back in this repostiory simply run:
make unpack

# Now the repository reflects the state of the VMs filesystem
```

## Credits

  - https://github.com/davidgiven/minix2
  - https://github.com/o-oconnell/minixfromscratch

## License

This repository is licensed under the BSD 3-Clause License, the same license that MINIX has (it was originally proprietary, but was open-sourced). See LICENSE for more information.