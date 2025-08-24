#!/bin/sh
# QEMU runner: defaults to VGA window. Set QEMU_DISPLAY=serial for stdio console.
# Set QEMU_CPU to override CPU model (default: pentium). Examples: QEMU_CPU=host or QEMU_CPU=486

IMAGE=hd.img
ACCEL="-machine accel=kvm:tcg"
CPU_MODEL="${QEMU_CPU:-pentium}"
CPU="-cpu $CPU_MODEL"
MEM="-m 64"
SMP="-smp 1"
DRIVE="-drive format=raw,file=$IMAGE,if=ide"
BOOT="-boot c"

if [ "${QEMU_DISPLAY:-vga}" = "serial" ]; then
	# Serial console to host stdio; no GUI window
	DISPLAY_OPTS="-serial mon:stdio -display none"
else
	DISPLAY_OPTS=""
fi

exec qemu-system-i386 \
	$ACCEL \
	$CPU \
	$SMP \
	$MEM \
	$DRIVE \
	$BOOT \
	$DISPLAY_OPTS
