#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

mode=${1:-bios}
case "$mode" in
    bios)
        firmware_args=
        ;;
    uefi)
        ovmf=${OVMF_CODE:-/usr/share/OVMF/OVMF_CODE.fd}
        test -r "$ovmf" || {
            printf 'error: UEFI firmware not found at %s (set OVMF_CODE)\n' "$ovmf" >&2
            exit 1
        }
        firmware_args="-drive if=pflash,format=raw,readonly=on,file=$ovmf"
        ;;
    *)
        printf 'usage: %s [bios|uefi]\n' "$0" >&2
        exit 2
        ;;
esac

# firmware_args is intentionally split into QEMU arguments.
# shellcheck disable=SC2086
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 $firmware_args -cdrom binary.hybrid.iso
