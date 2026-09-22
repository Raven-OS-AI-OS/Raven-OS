<div align="center">

<img src="assets/branding/raven-logo.png" alt="Raven OS logo" width="400">

# Raven OS — Ubuntu-based Linux for AI and Robotics Developers

### An open-source Linux workspace for AI and robotics developers

[![Ubuntu Noble](https://img.shields.io/badge/base-Ubuntu%2024.04%20Noble-E95420?logo=ubuntu&logoColor=white)](https://releases.ubuntu.com/noble/)
[![Desktop](https://img.shields.io/badge/desktop-XFCE-2284F2?logo=xfce&logoColor=white)](https://xfce.org/)
[![Architecture](https://img.shields.io/badge/architecture-amd64-2F333A)](#system-requirements)
[![Status](https://img.shields.io/badge/status-early%20development-F5A623)](#project-status)
[![Contributions](https://img.shields.io/badge/contributions-welcome-2EA44F)](#contributing)

**Raven OS (RavenOS)** is an open-source, Ubuntu-based Linux distribution in
development for AI and robotics developers. Built on **Ubuntu 24.04 LTS (Noble)**
with the **XFCE desktop**, it aims to provide a focused workspace for machine
learning, robot development, simulation, and edge computing.

This is the **official Raven OS source repository**, maintained by
[Raven-OS-AI-OS](https://github.com/Raven-OS-AI-OS).

[Official repository](https://github.com/Raven-OS-AI-OS/Raven-OS) · [Raven OS website](https://raven-os-ai-os.github.io/Web/) · [Report an issue](https://github.com/Raven-OS-AI-OS/Raven-OS/issues)

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
│   ├── hooks/                  # Build-time compatibility hooks
│   ├── local-packages/         # Generated Raven packages installed by a hook
│   └── package-lists/          # Ubuntu packages installed in the image
├── packages/
│   └── raven-customization/    # Packaged Raven identity and desktop defaults
└── scripts/
    ├── build-local-packages.sh # Build Raven-owned Debian packages
    ├── check-compatibility.sh # Guard Ubuntu-specific live-build settings
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


## Development 

On a compatible Ubuntu or Debian-based host, install the core build and test tools:

```bash
sudo apt update
sudo apt install live-build debootstrap syslinux isolinux xorriso grub-efi-amd64-bin mtools dosfstools qemu-system-x86
```

Clone and build:

```bash
git clone https://github.com/Raven-OS-AI-OS/Raven-OS.git
cd Raven-OS

```

Running `auto/config` also refreshes the local customization package before it
regenerates the `live-build` configuration.

The configured output is `binary.hybrid.iso`. A full build downloads many packages
and can take a while depending on the host and mirror speed.


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

The current build is a **live environment only**; the Debian installer is disabled
in [`auto/config`](auto/config).

## Customize the image

- Add or remove Ubuntu packages in
  [`config/package-lists/raven-desktop.list.chroot`](config/package-lists/raven-desktop.list.chroot).
- Add or remove AI related packages in
  [`config/package-lists/raven-ai.list.chroot`](config/package-lists/raven-ai.list.chroot).
- Add Raven-owned files under
  [`packages/raven-customization/rootfs/`](packages/raven-customization/rootfs/),
  update the package version, and run `./scripts/build-local-packages.sh`.
- Add non-interactive build compatibility work under `config/hooks/`.
- Adjust architecture, mirrors, image format, or boot options in
  [`auto/config`](auto/config), then regenerate the live-build configuration.

Keep changes reproducible and avoid embedding credentials, private keys, tokens, or
machine-specific configuration in an image.

## Automated stability checks

Run the fast checks locally before an expensive image build:

```bash
make test
```

They validate Ubuntu configuration, package-layer separation, shell syntax,
reproducible-build controls, and both firmware boot paths. 

** GitHub Actions **  
same suite plus ShellCheck for every push and pull request. These checks complement,
rather than replace, a full ISO build and BIOS/UEFI boot test.

### Preserve compatibility

The `auto/` and `config/` directories intentionally remain at the repository root:
`live-build` discovers them there. After reorganizing files or regenerating the
configuration, run the lightweight compatibility check before starting a full
image build:

```bash
./scripts/check-compatibility.sh
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

Raven OS is open-source software licensed under the MIT License.

## Acknowledgements

Raven OS is built on the work of the Ubuntu, Debian, Linux kernel, live-build, XFCE,
Syslinux, and wider free/open-source software communities.

---

<div align="center">

**Build boldly. Test responsibly. Help shape a Linux home for intelligent machines.**

</div>
