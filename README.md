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

[![Test stack workflow - CI](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/test-stack.yml/badge.svg)](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/test-stack.yml)

[![Test linting workflow - CI](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/ci.yml/badge.svg)](https://github.com/AhmadAL-Quraan/Inception/actions/workflows/ci.yml)
</div>
</p>

--- 

<div align="center">

[![Docs](https://img.shields.io/badge/📘_Full_Documentation-0A66C2?style=for-the-badge)](https://ahmadal-quraan.github.io/Inception/)
</div>



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
