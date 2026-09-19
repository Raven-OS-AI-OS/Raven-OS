# Raven customization package

This directory is the source tree for the `raven-customization` Debian package.
Files below `rootfs/` are installed at the corresponding paths in the live
system. Package metadata is kept in `control`.

Build the package from the repository root:

```sh
./scripts/build-local-packages.sh
```

The generated package is written to `config/packages.chroot/`, where
`live-build` automatically includes it in the image. The generated `.deb` is a
build artifact and is not committed.

Increase the version in `control` whenever an already-published package changes.
