# 0008 — Custom Dockerfiles built from penultimate-stable base images

## Status
Accepted

## Context
The subject forbids pulling prebuilt service images (e.g. `nginx`,
`wordpress`, `mariadb` from Docker Hub) and forbids using `latest` tags or
the most recent Debian/Alpine release. Each service must be built from a
custom Dockerfile starting from the **penultimate stable** version of Debian
or Alpine, with the service installed and configured explicitly.

## Decision
- Every service (`nginx`, `wordpress`, `mariadb`) has its own Dockerfile
  under `srcs/requirements/<service>/`, pinned to an explicit, non-`latest`
  base image tag (penultimate stable Debian/Alpine release).
- Each Dockerfile installs only the packages needed for that one service
  (e.g. `nginx` package + openssl for cert generation; `php-fpm` + WP-CLI +
  WordPress dependencies; `mariadb-server` and client libs), copies in
  service-specific config files, and sets an entrypoint script as the
  container's `CMD`/`ENTRYPOINT` that runs the service in the foreground
  (no supervisors, no daemonizing) so Docker can track process state
  correctly and container lifecycle (restart, logs, signals) works as
  expected.

## Consequences
- **Positive:** full control over exactly what's installed in each image,
  smaller/more auditable images than generic prebuilt ones, satisfies the
  project's constraint on base images and image provenance.
- **Negative:** more maintenance burden — security patches, package version
  bumps, and base-image EOL tracking are the project's own responsibility
  rather than inherited from an upstream official image's maintainers.
- **Trade-off accepted deliberately:** this is an explicit pedagogical goal
  of the project (understanding image construction, not just consuming
  images), so the extra maintenance cost is intentional here and would be
  revisited for a non-educational deployment.
