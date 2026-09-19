<div align="center">

<img src="assets/branding/raven-logo.png" alt="Raven OS desktop artwork" width="400">

# Raven OS

### An open-source Linux workspace for AI and robotics developers

[![Ubuntu Noble](https://img.shields.io/badge/base-Ubuntu%2024.04%20Noble-E95420?logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/noble/)
[![Desktop](https://img.shields.io/badge/desktop-XFCE-2284F2?logo=xfce&logoColor=white)](https://xfce.org/)
[![Architecture](https://img.shields.io/badge/architecture-amd64-2F333A)](#system-requirements)
[![Status](https://img.shields.io/badge/status-early%20development-F5A623)](#project-status)
[![Contributions](https://img.shields.io/badge/contributions-welcome-2EA44F)](#contributing)

Raven OS is a community-driven, Debian-family Linux distribution being built for
people who create intelligent machines. It aims to provide a focused desktop for
AI experimentation, robot development, simulation, edge computing, and the tools
that connect them.

[About](#about) · [Features](#current-features) · [Build](#build-from-source) · [Try it](#run-in-qemu) · [Contribute](#contributing)

</div>

> [!IMPORTANT]
> Raven OS is in early development. The current image is an **amd64 live system**
> based on Ubuntu 24.04 LTS (Noble) with XFCE. A small Ubuntu-supported data-science
> layer is included; broader AI frameworks and the robotics developer stack remain
> on the roadmap. Do not use the image as a production or safety-critical robotics
> platform yet.

## About

AI and robotics work often starts with hours of workstation setup: operating-system
packages, development tools, simulators, device access, middleware, and GPU or edge
hardware support. Raven OS is working toward a reproducible Linux environment where
those pieces belong together from the start.

The project currently produces a bootable, compressed ISO-hybrid image using
[`live-build`](https://manpages.debian.org/live-build). Its foundation is intentionally
lightweight: Ubuntu Noble packages, the Linux generic kernel, the XFCE desktop,
Syslinux/Isolinux for legacy BIOS, and GRUB for UEFI firmware.

## Current features

| Area | What is included today |
| --- | --- |
| Base | Ubuntu 24.04 LTS (Noble), drawing from `main`, `restricted`, `universe`, and `multiverse` |
| Desktop | XFCE, XFCE Goodies, LightDM, and a custom Raven visual theme |
| System | Linux generic kernel, systemd, NetworkManager, PipeWire, and WirePlumber |
| Everyday tools | Firefox, LibreOffice, VLC, GParted, OpenSSH client, Git, cURL, Wget, Vim, Nano, and htop |
| Image | Reproducible amd64 ISO-hybrid with BIOS (Syslinux) and UEFI (GRUB) boot paths |
| Updates | Ubuntu security repositories enabled in the build configuration |

The package definitions live in [`config/package-lists/`](config/package-lists/)
and are separated into stable base, desktop, and AI layers.

## Vision and roadmap

Raven OS is intended to grow into a practical development platform with:

- AI/ML frameworks and notebook-based workflows;
- ROS 2 and common robot-development utilities;
- simulation, visualization, and computer-vision tools;
- reproducible development environments and containers;
- improved support for GPUs, cameras, sensors, and edge-computing boards;
- installer, release, checksum, and upgrade documentation; and
- automated image builds and smoke tests.

Roadmap entries describe project direction, not features already shipped. If one of
these areas is your specialty, contributions are especially welcome.

## Repository layout

```text
Raven-OS/
├── assets/                     # Project-level artwork and branding
│   └── branding/               # Logos used by repository documentation
├── auto/config                 # Reproducible live-build configuration
├── config/
│   ├── bootloaders/isolinux/   # Live boot menu and theme
│   ├── hooks/                  # Build-time compatibility and customization hooks
│   ├── includes.chroot/        # Files copied into the live filesystem
│   └── package-lists/          # Packages installed in the image
└── scripts/
    ├── build.sh                # Clean, deterministic build entry point
    ├── check-ubuntu-compatibility.sh # Guard Ubuntu-specific live-build settings
    ├── resume-build.sh         # Recovery helper for an interrupted build
    └── test-build.sh           # Launch the generated ISO with QEMU/KVM
```

Generated build directories, logs, package manifests, and ISO artifacts remain at
the repository root while building, but are excluded from version control.

## Build from source

### System requirements

- A Linux build host with an amd64 processor;
- enough free storage for package caches, the chroot, and a multi-gigabyte ISO
  (at least 15 GB is a sensible starting point);
- 4 GB RAM or more for testing the image comfortably;
- `sudo` access and an internet connection to Ubuntu package mirrors; and
- `live-build`, `debootstrap`, `syslinux`/`isolinux` tooling, and `xorriso`.

On a compatible Ubuntu or Debian-based host, install the core build and test tools:

```bash
sudo apt update
sudo apt install live-build debootstrap syslinux isolinux xorriso grub-efi-amd64-bin mtools dosfstools qemu-system-x86
```

Clone and build:

```bash
git clone https://github.com/kolithawarnakulasooriya/Raven-OS.git
cd Raven-OS
sudo --preserve-env=SOURCE_DATE_EPOCH ./scripts/build.sh
```

The configured output is `binary.hybrid.iso`, accompanied by
`binary.hybrid.iso.sha256`. The build starts from a clean tree, fixes locale,
timezone, permissions, and timestamps, and then assembles one hybrid image with
both legacy BIOS and x86-64 UEFI boot entries. Set `SOURCE_DATE_EPOCH` to pin a
release timestamp; otherwise the latest Git commit timestamp is used. A full build
downloads many packages and can take a while depending on the host and mirror speed.

> [!NOTE]
> The configuration was generated with a legacy `live-build` configuration format.
> Build-host versions can affect compatibility. If you are changing build settings,
> edit [`auto/config`](auto/config), run `lb config`, and review the regenerated
> files before committing them.

### Recover an interrupted build

This repository contains a narrowly scoped recovery script for known interrupted
bootstrap/chroot and Syslinux build states:

```bash
./scripts/resume-build.sh
```

Read the script before running it. It uses `sudo`, modifies generated build state,
and is intended for this repository's current live-build workflow—not as a general
live-build recovery command.

## Run in QEMU

The included test script starts the generated ISO with four virtual CPUs, 4 GB RAM,
and KVM acceleration:

```bash
./scripts/test-build.sh bios
./scripts/test-build.sh uefi
```

KVM must be available to your user. UEFI testing also requires OVMF (override
its path with `OVMF_CODE`). The equivalent BIOS command is:

```bash
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cdrom binary.hybrid.iso
```

For a host without KVM, omit `-enable-kvm` (the live system will run more slowly).

The current build is a **live environment only**; the Debian installer is disabled
in [`auto/config`](auto/config).

## Customize the image

- Add or remove packages in
  [`config/package-lists/desktop.list.chroot`](config/package-lists/desktop.list.chroot).
- Add files to the target filesystem under `config/includes.chroot/`.
- Add non-interactive build customization under `config/hooks/`.
- Adjust architecture, mirrors, image format, or boot options in
  [`auto/config`](auto/config), then regenerate the live-build configuration.

Keep changes reproducible and avoid embedding credentials, private keys, tokens, or
machine-specific configuration in an image.

### Package layers

Package lists are deliberately ordered by responsibility. `base.list.chroot`
contains the kernel, live-boot, networking, and recovery foundation;
`desktop.list.chroot` adds XFCE and applications; and `ai.list.chroot` adds the
Ubuntu-supported data-science stack. AI dependencies must not move into or replace
the stable base. This lets the upper layer evolve while the bootable foundation
continues to receive ordinary Noble security updates.

## Automated stability checks

Run the fast checks locally before an expensive image build:

```bash
make test
```

They validate Ubuntu configuration, package-layer separation, shell syntax,
reproducible-build controls, and both firmware boot paths. GitHub Actions runs the
same suite plus ShellCheck for every push and pull request. These checks complement,
rather than replace, a full ISO build and BIOS/UEFI boot test.

After building, `make verify-iso` programmatically inspects the El Torito catalog
and asserts that both firmware loaders, the kernel, and the initramfs are present.

### Preserve Ubuntu compatibility

The `auto/` and `config/` directories intentionally remain at the repository root:
`live-build` discovers them there. After reorganizing files or regenerating the
configuration, run the lightweight compatibility check before starting a full
image build:

```bash
./scripts/check-ubuntu-compatibility.sh
```

The check verifies that both `auto/config` and the generated configuration still
select Ubuntu Noble, Ubuntu archive components and keyrings, the generic Ubuntu
kernel, and Casper. It does not replace an ISO build and boot test.

## Contributing

Raven OS is at the stage where careful testing, documentation, packaging, hardware
support, UI work, and architecture discussions all have a meaningful impact.

1. Fork the repository and create a focused branch.
2. Make one coherent change and document why it is needed.
3. Build the ISO when your change affects packages, hooks, boot files, or the live
   filesystem.
4. Boot-test the result in QEMU or on appropriate non-production hardware.
5. Open a pull request describing the change, test environment, and result.

Suggested branch names include `feature/ros2-toolchain`, `fix/live-boot`, and
`docs/build-guide`.

## Project status

This is an experimental, pre-release project. Expect incomplete features, breaking
changes, and inconsistencies while the distribution identity and toolchain mature.
The generated image is suitable for development and testing—not for production,
deployment to safety-critical systems, or handling sensitive data.

## License

The project is uder MIT Opensource licence

## Acknowledgements

Raven OS is built on the work of the Ubuntu, Debian, Linux kernel, live-build, XFCE,
Syslinux, and wider free/open-source software communities.

---

<div align="center">

**Build boldly. Test responsibly. Help shape a Linux home for intelligent machines.**

</div>
