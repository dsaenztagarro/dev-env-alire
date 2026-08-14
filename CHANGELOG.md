# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this image follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-14

First tagged release.

### Added

- `alr` is now a **pinned, stable release** (`ALR_VERSION=2.1.1`), fetched at build time with `ADD --checksum` (verified SHA-256) and layer-cached by URL + checksum. Native `aarch64-linux` binaries have shipped in Alire's versioned releases since [PR #1832](https://github.com/alire-project/alire/pull/1832), so a vendored nightly is no longer needed.

### Changed

- Rebased on the decoupled base `dsaenztagarro/dev-env:2.0.1`: runs as the `me` user with the project mounted at `/workspace` (was the `dev` user at `/home/dev/workdir`); paths use `$DEV_USER`.
- apt installs consolidated behind a BuildKit cache mount (`--mount=type=cache`), added `unzip`, and `# syntax=docker/dockerfile:1`.
- `Makefile` mounts `~/Code/alire` at `/workspace` (`-w`); dropped the dead vendored-`alr` existence check.

### Removed

- Vendored nightly `third_party/alr-nightly-bin-aarch64-linux/` (~41 MB `bin/alr` + marker files), replaced by the pinned download above. The Ada Language Server stays vendored (no upstream `aarch64` release to pin yet).

[1.0.0]: https://github.com/dsaenztagarro/dev-env-alire/releases/tag/1.0.0
