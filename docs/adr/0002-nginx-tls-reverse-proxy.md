# 0002 — NGINX as sole entrypoint, TLS 1.2/1.3 only

## Status
Accepted

## Context
The infrastructure needs a single, secure entrypoint for HTTP(S) traffic.
Exposing PHP-FPM or MariaDB directly to the outside would violate the
project's isolation requirements and be an unnecessary attack surface.
The 42 subject explicitly requires that NGINX be the only container exposing
a port to the host, and that it accept **only** TLSv1.2/TLSv1.3 connections
(no plaintext HTTP, no older TLS/SSL versions).

## Decision
NGINX is deployed as its own container and is the **only** service with a
published port on the host (443). It:
- terminates TLS using a self-signed certificate generated at build/entrypoint
  time (via `openssl`) for `aqoraan.42.fr`
- restricts `ssl_protocols` to `TLSv1.2 TLSv1.3` explicitly in
  `nginx.conf`/`aqoraan.conf`
- proxies PHP requests to the WordPress container over FastCGI
  (`fastcgi_pass wordpress:9000`) instead of serving PHP itself
- serves static assets directly from a shared volume with WordPress's files

## Consequences
- **Positive:** single, well-defined network boundary; PHP-FPM and MariaDB
  stay unreachable from outside the Compose network; enforces modern TLS only,
  satisfying the project's security requirement.
- **Negative:** self-signed certs mean browsers show a trust warning — 
  acceptable for a local/VM-only 42 evaluation context, not production-grade.
- **Risk mitigated:** removing older TLS versions closes downgrade-attack
  paths (e.g. POODLE-style issues tied to SSLv3/TLS1.0/1.1).
