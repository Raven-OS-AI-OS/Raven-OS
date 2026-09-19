#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

# Ask live-build to unmount and remove its state when it is available.  The
# explicit removal also makes this useful in CI images that only run checks.
if command -v lb >/dev/null 2>&1; then
    lb clean --purge
fi
rm -rf .build .cache binary cache chroot
rm -f .lock binary.contents binary.packages chroot.headers chroot.packages.*
rm -f raven-build.log binary.hybrid.iso binary.hybrid.iso.sha256
