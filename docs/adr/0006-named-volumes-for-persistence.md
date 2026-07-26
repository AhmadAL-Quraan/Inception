# 0006 — Named volumes for DB data and WordPress files

## Status
Accepted

## Context
The subject requires persistent storage for (1) the MariaDB database and
(2) the WordPress site files, so data survives container restarts/recreation,
and it requires this data to live on the host filesystem in a predictable
location rather than purely inside Docker's internal storage driver.

## Decision
Declare two named volumes in `docker-compose.yml`:
- one bind-mounted to a host path for MariaDB's data directory
  (`/var/lib/mysql`)
- one bind-mounted to a host path for WordPress files (themes, plugins,
  uploads, core) shared between the `wordpress` and `nginx` containers

Both use the `local` driver with explicit `device`/bind options pointing at a
fixed host directory (rather than default anonymous/managed volumes), so the
data location is explicit and inspectable outside Docker.

## Consequences
- **Positive:** DB and site content survive `docker compose down` / container
  rebuilds; the WordPress volume being shared between `nginx` and `wordpress`
  lets NGINX serve static files directly without proxying every request
  through PHP-FPM.
- **Negative:** bind-mount paths are host-specific, so the compose file
  encodes assumptions about the host directory structure (mitigated by
  driving the path through `.env`).
- **Related debugging:** NGINX `location` blocks needed care to distinguish
  `root` vs `alias` semantics when serving from this shared volume, since a
  mismatched `root`/`alias` combination silently produces wrong file paths
  rather than an obvious error.
