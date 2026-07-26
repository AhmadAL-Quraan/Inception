# 0003 — WordPress + PHP-FPM in a container without NGINX

## Status
Accepted

## Context
The subject requires WordPress and PHP-FPM to run in a container that does
**not** include a web server (no bundled NGINX/Apache) — NGINX lives in its
own container and talks to PHP-FPM over FastCGI. WordPress also needs to be
installed and configured non-interactively (no manual setup wizard), since
the whole stack must come up unattended via `docker compose up`.

## Decision
- The `wordpress` service runs `php-fpm` as its foreground process (PID 1),
  listening on TCP 9000, with no HTTP server inside the container.
- WordPress core, config (`wp-config.php`), plugins, and theme setup are
  provisioned at container startup using **WP-CLI**, driven by environment
  variables from `.env` (site URL, admin user/pass, DB host/name/user/pass).
- The container waits for MariaDB to be reachable before running
  `wp core install`, so the two services can be brought up in either order
  under Compose's default (non-blocking) startup.
- WordPress files (themes, uploads, core) are written to a volume shared
  read-only-in-spirit with NGINX, so NGINX can serve static assets directly
  without proxying them through PHP-FPM.

## Consequences
- **Positive:** clean separation of concerns (web server vs. app runtime);
  WP-CLI provisioning makes the whole install reproducible and scriptable,
  no manual browser-based WordPress setup needed; matches the "container has
  no web server" constraint.
- **Negative:** startup ordering/readiness (DB must be up before `wp core
  install` runs) has to be handled explicitly in the entrypoint script,
  since Compose `depends_on` alone doesn't guarantee the DB is *ready*, only
  that its container has started.
- **Trade-off:** using WP-CLI at container start couples first-boot time to
  DB availability; an entrypoint retry/wait loop is required.
