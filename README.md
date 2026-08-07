# Inception 

<p align="center">
  <b> Configure Nginx, WordPress, PHP-FPM and MariaDB using Docker.</b>
</p>



<p align="center">
  <img src="https://img.shields.io/badge/Status-Inactive-red">
  <img src="https://img.shields.io/badge/Focus-42 project-blue">
  <img src="https://img.shields.io/badge/Linux-Debian-red">
  <img src="https://img.shields.io/badge/Editor-Neovim-green">
<div align="center">

[![Integration Test](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/test-stack.yml/badge.svg)](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/test-stack.yml)
[![Lint & Build](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/Build-lint_checks.yml/badge.svg)](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/Build-lint_checks.yml)
</div>
</p>

--- 

<div align="center">

[![Docs](https://img.shields.io/badge/Docs-In--depth_Technical_Documentation-0A66C2?style=for-the-badge)](https://ahmadal-quraan.github.io/Inception/)
</div>


---


## Workflow

Two main workflows: 
1) `Build-lint_check` workflow: fast, lightweight, catches syntax/style/build-time issues (lint + build images individually)
2) `test-stack.yml` workflow: slower, catches actual runtime/integration test/issues (containers starting, staying healthy, serving real traffic), and how they integrate together.

## Doc

* Reference [USER_DOC](https://github.com/AhmadAL-Quraan/Inception/blob/main/USER_DOC.md) to understand how to use this.
* Reference [DEV_DOC](https://github.com/AhmadAL-Quraan/Inception/blob/main/DEV_DOC.md) to understand how to develop this + The [In-depth technical doc](https://ahmadal-quraan.github.io/Inception/) for a deeper informations.
## Release Signing

Releases are signed via [Sigstore](https://sigstore.dev) using cosign, with identity
tied to the GitHub Actions workflow that produced them.

### Verify a release

```bash
cosign verify-blob \
  --certificate-identity 'https://github.com/AhmadAL-Quraan/Inception/.github/workflows/release.yml@refs/tags/v1.0.0' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  --bundle release.tar.gz.bundle \

  release.tar.gz
```
