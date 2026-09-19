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

# Use the host CPU model with KVM so QEMU does not advertise virtualization
# extensions from the wrong CPU vendor. Fall back to TCG when /dev/kvm is not
# available to this user (common inside VMs and containers).
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    accelerator_args="-enable-kvm -cpu host"
else
    accelerator_args="-accel tcg -cpu max,svm=off"
    printf 'warning: /dev/kvm is unavailable; using slower software emulation\n' >&2
fi

# accelerator_args and firmware_args are intentionally split into QEMU arguments.
# shellcheck disable=SC2086
qemu-system-x86_64 $accelerator_args -m 4096 -smp 4 $firmware_args \
    -cdrom binary.hybrid.iso
