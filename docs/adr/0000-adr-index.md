# Architecture Decision Records — Inception

This directory contains the Architecture Decision Records (ADRs) for the
**Inception** project (42 School), which sets up NGINX, WordPress + PHP-FPM,
and MariaDB as separate Docker containers orchestrated with Docker Compose.

Each ADR is immutable once accepted. If a decision changes later, a new ADR
is written that supersedes the old one — the old one is kept for history.

## Index

| ID | Title | Status |
|----|-------|--------|
| [0001](0001-docker-compose-orchestration.md) | Use Docker Compose for multi-container orchestration | Accepted |
| [0002](0002-nginx-tls-reverse-proxy.md) | NGINX as sole entrypoint, TLS 1.2/1.3 only | Accepted |
| [0003](0003-wordpress-php-fpm-separate-container.md) | WordPress + PHP-FPM in a container without NGINX | Accepted |
| [0004](0004-mariadb-isolated-container.md) | MariaDB as an isolated, unexposed container | Accepted |
| [0005](0005-env-file-for-configuration.md) | Use `.env` file for configuration and credentials | Accepted |
| [0006](0006-named-volumes-for-persistence.md) | Named volumes for DB data and WordPress files | Accepted |
| [0007](0007-custom-domain-via-hosts.md) | Custom domain `aqoraan.42.fr` resolved via `/etc/hosts` | Accepted |
| [0008](0008-custom-dockerfiles-penultimate-stable.md) | Custom Dockerfiles built from penultimate-stable base images | Accepted |
