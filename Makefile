SHELL := /usr/bin/bash

.PHONY: pack run unpack clean modprobe

modprobe:
	@sudo modprobe minix || true

pack: modprobe
	./scripts/pack.sh

run:
	./scripts/run-qemu.sh

unpack: modprobe
	./scripts/unpack.sh

clean:
	rm -f hd.img
