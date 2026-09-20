#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
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
assert_contains scripts/test-build.sh '-cpu host'
assert_contains scripts/test-build.sh '-cpu max,svm=off'
assert_contains config/package-lists/raven-base.list.chroot 'gnupg'
assert_contains scripts/build-local-packages.sh 'config/local-packages'
assert_contains config/hooks/025-install-local-packages.chroot 'dpkg --install'
assert_contains packages/raven-customization/control 'Replaces: base-files, bash'
assert_contains packages/raven-customization/rootfs/etc/skel/.config/xfce4/xfce-perchannel-xml/xfce4-desktop.xml '/usr/share/backgrounds/raven/background.jpg'
assert_contains packages/raven-customization/rootfs/etc/lightdm/lightdm-gtk-greeter.conf.d/90-raven.conf 'background=/usr/share/backgrounds/raven/background.jpg'
assert_contains config/hooks/030-customize.chroot '/usr/share/desktop-base'
assert_contains config/hooks/030-customize.chroot "-name 'debian-*.xml'"
assert_contains config/hooks/030-customize.chroot '/usr/share/xfce4/backdrops/xubuntu-wallpaper.png'
assert_contains config/hooks/030-customize.chroot '/usr/sbin/lightdm'
assert_contains packages/raven-customization/rootfs/etc/lightdm/lightdm.conf.d/90-raven-session.conf 'user-session=xubuntu'
assert_contains config/package-lists/raven-desktop.list.chroot 'policykit-1-gnome'
assert_contains config/package-lists/raven-desktop.list.chroot 'xfce4-notifyd'

duplicates=$(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' config/package-lists/*.list.chroot | sort | uniq -d)
if [ -n "$duplicates" ]; then
    printf 'not ok - packages occur in multiple layers:\n%s\n' "$duplicates" >&2
    failures=$((failures + 1))
fi

test "$failures" -eq 0
printf 'All static stability tests passed.\n'
