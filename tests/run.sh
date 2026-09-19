#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

failures=0
for file in auto/config scripts/*.sh config/hooks/* tests/*.sh; do
    if ! sh -n "$file"; then
        failures=$((failures + 1))
    fi
done

assert_contains() {
    grep -Fq -- "$2" "$1" || {
        printf 'not ok - %s lacks %s\n' "$1" "$2" >&2
        failures=$((failures + 1))
    }
}

assert_contains config/bootloaders/isolinux/raven-live.cfg.in '/casper/vmlinuz'
assert_contains scripts/make-hybrid-iso.sh '/casper/vmlinuz'
assert_contains scripts/make-hybrid-iso.sh 'x86_64-efi'
assert_contains scripts/build.sh 'SOURCE_DATE_EPOCH'
assert_contains scripts/build.sh './scripts/clean-build.sh'

duplicates=$(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' config/package-lists/*.list.chroot | sort | uniq -d)
if [ -n "$duplicates" ]; then
    printf 'not ok - packages occur in multiple layers:\n%s\n' "$duplicates" >&2
    failures=$((failures + 1))
fi

test "$failures" -eq 0
printf 'All static stability tests passed.\n'
