#!/bin/sh
set -e

IMAGE=hd.img
MNT=$(mktemp -d /tmp/minix32-mnt-XXXXXX)
MNTUSR=$(mktemp -d /tmp/minix32-mnt-XXXXXX)

echo "Mount point:  $MNT"

echo "Aux usr mnt: $MNTUSR"

sudo modprobe minix 2>/dev/null || true

try_mount() {
	_off="$1"; _label="$2"; _target="$3"
	_opts="-o loop"
	if [ -n "$_off" ]; then _opts="-o loop,offset=$_off"; fi
	echo "Trying offset ${_off:-none} ($_label) -> $_target"
	if sudo mount -t minix $_opts "$IMAGE" "$_target" 2>/dev/null; then return 0; fi
	return 1
}

try_mount_limit() {
	_off="$1"; _size="$2"; _label="$3"; _target="$4"
	_opts="-o loop,offset=$_off,sizelimit=$_size"
	echo "Trying offset $_off size $_size ($_label) -> $_target"
	if sudo mount -t minix $_opts "$IMAGE" "$_target" 2>/dev/null; then return 0; fi
	return 1
}

# 1) Direct filesystem
try_mount "" "direct" "$MNT" || true

# 2) Fixed 512 offset (MBR)
if ! mountpoint -q "$MNT"; then
	try_mount 512 "mbr+512" "$MNT" || true
fi

# 3) fdisk-detected Minix partition start sector
root_start=""
if ! mountpoint -q "$MNT"; then
	start_sec=$(sudo fdisk -l "$IMAGE" 2>/dev/null | awk '/Minix/ {for(i=1;i<=NF;i++){ if($i ~ /^[0-9]+$/){ print $i; exit } }}' | head -n1)
	if echo "$start_sec" | grep -Eq '^[0-9]+$'; then
		root_start="$start_sec"
		off=$((start_sec * 512))
		try_mount "$off" "fdisk-start=$start_sec" "$MNT" || true
	fi
fi

# 4) Known MINIX book image layout: root at 65 sectors for 2880 sectors; usr at 2945
if ! mountpoint -q "$MNT"; then
	try_mount_limit $((65*512)) $((2880*512)) "book-root" "$MNT" || true
fi

if ! mountpoint -q "$MNT"; then
	# Also try starting exactly at 64 with the same sizelimit
	try_mount_limit $((64*512)) $((2880*512)) "book-root-64" "$MNT" || true
fi

if ! mountpoint -q "$MNT"; then
	echo "Failed to mount $IMAGE as MINIX root filesystem." >&2
	rmdir "$MNT" "$MNTUSR"
	exit 1
fi

linkfile=/tmp/$$.linkfile
trap "sudo umount $MNT; rmdir $MNT; sudo umount $MNTUSR 2>/dev/null || true; rmdir $MNTUSR; rm -f $linkfile" EXIT

# Sync root filesystem
sudo rsync -av \
    --hard-links \
    --delete \
    --whole-file \
    --no-specials \
    --chown $(whoami) \
    --exclude 'dev' \
    --exclude 'etc/ttytab' \
    --exclude 'etc/mtab' \
    --exclude 'etc/utmp' \
    --exclude 'usr/adm' \
    --exclude 'boot' \
    "$MNT"/ \
    minix/fs/ \
    > "$linkfile"

awk '/ => / { print "ln -sfr ./" $3 " " $1 }' "$linkfile" | (cd minix/fs && sh)

# Try separate /usr at 2945
if try_mount $((2945*512)) "book-usr" "$MNTUSR"; then
	echo "Syncing separate /usr from 2945"
	sudo rsync -av \
	  --hard-links \
	  --delete \
	  --whole-file \
	  --no-specials \
	  --chown $(whoami) \
	  "$MNTUSR"/ \
	  minix/fs/usr/
fi
