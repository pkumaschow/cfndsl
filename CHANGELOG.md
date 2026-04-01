# Changelog

## [Unreleased]

### Changed
- Base image updated from `ruby:3-alpine3.17` to `ruby:3-alpine` (EOL Alpine 3.17 replaced with latest)
- `apk upgrade --no-cache` added to apply all OS-level security patches at build time
- cfndsl: 1.4.0 → 1.7.3
- `py-pip` → `py3-pip` (deprecated package removed in newer Alpine)
- `pip install` → `pip3 install --no-cache-dir --break-system-packages` (modern pip invocation)
- `apk add` consolidated and cleaned up; removed separate `apk update` and `apk add --upgrade apk-tools` calls
- `--no-document` added to gem installs (reduces image size)
- aws-sdk pinned to latest at build time

### Security
- **CVE-2025-15467** (CRITICAL) — OpenSSL: Remote code execution via oversized Initialization Vector; fixed by `apk upgrade` → `libcrypto3`/`libssl3`
- **CVE-2025-26519** (HIGH) — musl libc: buffer overflow; fixed by `apk upgrade` → `musl`
- **CVE-2024-49761** (HIGH) — rexml: XDoS via crafted XML; fixed by `gem update rexml`
- **CVE-2025-61594** (HIGH) — uri gem: vulnerability in URI parsing; fixed by `gem update uri`
- **CVE-2026-24049** (HIGH) — wheel/setuptools: Path traversal in `wheel.cli.unpack` — chmod uses unsanitized archive filename; fixed by `pip3 install --upgrade wheel setuptools`

### CI/CD
- Replaced `elgohr/Publish-Docker-Github-Action` with `docker/build-push-action@v6`
- Updated `actions/checkout@master` → `@v4`
- Added Docker layer caching via GitHub Actions cache
- Added SLSA provenance attestation (`provenance: mode=max`) on main branch builds
- Added SBOM attestation (`sbom: true`) on main branch builds
- Integrated Docker Scout: vulnerability comparison on PRs, CVE recording on main
- Publish now triggers only on pushes to `main` (previously all branches/tags)
- Version tag (`pkumaschow/cfndsl:1.7.3`) now pushed alongside `latest`
- `CFNDSL_VERSION` moved to workflow-level `env` (single source of truth)
