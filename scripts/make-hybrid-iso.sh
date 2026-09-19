#!/bin/sh
set -eu

tree=${1:-binary}
output=${2:-binary.hybrid.iso}
volume=${ISO_VOLUME:-Raven_NOBLE}
epoch=${SOURCE_DATE_EPOCH:-0}

test -f "$tree/isolinux/isolinux.bin"
test -f "$tree/casper/vmlinuz"
test -f "$tree/casper/initrd.img"

for command in xorriso grub-mkstandalone mkfs.vfat mcopy; do
    command -v "$command" >/dev/null 2>&1 || {
        printf 'error: required ISO command not found: %s\n' "$command" >&2
        exit 127
    }
done

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT INT TERM
mkdir -p "$tree/boot/grub" "$tree/EFI/BOOT"

cat > "$tree/boot/grub/grub.cfg" <<'EOF'
set timeout=5
set default=0

menuentry "Start Raven OS" {
    linux /casper/vmlinuz boot=casper components quiet splash
    initrd /casper/initrd.img
}
menuentry "Start Raven OS (safe graphics)" {
    linux /casper/vmlinuz boot=casper components nomodeset
    initrd /casper/initrd.img
}
EOF

cat > "$work/embedded.cfg" <<EOF
search --no-floppy --label --set=root $volume
set prefix=(\$root)/boot/grub
configfile /boot/grub/grub.cfg
EOF
grub-mkstandalone --format=x86_64-efi \
    --output="$tree/EFI/BOOT/BOOTX64.EFI" \
    --locales= --fonts= "boot/grub/grub.cfg=$work/embedded.cfg"

efi_image="$tree/boot/grub/efi.img"
truncate -s 4M "$efi_image"
mkfs.vfat --invariant -i 5241564e -n RAVEN_EFI "$efi_image" >/dev/null
mmd -i "$efi_image" ::/EFI ::/EFI/BOOT
touch -d "@$epoch" "$tree/EFI/BOOT/BOOTX64.EFI" "$tree/boot/grub/grub.cfg"
mcopy -m -i "$efi_image" "$tree/EFI/BOOT/BOOTX64.EFI" ::/EFI/BOOT/BOOTX64.EFI

# xorriso honors SOURCE_DATE_EPOCH for ISO timestamps. A fixed modification
# date also covers older xorriso releases and files emitted by legacy live-build.
iso_date=$(date -u -d "@$epoch" +%Y%m%d%H%M%S00 2>/dev/null || printf 1970010100000000)
mbr=${ISOHYBRID_MBR:-/usr/lib/ISOLINUX/isohdpfx.bin}
test -f "$mbr"
# Normalize the staged tree after all generated boot files have been written.
find "$tree" -exec touch -h -d "@$epoch" {} +
tmp_output="$output.tmp"
rm -f "$tmp_output"
xorriso -as mkisofs -quiet -r -J -joliet-long -V "$volume" \
    --modification-date="$iso_date" \
    -isohybrid-mbr "$mbr" -partition_offset 16 \
    -c isolinux/boot.cat -b isolinux/isolinux.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
    -isohybrid-gpt-basdat -o "$tmp_output" "$tree"
mv "$tmp_output" "$output"
