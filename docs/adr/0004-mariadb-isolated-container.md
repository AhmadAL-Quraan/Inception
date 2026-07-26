# 0004 — MariaDB as an isolated, unexposed container

## Status
Accepted

## Context
WordPress needs a relational database. The subject requires MariaDB to run
in its own container, without NGINX, and without any port published to the
host — it must only be reachable from other containers on the internal
Compose network.

## Decision
- The `mariadb` service runs `mariadbd` as its foreground process, with a
  custom Dockerfile (no official MariaDB image reused as-is).
- No `ports:` mapping is declared for MariaDB in `docker-compose.yml` — it is
  reachable only via the internal Docker network at hostname `mariadb` on
  port 3306, resolved through Compose's embedded DNS.
- Database name, application user/password, and root password are supplied
  via environment variables from `.env` and consumed by an entrypoint script
  that runs `mariadb-install-db` and creates the WordPress database/user on
  first start only (guarded by checking for existing data in the volume).
- Database files are written to a named volume so data survives container
  recreation.

## Consequences
- **Positive:** database is not reachable from outside the Docker network at
  all, reducing attack surface to zero external exposure; first-boot
  initialization is idempotent thanks to the data-directory check.
- **Negative:** debugging DB issues requires `docker compose exec` into the
  container or a network-connected client (e.g. Adminer) rather than
  connecting directly from the host.
- Access-denied/init issues encountered during development (grants applying
  only to `localhost` vs. `%`) were resolved by explicitly granting the
  WordPress DB user access from any host on the Compose network, since the
  WordPress container connects as a different network peer, not `localhost`.
