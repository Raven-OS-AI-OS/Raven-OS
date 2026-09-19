#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"
failures=0

require() {
    if ! grep -Fq -- "$2" "$1"; then
        printf 'error: %s must contain: %s\n' "$1" "$2" >&2
        failures=$((failures + 1))
    fi
}

# Keep the operating system usable without the higher-level AI toolchain.
for package in linux-image-generic casper network-manager; do
    require config/package-lists/base.list.chroot "$package"
    if grep -Fqx "$package" config/package-lists/ai.list.chroot; then
        printf 'error: base package %s leaked into the AI layer\n' "$package" >&2
        failures=$((failures + 1))
    fi
done

# Assert both independently bootable firmware paths are assembled.
require scripts/make-hybrid-iso.sh 'isolinux/isolinux.bin'
require scripts/make-hybrid-iso.sh 'BOOTX64.EFI'
require scripts/make-hybrid-iso.sh '-isohybrid-gpt-basdat'

test "$failures" -eq 0
printf 'Layering and dual-boot layout checks passed.\n'
