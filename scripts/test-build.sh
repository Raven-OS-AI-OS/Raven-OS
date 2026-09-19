#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cdrom binary.hybrid.iso
