# Raven customization package

This directory is the source tree for the `raven-customization` Debian package.
Files below `rootfs/` are installed at the corresponding paths in the live
system. Package metadata is kept in `control`.

Build the package from the repository root:

```sh
./scripts/build-local-packages.sh
```

The generated package is written below `config/local-packages/` and installed
by `config/hooks/025-install-local-packages.chroot`. This avoids the obsolete
GnuPG 1 repository-signing flow in the legacy `live-build` version. The
generated `.deb` is a build artifact and is not committed.

Increase the version in `control` whenever an already-published package changes.
