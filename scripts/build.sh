#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

for command in lb xorriso grub-mkstandalone mkfs.vfat mcopy sha256sum; do
    if ! command -v "$command" >/dev/null 2>&1; then
        printf 'error: required build command not found: %s\n' "$command" >&2
        exit 127
    fi
done

# The commit timestamp is stable across machines. Callers producing a release
# from an exported tree may provide the same value explicitly.
: "${SOURCE_DATE_EPOCH:=$(git log -1 --format=%ct 2>/dev/null || printf 0)}"
export SOURCE_DATE_EPOCH TZ=UTC LANG=C.UTF-8 LC_ALL=C.UTF-8
umask 022

./scripts/clean-build.sh
lb config
lb build 2>&1 | tee raven-build.log
./scripts/make-hybrid-iso.sh binary binary.hybrid.iso
sha256sum binary.hybrid.iso > binary.hybrid.iso.sha256
printf 'Built binary.hybrid.iso (SOURCE_DATE_EPOCH=%s)\n' "$SOURCE_DATE_EPOCH"
