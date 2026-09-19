#!/bin/sh
set -eu

iso=${1:-binary.hybrid.iso}
test -s "$iso"
command -v xorriso >/dev/null 2>&1 || {
    printf 'error: xorriso is required to inspect %s\n' "$iso" >&2
    exit 127
}

report=$(xorriso -indev "$iso" -report_el_torito plain 2>&1)
printf '%s\n' "$report" | grep -Eq 'BIOS.*isolinux/isolinux\.bin|BIOS'
printf '%s\n' "$report" | grep -Eq 'UEFI.*boot/grub/efi\.img|UEFI'

for path in /casper/vmlinuz /casper/initrd.img /EFI/BOOT/BOOTX64.EFI /boot/grub/grub.cfg; do
    xorriso -indev "$iso" -find "$path" -print 2>/dev/null | grep -Fq "$path"
done
printf 'ISO contains valid BIOS and UEFI boot payloads.\n'
