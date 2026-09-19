#!/bin/sh

# Guard the live-build configuration against accidentally falling back to
# Debian defaults when files are moved or regenerated.
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

failures=0

require_line() {
    file=$1
    expected=$2

    if ! grep -Fqx -- "$expected" "$file"; then
        printf 'error: %s must contain: %s\n' "$file" "$expected" >&2
        failures=$((failures + 1))
    fi
}

require_argument() {
    expected=$1

    if ! grep -Fq -- "$expected" auto/config; then
        printf 'error: auto/config must configure: %s\n' "$expected" >&2
        failures=$((failures + 1))
    fi
}

# Check both the reproducible source of truth and the checked-in configuration
# produced by live-build. This catches partial regeneration as well as edits.
require_argument "--mode ubuntu"
require_argument "--distribution noble"
require_argument "--parent-distribution noble"
require_argument "--keyring-packages ubuntu-keyring"
require_argument 'main restricted universe multiverse'
require_argument "archive.ubuntu.com/ubuntu"
require_argument "security.ubuntu.com/ubuntu"
require_argument "--initramfs casper"

require_line config/common 'LB_MODE="ubuntu"'
require_line config/common 'LB_INITRAMFS="casper"'
require_line config/bootstrap 'LB_DISTRIBUTION="noble"'
require_line config/bootstrap 'LB_PARENT_DISTRIBUTION="noble"'
require_line config/bootstrap 'LB_ARCHIVE_AREAS="main restricted universe multiverse"'
require_line config/bootstrap 'LB_PARENT_ARCHIVE_AREAS="main restricted universe multiverse"'
require_line config/chroot 'LB_KEYRING_PACKAGES="ubuntu-keyring"'
require_line config/chroot 'LB_LINUX_FLAVOURS="generic"'

if [ "$failures" -ne 0 ]; then
    printf '\nUbuntu compatibility check failed with %s error(s).\n' "$failures" >&2
    exit 1
fi

printf 'Ubuntu Noble live-build compatibility checks passed.\n'
