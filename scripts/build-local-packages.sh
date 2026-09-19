#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
package_source="$repo_root/packages/raven-customization"
output_dir="$repo_root/config/local-packages"
legacy_output_dir="$repo_root/config/packages.chroot"
temporary_dir=$(mktemp -d "${TMPDIR:-/tmp}/raven-packages.XXXXXX")

cleanup() {
    rm -rf "$temporary_dir"
}
trap cleanup EXIT HUP INT TERM

command -v dpkg-deb >/dev/null 2>&1 || {
    echo "error: dpkg-deb is required to build local packages" >&2
    exit 1
}

package=$(sed -n 's/^Package: //p' "$package_source/control")
version=$(sed -n 's/^Version: //p' "$package_source/control")
architecture=$(sed -n 's/^Architecture: //p' "$package_source/control")

if [ -z "$package" ] || [ -z "$version" ] || [ -z "$architecture" ]; then
    echo "error: incomplete package metadata in $package_source/control" >&2
    exit 1
fi

package_root="$temporary_dir/$package"
mkdir -p "$package_root/DEBIAN" "$output_dir"
# Keep exactly one version in the hook's input directory. Otherwise dpkg may
# attempt an older, incompatible build before the current package.
rm -f "$output_dir/${package}_"*.deb
# live-build 3 signs config/packages.chroot with obsolete GnuPG 1 commands.
# Remove artifacts from the old location so modern GnuPG is never invoked by
# that compatibility path.
rm -f "$legacy_output_dir/${package}_"*.deb
cp -a "$package_source/rootfs/." "$package_root/"
install -m 0644 "$package_source/control" "$package_root/DEBIAN/control"

dpkg-deb --root-owner-group --build "$package_root" \
    "$output_dir/${package}_${version}_${architecture}.deb"
